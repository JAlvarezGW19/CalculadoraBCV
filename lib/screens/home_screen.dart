import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _foreignController = TextEditingController();
  final TextEditingController _vesController = TextEditingController();

  @override
  void dispose() {
    _foreignController.dispose();
    _vesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratesAsyncValue = ref.watch(ratesProvider);
    final conversionState = ref.watch(conversionProvider);

    // Determines active rate based on selection
    double activeRate = 0.0;
    if (ratesAsyncValue.hasValue) {
      final rates = ratesAsyncValue.value!;
      final isUsd = conversionState.currency == CurrencyType.usd;
      final isToday = conversionState.dateMode == RateDateMode.today;

      if (isUsd) {
        activeRate = isToday ? rates.usdToday : rates.usdTomorrow;
      } else {
        activeRate = isToday ? rates.eurToday : rates.eurTomorrow;
      }
    }

    ref.listen<ConversionState>(conversionProvider, (previous, next) {
      if (_foreignController.text != next.foreignValue) {
        _foreignController.text = next.foreignValue;
        _foreignController.selection = TextSelection.fromPosition(
          TextPosition(offset: _foreignController.text.length),
        );
      }
      if (_vesController.text != next.vesValue) {
        _vesController.text = next.vesValue;
        _vesController.selection = TextSelection.fromPosition(
          TextPosition(offset: _vesController.text.length),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Toggles Row
              _buildToggles(
                conversionState,
                ratesAsyncValue.value?.hasTomorrow ?? false,
              ),
              const SizedBox(height: 20),

              // 1. Exchange Rate Display Card
              _buildRateCard(ratesAsyncValue, conversionState),
              const SizedBox(height: 24),

              // 2. Main Conversion Area
              if (ratesAsyncValue.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppTheme.textAccent),
                )
              else if (ratesAsyncValue.hasError)
                const SizedBox.shrink()
              else
                _buildConversionCard(activeRate, conversionState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggles(ConversionState state, bool hasTomorrow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Currency Toggle
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildToggleButton(
                "USD",
                state.currency == CurrencyType.usd,
                () => ref
                    .read(conversionProvider.notifier)
                    .setCurrency(CurrencyType.usd),
              ),
              _buildToggleButton(
                "EUR",
                state.currency == CurrencyType.eur,
                () => ref
                    .read(conversionProvider.notifier)
                    .setCurrency(CurrencyType.eur),
              ),
            ],
          ),
        ),
        // Date Mode Toggle (Hoy / Mañana)
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildToggleButton(
                "Hoy",
                state.dateMode == RateDateMode.today,
                () => ref
                    .read(conversionProvider.notifier)
                    .setDateMode(RateDateMode.today),
              ),
              _buildToggleButton(
                "Mañana",
                state.dateMode == RateDateMode.tomorrow,
                hasTomorrow
                    ? () => ref
                          .read(conversionProvider.notifier)
                          .setDateMode(RateDateMode.tomorrow)
                    : null,
                showBadge: hasTomorrow,
                isDisabled: !hasTomorrow,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    String text,
    bool isSelected,
    VoidCallback? onTap, {
    bool showBadge = false,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color: isDisabled
                    ? AppTheme.textSubtle.withValues(alpha: 0.3)
                    : (isSelected ? Colors.white : AppTheme.textSubtle),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent, // O un color que resalte
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRateCard(
    AsyncValue<RatesData> ratesAsyncValue,
    ConversionState state,
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

              return RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "1 $symbol = ",
                      style: AppTheme.rateLabelStyle,
                    ),
                    TextSpan(
                      text: "${rate.toStringAsFixed(2)} VES",
                      style: AppTheme.rateStyle,
                    ),
                  ],
                ),
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

  Widget _buildConversionCard(double rate, ConversionState state) {
    final label = state.currency == CurrencyType.usd ? "USD" : "EUR";
    return Container(
      padding: const EdgeInsets.all(32),
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
          // Foreign Input
          _buildInputField(
            controller: _foreignController,
            label: label,
            placeholder: "Monto en $label",
            onChanged: (value) {
              ref.read(conversionProvider.notifier).updateForeign(value, rate);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Icon(
              Icons.swap_vert_rounded,
              color: AppTheme.textSubtle,
              size: 32,
            ),
          ),
          // VES Input
          _buildInputField(
            controller: _vesController,
            label: "VES",
            placeholder: "Equivalente en VES",
            onChanged: (value) {
              ref.read(conversionProvider.notifier).updateVES(value, rate);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.inputLabelStyle),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTheme.inputTextStyle,
            cursorColor: AppTheme.textAccent,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: AppTheme.textSubtle.withAlpha(128),
                fontSize: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
