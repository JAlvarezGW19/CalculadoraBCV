import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/history_point.dart';

class HistoryService {
  static const String _cacheKey = 'history_rates_cache_v3';
  static const String _lastUpdateKey = 'history_last_update_v3';

  // Singleton para mantener el listener activo
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  StreamSubscription<DocumentSnapshot>? _listener;
  List<dynamic>? _cachedRates;

  /// Inicia el listener en tiempo real para detectar nuevas tasas
  void startRealtimeListener() {
    if (_listener != null) {
      debugPrint('⚠️ Listener ya está activo');
      return;
    }

    debugPrint('🔔 Iniciando listener en tiempo real para historial...');

    _listener = FirebaseFirestore.instance
        .collection('historial_tasas')
        .doc('consolidated')
        .snapshots()
        .listen(
          (snapshot) async {
            if (snapshot.exists) {
              final data = snapshot.data();
              if (data != null && data['rates'] != null) {
                final newRates = data['rates'] as List<dynamic>;
                final lastUpdate = data['last_updated'] as Timestamp?;

                // Verificar si hay cambios
                final shouldUpdate = await _hasNewData(lastUpdate);

                if (shouldUpdate) {
                  _cachedRates = newRates;
                  await _cacheData(newRates, lastUpdate);
                  debugPrint(
                    '🔔 Nueva tasa detectada! Caché actualizado: ${newRates.length} registros',
                  );
                }
              }
            }
          },
          onError: (error) {
            debugPrint('❌ Error en listener de historial: $error');
          },
        );
  }

  /// Detiene el listener en tiempo real
  void stopRealtimeListener() {
    _listener?.cancel();
    _listener = null;
    debugPrint('🔕 Listener de historial detenido');
  }

  /// Verifica si hay nuevos datos comparando timestamps
  Future<bool> _hasNewData(Timestamp? newTimestamp) async {
    if (newTimestamp == null) return true;

    final prefs = await SharedPreferences.getInstance();
    final lastUpdateStr = prefs.getString(_lastUpdateKey);

    if (lastUpdateStr == null) return true;

    final lastUpdate = DateTime.parse(lastUpdateStr);
    final newUpdate = newTimestamp.toDate();

    return newUpdate.isAfter(lastUpdate);
  }

  Future<List<HistoryPoint>> fetchHistory(
    String currency, // 'USD' or 'EUR'
    DateTime start,
    DateTime end,
    double currentRate,
  ) async {
    List<dynamic> ratesList = [];

    // 1. Intentar usar caché en memoria primero (más rápido)
    if (_cachedRates != null && _cachedRates!.isNotEmpty) {
      ratesList = _cachedRates!;
      debugPrint(
        '⚡ Historial cargado desde memoria: ${ratesList.length} registros',
      );
    }
    // 2. Si no hay caché en memoria, cargar desde SharedPreferences
    else {
      ratesList = await _loadCache();
      if (ratesList.isNotEmpty) {
        _cachedRates = ratesList;
        debugPrint(
          '📦 Historial cargado desde caché: ${ratesList.length} registros',
        );
      }
    }

    // 3. Si no hay caché, hacer fetch inicial de Firestore
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
            _cachedRates = ratesList;
            final lastUpdate = data['last_updated'] as Timestamp?;
            await _cacheData(ratesList, lastUpdate);
            debugPrint(
              '✅ Historial cargado desde Firestore: ${ratesList.length} registros (1 lectura)',
            );
          }
        }
      } catch (e) {
        debugPrint("❌ Error cargando historial: $e");
        throw Exception("No se pudo cargar el historial.");
      }
    }

    if (ratesList.isEmpty) {
      throw Exception("No hay datos históricos disponibles.");
    }

    // 4. Filtrar y mapear datos
    List<HistoryPoint> points = [];

    // Normalizar fechas a inicio del día (00:00:00)
    final startYMD = DateTime(start.year, start.month, start.day);
    final endYMD = DateTime(end.year, end.month, end.day);

    for (var item in ratesList) {
      String? dateStr = item['rate_date'];

      // Limpiar formato ISO si es necesario
      if (dateStr != null && dateStr.contains("T")) {
        dateStr = dateStr.split("T")[0];
      }

      final rawDate = DateTime.tryParse(dateStr ?? "");

      if (rawDate != null) {
        final itemDate = DateTime(rawDate.year, rawDate.month, rawDate.day);

        // Verificar si está en el rango (inclusivo)
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

    // Ordenar por fecha ascendente
    points.sort((a, b) => a.date.compareTo(b.date));

    debugPrint('📊 Puntos filtrados para el rango: ${points.length}');
    return points;
  }

  Future<void> _cacheData(List<dynamic> rates, Timestamp? lastUpdate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(rates));

    if (lastUpdate != null) {
      await prefs.setString(
        _lastUpdateKey,
        lastUpdate.toDate().toIso8601String(),
      );
    }

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
}
