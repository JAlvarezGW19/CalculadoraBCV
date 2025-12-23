import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _endpointHistory =
      'https://bcv-api.rafnixg.dev/rates/history';
  static const String _endpointCrossRates =
      'https://open.er-api.com/v6/latest/USD';

  static const String _cachedDataKey = 'cached_rates_history_v3';

  Future<Map<String, dynamic>> fetchRates() async {
    try {
      final responseHistory = await http.get(Uri.parse(_endpointHistory));

      double usdToday = 0.0;
      double usdTomorrow = 0.0;
      bool hasTomorrow = false;

      if (responseHistory.statusCode == 200) {
        final data = json.decode(responseHistory.body);
        if (data['rates'] != null && (data['rates'] as List).isNotEmpty) {
          final List rates = data['rates'];

          if (rates.isNotEmpty) {
            final latestRate = rates[0];
            final latestDateStr = latestRate['date'] as String; // YYYY-MM-DD
            final latestVal = (latestRate['dollar'] as num).toDouble();

            final now = DateTime.now();
            final todayStr =
                "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

            final latestDate = DateTime.parse(latestDateStr);
            final todayDate = DateTime.parse(todayStr);

            if (latestDate.isAfter(todayDate)) {
              // Tenemos tasa para mañana (publicada hoy para mañana)
              usdTomorrow = latestVal;
              hasTomorrow = true;

              if (rates.length > 1) {
                usdToday = (rates[1]['dollar'] as num).toDouble();
              } else {
                usdToday = latestVal;
              }
            } else {
              // La última tasa es la de hoy (o anterior).
              usdToday = latestVal;
              usdTomorrow = 0.0;
              hasTomorrow = false;
            }
          }
        }
      }

      // Fetch Euro Cross Rate
      final responseCross = await http.get(Uri.parse(_endpointCrossRates));
      double eurRateInUsd = 0.0;

      if (responseCross.statusCode == 200) {
        final data = json.decode(responseCross.body);
        if (data['rates'] != null && data['rates']['EUR'] != null) {
          eurRateInUsd = (data['rates']['EUR'] as num).toDouble();
        }
      }

      // Calculate Euros
      double eurToday = 0.0;
      double eurTomorrow = 0.0;

      if (eurRateInUsd > 0) {
        if (usdToday > 0) eurToday = usdToday / eurRateInUsd;
        if (usdTomorrow > 0) eurTomorrow = usdTomorrow / eurRateInUsd;
      } else {
        if (usdToday > 0) eurToday = usdToday * 1.1; // Fallback
        if (usdTomorrow > 0) eurTomorrow = usdTomorrow * 1.1;
      }

      final result = {
        'usd_today': usdToday,
        'usd_tomorrow': usdTomorrow,
        'eur_today': eurToday,
        'eur_tomorrow': eurTomorrow,
        'has_tomorrow': hasTomorrow,
      };

      await _cacheData(result);
      return result;
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
