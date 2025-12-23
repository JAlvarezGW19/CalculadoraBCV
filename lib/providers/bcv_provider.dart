import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// 1. Enums
enum CurrencyType { usd, eur }

enum RateDateMode { today, tomorrow } // "Mañana" es la vigente para el usuario

// 2. Models
class RatesData {
  final double usdToday;
  final double usdTomorrow;
  final double eurToday;
  final double eurTomorrow;
  final bool hasTomorrow; // Flag to indicate if tomorrow's rate is available

  const RatesData({
    required this.usdToday,
    required this.usdTomorrow,
    required this.eurToday,
    required this.eurTomorrow,
    required this.hasTomorrow,
  });
}

// 3. Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final ratesProvider = FutureProvider<RatesData>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  final data = await apiService.fetchRates();
  return RatesData(
    usdToday: (data['usd_today'] as num?)?.toDouble() ?? 0.0,
    usdTomorrow: (data['usd_tomorrow'] as num?)?.toDouble() ?? 0.0,
    eurToday: (data['eur_today'] as num?)?.toDouble() ?? 0.0,
    eurTomorrow: (data['eur_tomorrow'] as num?)?.toDouble() ?? 0.0,
    hasTomorrow: data['has_tomorrow'] as bool? ?? false,
  );
});

// 4. State
class ConversionState {
  final String foreignValue; // USD or EUR input
  final String vesValue;
  final CurrencyType currency;
  final RateDateMode dateMode;

  ConversionState({
    this.foreignValue = '',
    this.vesValue = '',
    this.currency = CurrencyType.usd,
    this.dateMode = RateDateMode.tomorrow,
  });

  ConversionState copyWith({
    String? foreignValue,
    String? vesValue,
    CurrencyType? currency,
    RateDateMode? dateMode,
  }) {
    return ConversionState(
      foreignValue: foreignValue ?? this.foreignValue,
      vesValue: vesValue ?? this.vesValue,
      currency: currency ?? this.currency,
      dateMode: dateMode ?? this.dateMode,
    );
  }
}

class ConversionNotifier extends Notifier<ConversionState> {
  @override
  ConversionState build() {
    return ConversionState();
  }

  void setCurrency(CurrencyType type) {
    state = state.copyWith(currency: type, foreignValue: '', vesValue: '');
  }

  void setDateMode(RateDateMode mode) {
    state = state.copyWith(dateMode: mode);
    // Recalculate if needed, but easier to clear or keep values and let user retype or auto-update?
    // Let's keep values and trigger recalculation if possible, but here we just update state.
    // Ideally we should re-convert current values with new rate, but rate is passed in methods.
    // For simplicity, we'll clear inputs to avoid confusion or keep them?
    // Keeping them requires access to the rate here, which is in AsyncValue.
    // Let's clear to be safe and simple.
    state = state.copyWith(foreignValue: '', vesValue: '');
  }

  // Update logic when user types Foreign Currency
  void updateForeign(String input, double rate) {
    if (input.isEmpty) {
      state = state.copyWith(foreignValue: '', vesValue: '');
      return;
    }

    // Handle decimals
    if (input.endsWith('.')) {
      state = state.copyWith(foreignValue: input);
      final val = double.tryParse(input);
      if (val != null) {
        final ves = val * rate;
        state = state.copyWith(vesValue: ves.toStringAsFixed(2));
      }
      return;
    }

    final val = double.tryParse(input);
    if (val != null) {
      final ves = val * rate;
      state = state.copyWith(
        foreignValue: input,
        vesValue: ves.toStringAsFixed(2),
      );
    } else {
      state = state.copyWith(foreignValue: input, vesValue: '');
    }
  }

  // Update logic when user types VES
  void updateVES(String input, double rate) {
    if (input.isEmpty) {
      state = state.copyWith(foreignValue: '', vesValue: '');
      return;
    }

    if (input.endsWith('.')) {
      state = state.copyWith(vesValue: input);
      final val = double.tryParse(input);
      if (val != null && rate > 0) {
        final foreign = val / rate;
        state = state.copyWith(foreignValue: foreign.toStringAsFixed(2));
      }
      return;
    }

    final val = double.tryParse(input);
    if (val != null && rate > 0) {
      final foreign = val / rate;
      state = state.copyWith(
        vesValue: input,
        foreignValue: foreign.toStringAsFixed(2),
      );
    } else {
      state = state.copyWith(vesValue: input, foreignValue: '');
    }
  }
}

final conversionProvider =
    NotifierProvider<ConversionNotifier, ConversionState>(
      ConversionNotifier.new,
    );
