import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_widget_service.dart';

class ApiService {
  static const String _endpoint =
      'https://api.dolarvzla.com/public/exchange-rate';
  static const String _cachedDataKey = 'cached_rates_dolarvzla_v1';

  Future<Map<String, dynamic>> fetchRates({bool forceRefresh = false}) async {
    // 1. Try to load cache first to check freshness
    Map<String, dynamic>? cachedData;
    try {
      cachedData = await loadInternalCache();
    } catch (_) {
      // No cache or error loading it
    }

    if (!forceRefresh && cachedData != null) {
      if (isCacheValid(cachedData)) {
        return cachedData;
      }
    }

    // 2. Try Fetching from API
    try {
      final response = await http
          .get(Uri.parse(_endpoint))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return await _processApiResponse(response.body);
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      // 3. Fallback: Web Scraping from BCV
      debugPrint("API failed, attempting scraping: $e");
      try {
        return await _fetchFromWebScraping();
      } catch (e2) {
        debugPrint("Scraping failed: $e2");
        // If everything fails, return old cache if available
        if (cachedData != null) return cachedData;
        rethrow;
      }
    }
  }

  bool isCacheValid(Map<String, dynamic> cache) {
    if (cache['last_fetch'] == null) return false;

    final lastFetch = DateTime.parse(cache['last_fetch']);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final fourPM = DateTime(now.year, now.month, now.day, 16, 0);

    DateTime? todayDateInCache;
    if (cache['today_date'] != null) {
      todayDateInCache = DateTime.parse(cache['today_date']);
    }

    // Check if cache date matches today
    final isCacheToday =
        todayDateInCache != null &&
        todayDateInCache.year == today.year &&
        todayDateInCache.month == today.month &&
        todayDateInCache.day == today.day;

    final hasTomorrow = cache['has_tomorrow'] == true;

    // RULE 1: If we have tomorrow's rate, we are good.
    if (hasTomorrow) return true;

    // RULE 2: If cache is from today and it's before 4 PM.
    // Assuming rates don't change until after 4 PM.
    if (isCacheToday && now.isBefore(fourPM)) {
      return true;
    }

    // RULE 3: If it's after 4 PM, check debounce (30 mins).
    // Or if we already have today's final rate (implied if we fetched after 4pm and no tomorrow yet).
    if (now.isAfter(fourPM)) {
      final diff = now.difference(lastFetch);
      if (diff.inMinutes < 30) {
        return true; // Wait 30 mins before trying again
      }
    }

    // If cache is from yesterday or older, return false (force update)
    if (!isCacheToday && !hasTomorrow) return false;

    return false; // Default to fetch
  }

  Future<Map<String, dynamic>> _processApiResponse(String body) async {
    final data = json.decode(body);
    final current = data['current'];
    final previous = data['previous'];
    final currentDate = DateTime.parse(current['date']);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    double usdToday = 0.0, usdTomorrow = 0.0;
    double eurToday = 0.0, eurTomorrow = 0.0;
    bool hasTomorrow = false;
    DateTime? dateTodayVal, dateTomorrowVal;

    if (currentDate.isAfter(today)) {
      usdTomorrow = (current['usd'] as num).toDouble();
      eurTomorrow = (current['eur'] as num).toDouble();
      hasTomorrow = true;
      dateTomorrowVal = currentDate;

      if (previous != null) {
        usdToday = (previous['usd'] as num).toDouble();
        eurToday = (previous['eur'] as num).toDouble();
        dateTodayVal = previous['date'] != null
            ? DateTime.parse(previous['date'])
            : today;
      } else {
        usdToday = usdTomorrow;
        eurToday = eurTomorrow;
        dateTodayVal = today;
      }
    } else {
      usdToday = (current['usd'] as num).toDouble();
      eurToday = (current['eur'] as num).toDouble();
      hasTomorrow = false;
      dateTodayVal = currentDate;
      dateTomorrowVal = null;
    }

    final result = {
      'usd_today': usdToday,
      'usd_tomorrow': usdTomorrow,
      'eur_today': eurToday,
      'eur_tomorrow': eurTomorrow,
      'has_tomorrow': hasTomorrow,
      'last_fetch': DateTime.now().toIso8601String(),
      'today_date': dateTodayVal.toIso8601String(),
      'tomorrow_date': dateTomorrowVal?.toIso8601String(),
    };

    await _cacheData(result);
    return result;
  }

  Future<Map<String, dynamic>> _fetchFromWebScraping() async {
    // Web scraping specific for http://www.bcv.org.ve/
    // Since SSL might fail on some networks for BCV, try/catch http.
    // Note: BCV website certificate issues are common.
    final response = await http
        .get(Uri.parse('http://www.bcv.org.ve/'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final body = response.body;

      // Extract USD
      // Pattern: <div id="dolar"> ... <strong> 45,3200 </strong>
      final usdRegex = RegExp(
        r'id="dolar".*?<strong>\s*([\d,]+)\s*</strong>',
        caseSensitive: false,
        dotAll: true,
      );
      final usdMatch = usdRegex.firstMatch(body);
      final usdStr = usdMatch?.group(1)?.replaceAll(',', '.') ?? "0";

      // Extract EUR
      final eurRegex = RegExp(
        r'id="euro".*?<strong>\s*([\d,]+)\s*</strong>',
        caseSensitive: false,
        dotAll: true,
      );
      final eurMatch = eurRegex.firstMatch(body);
      final eurStr = eurMatch?.group(1)?.replaceAll(',', '.') ?? "0";

      final usd = double.tryParse(usdStr) ?? 0.0;
      final eur = double.tryParse(eurStr) ?? 0.0;

      if (usd == 0.0) throw Exception("Failed to scrape USD");

      // Construct payload
      // Scraping only gives "current" rates. We assume they are for "Today" unless update logic implies otherwise.
      // We don't know "tomorrow" from scraping main page usually.

      final now = DateTime.now();

      final result = {
        'usd_today': usd,
        'usd_tomorrow': 0.0,
        'eur_today': eur,
        'eur_tomorrow': 0.0,
        'has_tomorrow': false,
        'last_fetch': now.toIso8601String(),
        'today_date': now.toIso8601String(), // Saving "now" as date reference
        'tomorrow_date': null,
      };

      await _cacheData(result);
      return result;
    }
    throw Exception("BCV Website Unreachable: ${response.statusCode}");
  }

  Future<void> _cacheData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedDataKey, json.encode(data));

    // Update Home Screen Widget
    try {
      final double usd = data['usd_today'] ?? 0.0;
      final double eur = data['eur_today'] ?? 0.0;
      final String date =
          data['today_date'] ?? DateTime.now().toIso8601String();

      final bool isPremium = prefs.getBool('is_premium') ?? false;

      // Update widget in background (don't await to avoid blocking UI/Flow)
      HomeWidgetService.updateWidgetData(
        usdRate: usd,
        eurRate: eur,
        rateDate: date,
        isPremium: isPremium,
      );
    } catch (e) {
      debugPrint("Widget update error: $e");
    }
  }

  Future<Map<String, dynamic>> loadInternalCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_cachedDataKey)) {
      final jsonString = prefs.getString(_cachedDataKey);
      if (jsonString != null) {
        return json.decode(jsonString);
      }
    }
    throw Exception(
      'Sin conexión a internet y sin datos en caché disponibles.',
    );
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedDataKey);
  }

  Future<void> refreshWidgetFromCache() async {
    try {
      final data = await loadInternalCache();
      // Since loadFromCache returns a Map if successful, we can use it.
      // But we need to check if it has the data structure we expect.
      // It relies on _cacheData logic which already does this, but we need to call updateWidget explicitly.
      // Actually, let's just reuse _cacheData logic but without re-saving/overwriting if not needed?
      // No, better to extract the widget update logic or just duplicate it briefly here for clarity.

      final double usd = data['usd_today'] ?? 0.0;
      final double eur = data['eur_today'] ?? 0.0;
      final String date =
          data['today_date'] ?? DateTime.now().toIso8601String();

      final prefs = await SharedPreferences.getInstance();
      final bool isPremium = prefs.getBool('is_premium') ?? false;

      HomeWidgetService.updateWidgetData(
        usdRate: usd,
        eurRate: eur,
        rateDate: date,
        isPremium: isPremium,
      );
    } catch (_) {
      // No cache or error
    }
  }
}
