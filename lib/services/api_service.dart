import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _endpoint =
      'https://api.dolarvzla.com/public/exchange-rate';
  static const String _cachedDataKey = 'cached_rates_dolarvzla_v1';

  Future<Map<String, dynamic>> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(_endpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse 'current' and 'previous'
        final current = data['current'];
        final previous = data['previous'];

        // Dates format in API is usually "YYYY-MM-DD" e.g. "2025-12-23"
        // We parse it to DateTime.
        final currentDate = DateTime.parse(current['date']);

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        double usdToday = 0.0;
        double usdTomorrow = 0.0;
        double eurToday = 0.0;
        double eurTomorrow = 0.0;
        bool hasTomorrow = false;

        // Logic:
        // If 'current' date is AFTER today -> It's Tomorrow's rate. 'previous' is Today's rate.
        // If 'current' date is TODAY (or older) -> It's Today's rate. Tomorrow is unavailable.

        if (currentDate.isAfter(today)) {
          // 'current' contains tomorrow's rates
          usdTomorrow = (current['usd'] as num).toDouble();
          eurTomorrow = (current['eur'] as num).toDouble();
          hasTomorrow = true;

          if (previous != null) {
            usdToday = (previous['usd'] as num).toDouble();
            eurToday = (previous['eur'] as num).toDouble();
          } else {
            // Fallback
            usdToday = usdTomorrow;
            eurToday = eurTomorrow;
          }
        } else {
          // 'current' contains today's rates
          usdToday = (current['usd'] as num).toDouble();
          eurToday = (current['eur'] as num).toDouble();
          // Reset tomorrow values
          usdTomorrow = 0.0;
          eurTomorrow = 0.0;
          hasTomorrow = false;
        }

        final result = {
          'usd_today': usdToday,
          'usd_tomorrow': usdTomorrow,
          'eur_today': eurToday,
          'eur_tomorrow': eurTomorrow,
          'has_tomorrow': hasTomorrow,
          'last_fetch': DateTime.now().toIso8601String(),
          'rate_date': currentDate.toIso8601String(),
        };

        await _cacheData(result);
        return result;
      } else {
        return await _loadFromCache();
      }
    } catch (e) {
      return await _loadFromCache();
    }
  }

  Future<void> _cacheData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedDataKey, json.encode(data));
  }

  Future<Map<String, dynamic>> _loadFromCache() async {
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
}
