import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/history_point.dart';

class HistoryService {
  static const String _cacheKey = 'history_rates_cache_v2';
  static const String _lastFetchKey = 'history_last_fetch_v2';

  Future<List<HistoryPoint>> fetchHistory(
    String currency, // 'USD' or 'EUR'
    DateTime start,
    DateTime end,
    double currentRate,
  ) async {
    List<dynamic> ratesList = [];

    // 1. Try to load from Firestore (Primary) or cache
    try {
      if (await _shouldFetch()) {
        // ✨ NUEVA ESTRUCTURA: Leer UN SOLO documento consolidado
        final docSnapshot = await FirebaseFirestore.instance
            .collection('historial_tasas')
            .doc('consolidated')
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data['rates'] != null) {
            ratesList = data['rates'] as List<dynamic>;
            await _cacheData(ratesList);
            debugPrint(
              '✅ Historial cargado desde Firestore: ${ratesList.length} registros (1 lectura)',
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Firestore History fetch error: $e");
    }

    // 2. Load from cache if Firestore failed or wasn't needed
    if (ratesList.isEmpty) {
      ratesList = await _loadCache();
      if (ratesList.isNotEmpty) {
        debugPrint(
          '📦 Historial cargado desde caché: ${ratesList.length} registros',
        );
      }
    }

    // Si sigue vacío, intentamos forzar fetch aunque no toque
    if (ratesList.isEmpty) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('historial_tasas')
            .doc('consolidated')
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data['rates'] != null) {
            ratesList = data['rates'] as List<dynamic>;
            await _cacheData(ratesList);
            debugPrint(
              '✅ Historial forzado desde Firestore: ${ratesList.length} registros',
            );
          }
        }
      } catch (e) {
        debugPrint("Error en fetch forzado: $e");
      }
    }

    if (ratesList.isEmpty) {
      throw Exception("No hay datos históricos disponibles.");
    }

    // 3. Filter and Map
    List<HistoryPoint> points = [];

    // Normalize range dates to start of day (00:00:00)
    final startYMD = DateTime(start.year, start.month, start.day);
    final endYMD = DateTime(end.year, end.month, end.day);

    for (var item in ratesList) {
      // En la nueva estructura, cada item tiene: { rate_date, usd, eur, source }
      String? dateStr = item['rate_date'];

      // Some old cache might have partial ISO string
      if (dateStr != null && dateStr.contains("T")) {
        dateStr = dateStr.split("T")[0];
      }

      final rawDate = DateTime.tryParse(dateStr ?? "");

      if (rawDate != null) {
        // Normalize item date to 00:00:00
        final itemDate = DateTime(rawDate.year, rawDate.month, rawDate.day);

        // Inclusive check: start <= item <= end
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

    // Sort by date ascending for the graph
    points.sort((a, b) => a.date.compareTo(b.date));

    debugPrint('📊 Puntos filtrados para el rango: ${points.length}');
    return points;
  }

  Future<bool> _shouldFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_lastFetchKey);
    if (lastStr == null) return true;

    final last = DateTime.parse(lastStr);
    // Fetch if older than 6 hours (puedes ajustar este tiempo)
    return DateTime.now().difference(last).inHours > 6;
  }

  Future<void> _cacheData(List<dynamic> rates) async {
    final prefs = await SharedPreferences.getInstance();
    // Cache as JSON list
    await prefs.setString(_cacheKey, json.encode(rates));
    await prefs.setString(_lastFetchKey, DateTime.now().toIso8601String());
    debugPrint('💾 Caché guardado: ${rates.length} registros');
  }

  Future<List<dynamic>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_cacheKey);
    if (str != null) {
      try {
        return json.decode(str);
      } catch (e) {
        debugPrint('Error decodificando caché: $e');
        return [];
      }
    }
    return [];
  }

  /// Método para forzar actualización del caché
  Future<void> forceRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastFetchKey);
    debugPrint('🔄 Caché de historial invalidado');
  }

  /// Método para limpiar caché completamente
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_lastFetchKey);
    debugPrint('🗑️ Caché de historial eliminado');
  }
}
