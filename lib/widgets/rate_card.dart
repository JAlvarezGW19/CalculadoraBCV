import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';
import 'add_rate_dialog.dart';

class RateDisplayCard extends ConsumerWidget {
  final AsyncValue<RatesData> ratesAsyncValue;
  final CustomRate? currentCustomRate;
  final double bcvComparisonRate;

  const RateDisplayCard({
    super.key,
    required this.ratesAsyncValue,
    required this.currentCustomRate,
    required this.bcvComparisonRate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversionProvider);
    if (state.currency == CurrencyType.custom) {
      return _buildCustomRateCard(
        context,
        ref,
        state,
        currentCustomRate,
        bcvComparisonRate,
      );
    }
    return _buildStandardRateCard(state, ratesAsyncValue);
  }

  Widget _buildStandardRateCard(
    ConversionState state,
    AsyncValue<RatesData> ratesAsyncValue,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text("Tasa Oficial BCV", style: AppTheme.subtitleStyle),
          const SizedBox(height: 10),
          ratesAsyncValue.when(
            data: (rates) {
              final isUsd = state.currency == CurrencyType.usd;
              final isToday = state.dateMode == RateDateMode.today;
              final rate = isUsd
                  ? (isToday ? rates.usdToday : rates.usdTomorrow)
                  : (isToday ? rates.eurToday : rates.eurTomorrow);
              final symbol = isUsd ? "USD" : "EUR";

              final dateToUse = isToday ? rates.todayDate : rates.tomorrowDate;

              String dateStr = "---";
              if (dateToUse != null) {
                dateStr = DateFormat('dd/MM/yyyy').format(dateToUse);
              }

              return Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "1 $symbol = ",
                          style: AppTheme.rateLabelStyle,
                        ),
                        TextSpan(
                          text:
                              "${NumberFormat("#,##0.00", "es_VE").format(rate)} VES",
                          style: AppTheme.rateStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppTheme.textSubtle.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Fecha Valor: $dateStr",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSubtle.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () =>
                const CircularProgressIndicator(color: AppTheme.textAccent),
            error: (err, stack) => const Text(
              "Error cargando tasa",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRateCard(
    BuildContext context,
    WidgetRef ref,
    ConversionState state,
    CustomRate? rate,
    double bcvComparisonRate,
  ) {
    final customRates = ref.watch(customRatesProvider);

    // Fallback if null (shouldn't happen if list not empty)
    if (rate == null && customRates.isNotEmpty) rate = customRates.first;
    if (rate == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.currency_exchange,
              color: AppTheme.textSubtle,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "Crea tu primera tasa personalizada",
              style: AppTheme.subtitleStyle.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Agrega tasas de cambios personalizadas para calcular tus conversiones.",
              style: TextStyle(
                color: AppTheme.textSubtle.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                "Crear Tasa",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.textAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final newRate = await showAddEditRateDialog(context, ref);
                if (newRate != null) {
                  ref
                      .read(conversionProvider.notifier)
                      .setSelectedCustomRate(newRate.id);
                }
              },
            ),
          ],
        ),
      );
    }

    double diff = 0.0;
    if (bcvComparisonRate > 0 && rate.rate > 0) {
      diff = ((rate.rate - bcvComparisonRate) / bcvComparisonRate) * 100;
    }

    final bcvLabel = state.comparisonBase == CurrencyType.usd
        ? "BCV USD"
        : "BCV EUR";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Partially Stacked to allow robust centering of title + right buttons
          SizedBox(
            height: 20,
            child: Stack(
              children: [
                // 1. Center: Dropdown or Title
                Align(
                  alignment: Alignment.center,
                  child: customRates.isEmpty
                      ? Text("Crea una tasa", style: AppTheme.subtitleStyle)
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: customRates.any((r) => r.id == rate!.id)
                                ? rate.id
                                : null,
                            dropdownColor: AppTheme.cardBackground,
                            style: AppTheme.subtitleStyle,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.textAccent,
                            ),
                            items: customRates.map((r) {
                              return DropdownMenuItem(
                                value: r.id,
                                child: Text(r.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref
                                    .read(conversionProvider.notifier)
                                    .setSelectedCustomRate(val);
                              }
                            },
                          ),
                        ),
                ),

                // 2. Right: Buttons
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: AppTheme.textAccent,
                        ),
                        iconSize: 20,
                        onPressed: () async {
                          final newRate = await showAddEditRateDialog(
                            context,
                            ref,
                          );
                          if (newRate != null) {
                            ref
                                .read(conversionProvider.notifier)
                                .setSelectedCustomRate(newRate.id);
                          }
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        tooltip: "Crear nueva tasa",
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppTheme.textSubtle,
                        ),
                        iconSize: 20,
                        onPressed: () =>
                            showAddEditRateDialog(context, ref, rate: rate),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        tooltip: "Editar tasa",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "1 ${rate.name} = ",
                  style: AppTheme.rateLabelStyle,
                ),
                TextSpan(
                  text:
                      "${NumberFormat("#,##0.00", "es_VE").format(rate.rate)} VES",
                  style: AppTheme.rateStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Comparison Row
          GestureDetector(
            onTap: () {
              final newBase = state.comparisonBase == CurrencyType.usd
                  ? CurrencyType.eur
                  : CurrencyType.usd;
              ref.read(conversionProvider.notifier).setComparisonBase(newBase);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$bcvLabel: ${bcvComparisonRate.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: AppTheme.textSubtle,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(height: 12, width: 1, color: Colors.white24),
                  const SizedBox(width: 8),
                  Text(
                    "${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}%",
                    style: TextStyle(
                      color: diff >= 0 ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.swap_horiz,
                    color: AppTheme.textSubtle,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
