import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  final DateTime? todayDate;
  final DateTime? tomorrowDate;

  const RatesData({
    required this.usdToday,
    required this.usdTomorrow,
    required this.eurToday,
    required this.eurTomorrow,
    required this.hasTomorrow,
    this.lastFetch,
    this.todayDate,
    this.tomorrowDate,
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

final ratesProvider = AsyncNotifierProvider<RatesNotifier, RatesData>(
  RatesNotifier.new,
);

class RatesNotifier extends AsyncNotifier<RatesData> {
  @override
  Future<RatesData> build() async {
    final apiService = ref.read(apiServiceProvider);

    // 1. Try to load cache immediately (optimistic UI)
    Map<String, dynamic>? localData;
    try {
      localData = await apiService.loadInternalCache();
    } catch (_) {}

    if (localData != null) {
      // Logic for optimistic return
      final rates = _parseData(localData);

      // Check if data is fresh. If not, trigger background update.
      // But we return the stale data immediately so the UI renders.
      if (!apiService.isCacheValid(localData)) {
        _fetchInBackground();
      }

      return rates;
    }

    // 2. No cache? Must fetch (blocking UI, but only for first run ever)
    final fresh = await apiService.fetchRates();
    return _parseData(fresh);
  }

  Future<void> _fetchInBackground() async {
    // Avoid blocking the build
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final apiService = ref.read(apiServiceProvider);
      final fresh = await apiService.fetchRates(forceRefresh: true);
      state = AsyncData(_parseData(fresh));
    } catch (e) {
      // If native fetch fails, we just keep the stale data.
      // Maybe show a toast/snackbar if needed, but for now silent failure is better than crash.
      debugPrint("Background fetch failed: $e");
    }
  }

  RatesData _parseData(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic val) {
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final fallbackDate = parseDate(data['rate_date']);

    // Handle migration from old cache structure
    DateTime? tDate = parseDate(data['today_date']);
    DateTime? tomDate = parseDate(data['tomorrow_date']);
    final bool hasTom = data['has_tomorrow'] as bool? ?? false;

    if (tDate == null && tomDate == null && fallbackDate != null) {
      if (hasTom) {
        tomDate = fallbackDate;
        tDate = DateTime.now();
      } else {
        tDate = fallbackDate;
      }
    }

    // ROLLING OVER LOGIC:
    // If we have a "Tomorrow Rate" but that date IS NOW TODAY (or past),
    // then that rate becomes Today's rate.
    if (hasTom && tomDate != null) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      // Check if tomorrowDate is effectively today (start of day comparison)
      final bool isNowToday =
          tomDate.year == todayStart.year &&
          tomDate.month == todayStart.month &&
          tomDate.day == todayStart.day;

      // Or if based on logic it's in the past (unlikely but safe to handle)
      final bool isPast = tomDate.isBefore(todayStart);

      if (isNowToday || isPast) {
        // Shift values!
        tDate = tomDate;
        // Rates rollover
        final double usd = (data['usd_tomorrow'] as num?)?.toDouble() ?? 0.0;
        final double eur = (data['eur_tomorrow'] as num?)?.toDouble() ?? 0.0;

        // We override "today" values with these "tomorrow" values
        // We modify the map or just return correct RatesData?
        // Better to construct RatesData directly.

        return RatesData(
          usdToday: usd,
          usdTomorrow: 0.0, // Reset tomorrow
          eurToday: eur,
          eurTomorrow: 0.0, // Reset tomorrow
          hasTomorrow: false, // No longer have a NEXT day rate known
          lastFetch: parseDate(data['last_fetch']),
          todayDate: tDate,
          tomorrowDate: null,
        );
      }
    }

    // SANITY CHECK: prevent Today == Tomorrow if hasTomorrow is true
    // (This block is somewhat redundant if the above logic works, but kept for safety
    // if tomorrow is strictly distinct)
    if (hasTom && tDate != null && tomDate != null) {
      if (tDate.year == tomDate.year &&
          tDate.month == tomDate.month &&
          tDate.day == tomDate.day) {
        // This condition catches if source data said A is today and A is also tomorrow?
        // Or blindly parsed.
        // But the rollover logic above handles the case where Tomorrow BECAME Today.
        // This block might have been intended to fix bad API data.
        // Let's keep it but simplified or rely on above.
        // Actually, if we returned above, this code isn't reached.
      }
    }

    return RatesData(
      usdToday: (data['usd_today'] as num?)?.toDouble() ?? 0.0,
      usdTomorrow: (data['usd_tomorrow'] as num?)?.toDouble() ?? 0.0,
      eurToday: (data['eur_today'] as num?)?.toDouble() ?? 0.0,
      eurTomorrow: (data['eur_tomorrow'] as num?)?.toDouble() ?? 0.0,
      hasTomorrow: hasTom,
      lastFetch: parseDate(data['last_fetch']),
      todayDate: tDate,
      tomorrowDate: tomDate,
    );
  }

  // Check for updates respecting cache validity
  Future<void> checkForUpdates() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      // forceRefresh: false means it will only fetch if the cache is expired
      // according to our new tighter rules (every 2 mins after 3pm).
      final fresh = await apiService.fetchRates(forceRefresh: false);

      // We update the state. Since Riverpod handles equality, this won't trigger
      // rebuilds if the data is identical.
      state = AsyncData(_parseData(fresh));
    } catch (e) {
      // Silent failure is intended here as this is a background poll
      debugPrint("Poll failed: $e");
    }
  }

  // Method to manually force refresh if user wants
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final apiService = ref.read(apiServiceProvider);
      final fresh = await apiService.fetchRates(forceRefresh: true);
      state = AsyncData(_parseData(fresh));
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

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

  CustomRate addRate(String name, double rate) {
    final newRate = CustomRate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      rate: rate,
    );
    state = [...state, newRate];
    _saveRates();
    return newRate;
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
  final bool isVesSource; // True if VES was the last field edited
  final bool
  isRoundingEnabled; // True: 2 decimals, False: Dynamic decimals/precision
  final bool isInvertedOrder; // True: VES on top, Foreign on bottom

  ConversionState({
    this.foreignValue = '',
    this.vesValue = '',
    this.currency = CurrencyType.usd,
    this.dateMode = RateDateMode.today,
    this.selectedCustomRateId,
    this.comparisonBase = CurrencyType.usd,
    this.isVesSource = false,
    this.isRoundingEnabled = true,
    this.isInvertedOrder = false,
  });

  ConversionState copyWith({
    String? foreignValue,
    String? vesValue,
    CurrencyType? currency,
    RateDateMode? dateMode,
    String? selectedCustomRateId,
    CurrencyType? comparisonBase,
    bool? isVesSource,
    bool? isRoundingEnabled,
    bool? isInvertedOrder,
  }) {
    return ConversionState(
      foreignValue: foreignValue ?? this.foreignValue,
      vesValue: vesValue ?? this.vesValue,
      currency: currency ?? this.currency,
      dateMode: dateMode ?? this.dateMode,
      selectedCustomRateId: selectedCustomRateId ?? this.selectedCustomRateId,
      comparisonBase: comparisonBase ?? this.comparisonBase,
      isVesSource: isVesSource ?? this.isVesSource,
      isRoundingEnabled: isRoundingEnabled ?? this.isRoundingEnabled,
      isInvertedOrder: isInvertedOrder ?? this.isInvertedOrder,
    );
  }
}

class ConversionNotifier extends Notifier<ConversionState> {
  @override
  ConversionState build() {
    // Automatically recalculate if rates update (e.g. background fetch completes)
    ref.listen(ratesProvider, (previous, next) {
      if (next.hasValue && !next.isLoading) {
        _recalculateValues();
      }
    });
    return ConversionState();
  }

  // Toggle Visual Order (Foreign/VES position)
  void toggleOrder() {
    state = state.copyWith(isInvertedOrder: !state.isInvertedOrder);
  }

  // Helper for dynamic formatting
  String _formatNumber(double value) {
    if (state.isRoundingEnabled) {
      return NumberFormat("#,##0.00", "es_VE").format(value);
    } else {
      // Rounded disabled: Show full precision (up to 8 decimals)
      return NumberFormat("#,##0.########", "es_VE").format(value);
    }
  }

  void _recalculateValues() {
    final ratesAsync = ref.read(ratesProvider);
    double rate = 0.0;

    if (ratesAsync.hasValue) {
      final r = ratesAsync.value!;
      if (state.currency == CurrencyType.usd) {
        rate = state.dateMode == RateDateMode.today
            ? r.usdToday
            : r.usdTomorrow;
      } else if (state.currency == CurrencyType.eur) {
        rate = state.dateMode == RateDateMode.today
            ? r.eurToday
            : r.eurTomorrow;
      } else {
        // Custom
        final customRates = ref.read(customRatesProvider);
        if (customRates.isNotEmpty) {
          final id = state.selectedCustomRateId;
          final match = customRates.firstWhere(
            (c) => c.id == id,
            orElse: () => customRates.first,
          );
          // Update ID if it was implicit/fallback
          if (state.selectedCustomRateId != match.id) {
            state = state.copyWith(selectedCustomRateId: match.id);
          }
          rate = match.rate;
        }
      }
    }

    if (rate <= 0) {
      // If rate is valid (0 or negative, which shouldn't happen for rates but 0 is possible if empty),
      // we must zero out the RESULT, but keep the INPUT.
      if (state.isVesSource) {
        // Source is VES, so Foreign Result should be 0
        state = state.copyWith(foreignValue: _formatNumber(0));
      } else {
        // Source is Foreign, so VES Result should be 0
        state = state.copyWith(vesValue: _formatNumber(0));
      }
      return;
    }

    if (state.isVesSource) {
      // Recalculate Foreign based on VES
      if (state.vesValue.isNotEmpty) {
        final val = _parseInput(state.vesValue);
        if (val != null) {
          final foreign = val / rate;
          state = state.copyWith(foreignValue: _formatNumber(foreign));
        } else {
          state = state.copyWith(foreignValue: '');
        }
      } else {
        state = state.copyWith(foreignValue: '');
      }
    } else {
      // Recalculate VES based on Foreign
      if (state.foreignValue.isNotEmpty) {
        final val = _parseInput(state.foreignValue);
        if (val != null) {
          final ves = val * rate;
          state = state.copyWith(vesValue: _formatNumber(ves));
        } else {
          state = state.copyWith(vesValue: '');
        }
      } else {
        state = state.copyWith(vesValue: '');
      }
    }
  }

  void setCurrency(CurrencyType type) {
    if (state.currency == type) return;
    state = state.copyWith(currency: type);
    _recalculateValues();
  }

  void setDateMode(RateDateMode mode) {
    if (state.dateMode == mode) return;
    state = state.copyWith(dateMode: mode);
    _recalculateValues();
  }

  void setSelectedCustomRate(String id) {
    if (state.selectedCustomRateId == id) return;
    state = state.copyWith(selectedCustomRateId: id);
    _recalculateValues();
  }

  void setComparisonBase(CurrencyType type) {
    if (type == CurrencyType.usd || type == CurrencyType.eur) {
      state = state.copyWith(comparisonBase: type);
    }
  }

  void toggleRounding() {
    state = state.copyWith(isRoundingEnabled: !state.isRoundingEnabled);
    _recalculateValues();
  }

  // Formatting helper logic removed from static field to instance method

  double? _parseInput(String input) {
    // Robust Sanitize: Remove everything except digits and commas.
    // This ensures thousands separators (dots) or other symbols are ignored.
    String clean = input.replaceAll(RegExp(r'[^0-9,]'), '');
    // Replace comma with dot for standard double parsing
    clean = clean.replaceAll(',', '.');
    return double.tryParse(clean);
  }

  // Update logic when user types Foreign Currency
  void updateForeign(String input, double rate) {
    if (input.isEmpty) {
      state = state.copyWith(
        foreignValue: '',
        vesValue: '',
        isVesSource: false,
      );
      return;
    }

    // Handle decimal separator being typed (comma or dot)
    state = state.copyWith(foreignValue: input, isVesSource: false);

    final val = _parseInput(input);
    if (val != null) {
      final ves = val * rate;
      state = state.copyWith(vesValue: _formatNumber(ves));
    } else {
      state = state.copyWith(vesValue: '');
    }
  }

  // Update logic when user types VES
  void updateVES(String input, double rate) {
    if (input.isEmpty) {
      state = state.copyWith(foreignValue: '', vesValue: '', isVesSource: true);
      return;
    }

    state = state.copyWith(vesValue: input, isVesSource: true);

    final val = _parseInput(input);
    if (val != null && rate > 0) {
      final foreign = val / rate;
      state = state.copyWith(foreignValue: _formatNumber(foreign));
    } else {
      state = state.copyWith(foreignValue: '');
    }
  }
}

final conversionProvider =
    NotifierProvider<ConversionNotifier, ConversionState>(
      ConversionNotifier.new,
    );

// Provider to track the active tab index for Ad management
// Provider to track the active tab index for Ad management
class ActiveTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  // Method to update state
  @override
  set state(int value) => super.state = value;
}

final activeTabProvider = NotifierProvider<ActiveTabNotifier, int>(
  ActiveTabNotifier.new,
);
