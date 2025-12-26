import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // import debugPrint
import '../models/history_point.dart';

class HistoryService {
  static const String _endpoint =
      'https://api.dolarvzla.com/public/exchange-rate/list';
  static const String _cacheKey = 'history_rates_cache';
  static const String _lastFetchKey = 'history_last_fetch';

  Future<List<HistoryPoint>> fetchHistory(
    String currency, // 'USD' or 'EUR'
    DateTime start,
    DateTime end,
    double currentRate,
  ) async {
    List<dynamic> ratesList = [];

    // 1. Try to load from API if cache is old or empty
    try {
      if (await _shouldFetch()) {
        final response = await http.get(Uri.parse(_endpoint));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['rates'] != null) {
            ratesList = data['rates'];
            await _cacheData(ratesList);
          }
        }
      }
    } catch (e) {
      // Network error, fall through to cache
      debugPrint("History fetch error: $e");
    }

    // 2. Load from cache if API failed or wasn't needed
    if (ratesList.isEmpty) {
      ratesList = await _loadCache();
    }

    if (ratesList.isEmpty) {
      // Only if absolutely no data is available
      throw Exception("No hay datos históricos disponibles.");
    }

    // 3. Filter and Map
    List<HistoryPoint> points = [];

    // Normalize range dates to start of day (00:00:00)
    final startYMD = DateTime(start.year, start.month, start.day);
    final endYMD = DateTime(end.year, end.month, end.day);

    for (var item in ratesList) {
      final dateStr = item['date'];
      final rawDate = DateTime.tryParse(dateStr);

      if (rawDate != null) {
        // Normalize item date to 00:00:00 to avoid timezone/time issues
        final itemDate = DateTime(rawDate.year, rawDate.month, rawDate.day);

        // Inclusive check: start <= item <= end
        // Use compareTo for robust comparison
        if (itemDate.compareTo(startYMD) >= 0 &&
            itemDate.compareTo(endYMD) <= 0) {
          double? rateVal;
          if (currency == 'USD') {
            rateVal = (item['usd'] as num?)?.toDouble();
          } else {
            rateVal = (item['eur'] as num?)?.toDouble();
          }

          if (rateVal != null) {
            points.add(HistoryPoint(date: itemDate, rate: rateVal));
          }
        }
      }
    }

    // Sort by date ascending
    points.sort((a, b) => a.date.compareTo(b.date));

    return points;
  }

  Future<bool> _shouldFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_lastFetchKey);
    if (lastStr == null) return true;

    final last = DateTime.parse(lastStr);
    // Fetch if older than 12 hours
    return DateTime.now().difference(last).inHours > 12;
  }

  Future<void> _cacheData(List<dynamic> rates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(rates));
    await prefs.setString(_lastFetchKey, DateTime.now().toIso8601String());
  }

  Future<List<dynamic>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_cacheKey);
    if (str != null) {
      return json.decode(str);
    }
    return [];
  }
}
