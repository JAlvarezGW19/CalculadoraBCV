import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_point.dart';
import '../services/history_service.dart';
import 'bcv_provider.dart';

enum HistoryRange { week, month, threeMonths, year, custom }

enum HistoryViewMode { chart, list }

class HistoryState {
  final List<HistoryPoint> data;
  final bool isLoading;
  final CurrencyType selectedCurrency;
  final HistoryRange selectedRange;
  final HistoryViewMode viewMode;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String? error;

  HistoryState({
    this.data = const [],
    this.isLoading = false,
    this.selectedCurrency = CurrencyType.usd,
    this.selectedRange = HistoryRange.month,
    this.viewMode = HistoryViewMode.chart,
    this.customStartDate,
    this.customEndDate,
    this.error,
  });

  HistoryState copyWith({
    List<HistoryPoint>? data,
    bool? isLoading,
    CurrencyType? selectedCurrency,
    HistoryRange? selectedRange,
    HistoryViewMode? viewMode,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? error,
    bool clearError = false,
  }) {
    return HistoryState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      selectedRange: selectedRange ?? this.selectedRange,
      viewMode: viewMode ?? this.viewMode,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final historyServiceProvider = Provider<HistoryService>(
  (ref) => HistoryService(),
);

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  HistoryNotifier.new,
);

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    return HistoryState();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final service = ref.read(historyServiceProvider);
      final ratesAsync = ref.read(ratesProvider);

      // Get Anchor Rate
      double currentRate = 0.0;
      if (ratesAsync.hasValue) {
        final rates = ratesAsync.value!;
        final isToday = rates.usdToday > 0;

        currentRate = state.selectedCurrency == CurrencyType.usd
            ? (isToday ? rates.usdToday : rates.usdTomorrow)
            : (isToday ? rates.eurToday : rates.eurTomorrow);

        if (currentRate == 0) {
          currentRate = state.selectedCurrency == CurrencyType.usd
              ? rates.usdTomorrow
              : rates.eurTomorrow;
        }
      }

      final dateRange = _calculateDateRange();

      final points = await service.fetchHistory(
        state.selectedCurrency == CurrencyType.usd ? 'USD' : 'EUR',
        dateRange.start,
        dateRange.end,
        currentRate,
      );

      state = state.copyWith(data: points, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  DateTimeRange _calculateDateRange() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (state.selectedRange) {
      case HistoryRange.week:
        start = now.subtract(const Duration(days: 7));
        break;
      case HistoryRange.month:
        start = now.subtract(const Duration(days: 30));
        break;
      case HistoryRange.threeMonths:
        start = now.subtract(const Duration(days: 90));
        break;
      case HistoryRange.year:
        start = now.subtract(const Duration(days: 365));
        break;
      case HistoryRange.custom:
        start = state.customStartDate ?? now.subtract(const Duration(days: 30));
        end = state.customEndDate ?? now;
        break;
    }
    return DateTimeRange(start: start, end: end);
  }

  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == HistoryViewMode.chart
          ? HistoryViewMode.list
          : HistoryViewMode.chart,
    );
  }

  void setCurrency(CurrencyType type) {
    if (state.selectedCurrency == type) return;
    state = state.copyWith(selectedCurrency: type);
    loadHistory();
  }

  void setRange(HistoryRange range, {DateTime? start, DateTime? end}) {
    if (state.selectedRange == range && range != HistoryRange.custom) return;

    state = state.copyWith(
      selectedRange: range,
      customStartDate: start,
      customEndDate: end,
    );
    loadHistory();
  }
}
