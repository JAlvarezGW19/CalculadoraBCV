import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

// 1. Enums
enum CurrencyType { usd, eur, custom }

enum RateDateMode { today, tomorrow }

// 2. Models
class RatesData {
  final double usdToday;
  final double usdTomorrow;
  final double eurToday;
  final double eurTomorrow;
  final bool hasTomorrow;
  final DateTime? lastFetch;
  final DateTime? rateDate;

  const RatesData({
    required this.usdToday,
    required this.usdTomorrow,
    required this.eurToday,
    required this.eurTomorrow,
    required this.hasTomorrow,
    this.lastFetch,
    this.rateDate,
  });
}

class CustomRate {
  final String id;
  final String name;
  final double rate;

  CustomRate({required this.id, required this.name, required this.rate});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'rate': rate};

  factory CustomRate.fromJson(Map<String, dynamic> json) {
    return CustomRate(
      id: json['id'],
      name: json['name'],
      rate: (json['rate'] as num).toDouble(),
    );
  }

  CustomRate copyWith({String? name, double? rate}) {
    return CustomRate(id: id, name: name ?? this.name, rate: rate ?? this.rate);
  }
}

// 3. Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final ratesProvider = FutureProvider<RatesData>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final data = await apiService.fetchRates();

  DateTime? parseDate(dynamic val) {
    if (val is String) return DateTime.tryParse(val);
    return null;
  }

  return RatesData(
    usdToday: (data['usd_today'] as num?)?.toDouble() ?? 0.0,
    usdTomorrow: (data['usd_tomorrow'] as num?)?.toDouble() ?? 0.0,
    eurToday: (data['eur_today'] as num?)?.toDouble() ?? 0.0,
    eurTomorrow: (data['eur_tomorrow'] as num?)?.toDouble() ?? 0.0,
    hasTomorrow: data['has_tomorrow'] as bool? ?? false,
    lastFetch: parseDate(data['last_fetch']),
    rateDate: parseDate(data['rate_date']),
  );
});

class CustomRatesNotifier extends Notifier<List<CustomRate>> {
  @override
  List<CustomRate> build() {
    _loadRates();
    return [];
  }

  static const _key = 'custom_rates_v1';

  Future<void> _loadRates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      final List decoded = json.decode(jsonStr);
      state = decoded.map((e) => CustomRate.fromJson(e)).toList();
    }
  }

  Future<void> _saveRates() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = json.encode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }

  void addRate(String name, double rate) {
    final newRate = CustomRate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      rate: rate,
    );
    state = [...state, newRate];
    _saveRates();
  }

  void updateRate(String id, String name, double rate) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(name: name, rate: rate) else r,
    ];
    _saveRates();
  }

  void deleteRate(String id) {
    state = state.where((r) => r.id != id).toList();
    _saveRates();
  }
}

final customRatesProvider =
    NotifierProvider<CustomRatesNotifier, List<CustomRate>>(
      CustomRatesNotifier.new,
    );

// 4. State
class ConversionState {
  final String foreignValue;
  final String vesValue;
  final CurrencyType currency;
  final RateDateMode dateMode; // Applies to standard currencies
  final String? selectedCustomRateId; // For custom mode
  final CurrencyType comparisonBase; // Compare custom vs USD or EUR

  ConversionState({
    this.foreignValue = '',
    this.vesValue = '',
    this.currency = CurrencyType.usd,
    this.dateMode = RateDateMode.today,
    this.selectedCustomRateId,
    this.comparisonBase = CurrencyType.usd,
  });

  ConversionState copyWith({
    String? foreignValue,
    String? vesValue,
    CurrencyType? currency,
    RateDateMode? dateMode,
    String? selectedCustomRateId,
    CurrencyType? comparisonBase,
  }) {
    return ConversionState(
      foreignValue: foreignValue ?? this.foreignValue,
      vesValue: vesValue ?? this.vesValue,
      currency: currency ?? this.currency,
      dateMode: dateMode ?? this.dateMode,
      selectedCustomRateId: selectedCustomRateId ?? this.selectedCustomRateId,
      comparisonBase: comparisonBase ?? this.comparisonBase,
    );
  }
}

class ConversionNotifier extends Notifier<ConversionState> {
  @override
  ConversionState build() {
    return ConversionState();
  }

  void setCurrency(CurrencyType type) {
    if (state.currency == type) return;
    // When switching to custom, ensure we have a selection if available
    state = state.copyWith(currency: type, foreignValue: '', vesValue: '');
  }

  void setDateMode(RateDateMode mode) {
    if (state.dateMode == mode) return;
    state = state.copyWith(dateMode: mode, foreignValue: '', vesValue: '');
  }

  void setSelectedCustomRate(String id) {
    if (state.selectedCustomRateId == id) return;
    state = state.copyWith(
      selectedCustomRateId: id,
      foreignValue: '',
      vesValue: '',
    );
  }

  void setComparisonBase(CurrencyType type) {
    if (type == CurrencyType.usd || type == CurrencyType.eur) {
      state = state.copyWith(comparisonBase: type);
    }
  }

  final _formatter = NumberFormat("#,##0.00", "es_VE");

  double? _parseInput(String input) {
    // Sanitize: Remove thousands separator (.), replace decimal separator (,) with (.)
    String clean = input.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(clean);
  }

  // Update logic when user types Foreign Currency
  void updateForeign(String input, double rate) {
    if (input.isEmpty) {
      state = state.copyWith(foreignValue: '', vesValue: '');
      return;
    }

    // Handle decimal separator being typed (comma or dot)
    // If ending with separator, just update state so user sees it, don't recalc yet or do?
    // standard behavior: allow typing.
    state = state.copyWith(foreignValue: input);

    final val = _parseInput(input);
    if (val != null) {
      final ves = val * rate;
      state = state.copyWith(vesValue: _formatter.format(ves));
    } else {
      state = state.copyWith(vesValue: '');
    }
  }

  // Update logic when user types VES
  void updateVES(String input, double rate) {
    if (input.isEmpty) {
      state = state.copyWith(foreignValue: '', vesValue: '');
      return;
    }

    state = state.copyWith(vesValue: input);

    final val = _parseInput(input);
    if (val != null && rate > 0) {
      final foreign = val / rate;
      state = state.copyWith(foreignValue: _formatter.format(foreign));
    } else {
      state = state.copyWith(foreignValue: '');
    }
  }
}

final conversionProvider =
    NotifierProvider<ConversionNotifier, ConversionState>(
      ConversionNotifier.new,
    );
