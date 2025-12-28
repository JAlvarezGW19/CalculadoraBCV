import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_toggles.dart';
import '../widgets/rate_card.dart';
import '../widgets/conversion_card.dart';
import '../widgets/native_ad_widget.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsyncValue = ref.watch(ratesProvider);
    final conversionState = ref.watch(conversionProvider);
    final customRates = ref.watch(customRatesProvider);

    // Determine active rate and comparison rate
    double activeRate = 0.0;
    double bcvComparisonRate = 0.0;
    CustomRate? currentCustomRate;

    if (ratesAsyncValue.hasValue) {
      final rates = ratesAsyncValue.value!;

      // Calculate BCV Rates for reference
      final isToday = conversionState.dateMode == RateDateMode.today;
      final usdRate = isToday ? rates.usdToday : rates.usdTomorrow;
      final eurRate = isToday ? rates.eurToday : rates.eurTomorrow;

      final useTomIfAvailable = rates.hasTomorrow;
      if (conversionState.comparisonBase == CurrencyType.usd) {
        bcvComparisonRate = useTomIfAvailable
            ? rates.usdTomorrow
            : rates.usdToday;
      } else {
        bcvComparisonRate = useTomIfAvailable
            ? rates.eurTomorrow
            : rates.eurToday;
      }

      // Determine Active Conversion Rate
      if (conversionState.currency == CurrencyType.custom) {
        final id = conversionState.selectedCustomRateId;
        if (customRates.isNotEmpty) {
          currentCustomRate = customRates.firstWhere(
            (r) => r.id == id,
            orElse: () => customRates.first,
          );
          activeRate = currentCustomRate.rate;

          // Ensure selected ID is valid in state
          if (conversionState.selectedCustomRateId != currentCustomRate.id) {
            Future.microtask(
              () => ref
                  .read(conversionProvider.notifier)
                  .setSelectedCustomRate(currentCustomRate!.id),
            );
          }
        }
      } else {
        if (conversionState.currency == CurrencyType.usd) {
          activeRate = usdRate;
        } else {
          activeRate = eurRate;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          // Toggles Row
          CurrencyToggles(
            hasTomorrow: ratesAsyncValue.value?.hasTomorrow ?? false,
            tomorrowDate: ratesAsyncValue.value?.tomorrowDate,
          ),
          const SizedBox(height: 10),

          // 1. Exchange Rate Display Card
          RateDisplayCard(
            ratesAsyncValue: ratesAsyncValue,
            currentCustomRate: currentCustomRate,
            bcvComparisonRate: bcvComparisonRate,
          ),
          const SizedBox(height: 24),

          // 2. Main Conversion Area
          // 2. Main Conversion Area
          if (ratesAsyncValue.hasValue)
            ConversionCard(
              activeRate: activeRate,
              customRate: currentCustomRate,
              bcvCompRate: bcvComparisonRate,
              rateDate: conversionState.dateMode == RateDateMode.today
                  ? ratesAsyncValue.value?.todayDate
                  : ratesAsyncValue.value?.tomorrowDate,
            )
          else if (ratesAsyncValue.isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.textAccent),
            )
          else if (ratesAsyncValue.hasError)
            const SizedBox.shrink(),
          const SizedBox(height: 24),
          const NativeAdWidget(assignedTabIndex: 0),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
