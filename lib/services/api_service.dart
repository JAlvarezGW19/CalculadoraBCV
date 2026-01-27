import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'home_widget_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ApiService {
  static const String _cachedDataKey = 'cached_rates_dolarvzla_v1';

  Future<Map<String, dynamic>> fetchRates({bool forceRefresh = false}) async {
    // 1. Try to load cache first (Fastest)
    Map<String, dynamic>? cachedData;
    try {
      cachedData = await loadInternalCache();
    } catch (_) {}

    if (!forceRefresh && cachedData != null) {
      if (isCacheValid(cachedData)) {
        return cachedData;
      }
    }

    // 2. Try Firestore (Primary Source)
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('tasa_oficial')
          .doc('bcv')
          .get(
            GetOptions(
              source: forceRefresh ? Source.server : Source.serverAndCache,
            ),
          ); // Force server if requested

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return await _processFirestoreData(docSnapshot.data()!);
      }
    } catch (e) {
      debugPrint("Firestore fetch failed: $e");
    }

    // 3. Fallbacks (API with Key or Scraping) - Only if Firestore fails
    // We only use the API/Scraping if we are essentially "offline" from Firestore
    // or if Firestore is empty.
    // Given the new architecture, we rely on Firestore.
    // But we keep the old logic just in case for now, or return cache if available.
    if (cachedData != null) return cachedData;

    // If absolutely nothing works, rethrow
    throw Exception("No data available from Firestore or Cache");
  }

  Future<Map<String, dynamic>> _processFirestoreData(
    Map<String, dynamic> data,
  ) async {
    final double usd = (data['usd'] as num).toDouble();
    final double eur = (data['eur'] as num).toDouble();
    final bool hasTomorrow = data['has_tomorrow'] ?? false;

    String? dateTodayStr =
        data['date']; // The date the record was updated/created
    String? rateDateStr = data['rate_date']; // The actual value date

    // Determine dates
    DateTime dateVal = DateTime.now();
    if (rateDateStr != null) {
      dateVal = DateTime.parse(rateDateStr);
    } else if (dateTodayStr != null) {
      dateVal = DateTime.parse(dateTodayStr);
    }

    // Logic: If has_tomorrow is TRUE, the basic fields 'usd'/'eur' ARE the tomorrow rates.
    // We need to decide what 'today' is. Usually 'today' is the previous rate.
    // But for simplicity, if we only have one record, 'current' implies the one active.

    double usdToday = usd;
    double usdTomorrow = 0.0;
    double eurToday = eur;
    double eurTomorrow = 0.0;

    DateTime? dateTomorrowVal;

    if (hasTomorrow) {
      // The values in DB are treated as "Tomorrow's"
      usdTomorrow = usd;
      eurTomorrow = eur;
      dateTomorrowVal = dateVal;

      // Try to fetch "Today's" rate from history to process correctly
      try {
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final historyDoc = await FirebaseFirestore.instance
            .collection('historial_tasas')
            .doc(todayStr)
            .get();

        if (historyDoc.exists && historyDoc.data() != null) {
          final hData = historyDoc.data()!;
          usdToday = (hData['usd'] as num).toDouble();
          eurToday = (hData['eur'] as num).toDouble();
        } else {
          // If not found in history (rare), fallback to older logic or current
          // Ideally we check cache, but for now we set equal to avoid empty UI
          usdToday = usd;
          eurToday = eur;
        }
      } catch (e) {
        debugPrint("Error fetching today history: $e");
        // Fallback
        usdToday = usd;
        eurToday = eur;
      }
    } else {
      // Standard today rate
      usdToday = usd;
      eurToday = eur;
    }

    DateTime dateTodayFinal;

    if (hasTomorrow) {
      // dateTomorrowVal is already set to dateVal (Fecha del dato principal, que es Mañana)

      // Si encontramos data en historial de hoy, usamos esa fecha. Si no, usamos 'now'.
      // Pero para UI, 'today_date' debe ser HOY.
      dateTodayFinal = DateTime.now();

      // (El código de fetch del precio usdToday ya está bien arriba)
    } else {
      // Si NO hay mañana, el dato principal 'dateVal' ES de hoy.
      dateTodayFinal = dateVal;
    }

    final result = {
      'usd_today': usdToday,
      'usd_tomorrow': usdTomorrow,
      'eur_today': eurToday,
      'eur_tomorrow': eurTomorrow,
      'has_tomorrow': hasTomorrow,
      'last_fetch': DateTime.now().toIso8601String(),
      'today_date': dateTodayFinal.toIso8601String(),
      'tomorrow_date': dateTomorrowVal?.toIso8601String(),
    };

    await _cacheData(result);
    return result;
  }

  bool isCacheValid(Map<String, dynamic> cache) {
    if (cache['last_fetch'] == null) return false;

    final lastFetch = DateTime.parse(cache['last_fetch']);
    final now = DateTime.now();

    final hasTomorrow = cache['has_tomorrow'] == true;

    // RULE 1: If we ALREADY have tomorrow's rate, we can relax the cache significantly.
    // The rate typically doesn't change again until the next publication.
    // We keep cache valid for 18 hours to practically stop checking for the rest of the day.
    // The HomeScreen handles the date rollover (midnight) separately.
    if (hasTomorrow) {
      // Sanity Check: If the stored "tomorrow" date is already in the past,
      // the cache is definitely stale (user opened app after a few days).
      if (cache['tomorrow_date'] != null) {
        final tDate = DateTime.parse(cache['tomorrow_date']);
        final tomorrow = DateTime(tDate.year, tDate.month, tDate.day);
        final today = DateTime(now.year, now.month, now.day);

        if (tomorrow.isBefore(today)) {
          return false;
        }
      }

      final diffInMinutes = now.difference(lastFetch).inMinutes;
      return diffInMinutes < 1080; // 18 hours
    }

    // RULE 2: If we DO NOT have tomorrow's rate, we are hunting for it.
    final diffInMinutes = now.difference(lastFetch).inMinutes;

    // Weekend Check: BCV rarely updates on weekends
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return diffInMinutes < 60;
    }

    // Weekday Logic
    if (now.hour < 8) {
      // Early morning: Very unlikely to update
      return diffInMinutes < 120; // 2 hours
    } else if (now.hour < 16) {
      // Regular Work Day: Check every 30 mins until 4 PM
      return diffInMinutes < 30;
    } else {
      // CRITICAL ZONE: 4:00 PM onwards (Weekdays)
      // BCV rates can be published anytime afternoon.
      // We set cache validity to 10 minutes to save Firebase reads.
      // Using 2 mins is too aggressive for Quota. User can pull-to-refresh if desperate.
      return diffInMinutes < 10;
    }
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

      // Update widget in background (don't await to avoid blocking UI/Flow)
      // WIDGET IS NOW FREE FOR EVERYONE (Requested by User)
      HomeWidgetService.updateWidgetData(
        usdRate: usd,
        eurRate: eur,
        rateDate: date,
        isPremium: true, // Force true to unlock widget for all
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

      HomeWidgetService.updateWidgetData(
        usdRate: usd,
        eurRate: eur,
        rateDate: date,
        isPremium: true, // Force true (Widget is free)
      );
    } catch (_) {
      // No cache or error
    }
  }
}
