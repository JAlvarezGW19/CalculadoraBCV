// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:calculadora_bcv/l10n/app_localizations.dart';
import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_toggles.dart';
import '../widgets/add_rate_dialog.dart';

import '../services/calculator_engine.dart';
import '../widgets/calculator/calculator_display.dart';
import '../widgets/calculator/calculator_keypad.dart';

class ArithmeticCalculatorScreen extends ConsumerStatefulWidget {
  final double? initialValue;

  const ArithmeticCalculatorScreen({super.key, this.initialValue});

  @override
  ConsumerState<ArithmeticCalculatorScreen> createState() =>
      _ArithmeticCalculatorScreenState();
}

class _ArithmeticCalculatorScreenState
    extends ConsumerState<ArithmeticCalculatorScreen> {
  String _expression = '';
  String _result = '0';
  bool _isDivisaToBs = true; // true: Divisa -> Bs, false: Bs -> Divisa

  // History
  final List<String> _sessionHistory = [];
  bool _shouldResetExpression = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _expression = widget.initialValue.toString();
      _calculateResult();
    }
  }

  void _onKeyPressed(String key) {
    setState(() {
      // Handle reset logic after calculation
      if (_shouldResetExpression) {
        if (key == 'C') {
          // Let standard C logic handle it
        } else if (key == '⌫') {
          _expression = _result;
          _shouldResetExpression = false;
        } else if (CalculatorEngine.isOperator(key)) {
          _expression = _result;
          _shouldResetExpression = false;
        } else if (key == '=') {
          _shouldResetExpression = false;
        } else {
          _expression = '';
          _result = '0';
          _shouldResetExpression = false;
        }
      }

      if (key == 'C') {
        _expression = '';
        _result = '0';
        _shouldResetExpression = false;
      } else if (key == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          if (_expression.isEmpty) {
            _result = '0';
          } else {
            _calculateResult();
          }
        }
      } else if (key == '=') {
        _calculateResult(finalCalculation: true);
      } else {
        // Prevent duplicate operators
        if (CalculatorEngine.isOperator(key) &&
            _expression.isNotEmpty &&
            CalculatorEngine.isOperator(_expression[_expression.length - 1])) {
          _expression = _expression.substring(0, _expression.length - 1) + key;
        } else {
          // Normalize Decimal Separator
          String valueToAppend = key;
          if (key == ',') {
            valueToAppend = '.';
          }
          _expression += valueToAppend;
        }
        _calculateResult();
      }
    });
  }

  void _calculateResult({bool finalCalculation = false}) {
    if (_expression.isEmpty) {
      return;
    }

    double eval = CalculatorEngine.evaluate(_expression);

    if (eval.isNaN) return;

    String resultStr = CalculatorEngine.formatResult(eval);

    setState(() {
      _result = resultStr;
      if (finalCalculation) {
        _sessionHistory.add("$_expression = $_result");
        _expression = _result;
        _shouldResetExpression = true;
      }
    });
  }

  // DIALOGS

  void _showHistoryDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Historial de Sesión",
                  style: AppTheme.rateLabelStyle,
                ),
              ),
              const Divider(color: AppTheme.textSubtle),
              if (_sessionHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "No hay cálculos recientes.",
                    style: TextStyle(color: AppTheme.textSubtle),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _sessionHistory.length,
                    itemBuilder: (context, index) {
                      final item =
                          _sessionHistory[_sessionHistory.length - 1 - index];
                      return ListTile(
                        title: Text(
                          item,
                          style: GoogleFonts.montserrat(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          final parts = item.split(' = ');
                          if (parts.length >= 2) {
                            setState(() {
                              _expression = parts[0];
                              _calculateResult();
                              _shouldResetExpression = false;
                            });
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showRateSelectionDialog(WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (consumerContext, sheetRef, child) {
            final customRates = sheetRef.watch(customRatesProvider);
            final state = sheetRef.watch(conversionProvider);

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(consumerContext)!.selectRate,
                          style: AppTheme.rateLabelStyle,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppTheme.textAccent,
                          ),
                          onPressed: () async {
                            Navigator.pop(sheetContext); // Close sheet

                            if (!mounted) return;

                            final newRate = await showAddEditRateDialog(
                              context,
                              ref, // Use the outer ref (from method argument), which is stable
                            );
                            if (newRate != null && mounted) {
                              ref
                                  .read(conversionProvider.notifier)
                                  .setSelectedCustomRate(newRate.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppTheme.textSubtle),
                  if (customRates.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        "No hay tasas personalizadas.\nAgrega una nueva.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSubtle),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: customRates.length,
                        itemBuilder: (context, index) {
                          final rate = customRates[index];
                          final isSelected =
                              rate.id == state.selectedCustomRateId;
                          return ListTile(
                            leading: Icon(
                              Icons.monetization_on_outlined,
                              color: isSelected
                                  ? AppTheme.textAccent
                                  : AppTheme.textSubtle,
                            ),
                            title: Text(
                              rate.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              "${NumberFormat("#,##0.00", "es_VE").format(rate.rate)} Bs.",
                              style: const TextStyle(
                                color: AppTheme.textSubtle,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: AppTheme.textSubtle,
                                  ),
                                  onPressed: () {
                                    showAddEditRateDialog(
                                      context,
                                      ref,
                                      rate: rate,
                                    );
                                  },
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: AppTheme.textAccent,
                                  ),
                              ],
                            ),
                            onTap: () {
                              ref
                                  .read(conversionProvider.notifier)
                                  .setSelectedCustomRate(rate.id);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // LOGIC HELPERS
  double _getEffectiveRate(WidgetRef ref) {
    final ratesAsync = ref.read(ratesProvider);
    final state = ref.read(conversionProvider);
    final customRates = ref.read(customRatesProvider);

    double rate = 0.0;

    if (ratesAsync.hasValue) {
      final rates = ratesAsync.value!;
      final isToday = state.dateMode == RateDateMode.today;

      if (state.currency == CurrencyType.custom) {
        if (customRates.isNotEmpty && state.selectedCustomRateId != null) {
          final cr = customRates.firstWhere(
            (r) => r.id == state.selectedCustomRateId,
            orElse: () => customRates.first,
          );
          rate = cr.rate;
        }
      } else if (state.currency == CurrencyType.usd) {
        rate = isToday ? rates.usdToday : rates.usdTomorrow;
      } else {
        rate = isToday ? rates.eurToday : rates.eurTomorrow;
      }
    }
    return rate;
  }

  String _formatExpressionDisplay(String expression) {
    if (expression.isEmpty) return "";

    // Regex to find numbers (integer or decimal)
    // Matches: 123, 123.456, .456
    // We want to capture them and format them
    return expression.replaceAllMapped(RegExp(r'(\d*\.?\d+)'), (match) {
      String numberStr = match.group(0)!;

      // If it's just ".", leave it (or handle as "0,")?
      if (numberStr == '.') return ',';

      // Split by dot
      List<String> parts = numberStr.split('.');
      String integerPart = parts[0];
      String decimalPart = parts.length > 1 ? parts[1] : '';
      bool hasDecimal = parts.length > 1;

      // Format Integer Part
      String formattedInteger = "";
      if (integerPart.isNotEmpty) {
        try {
          // Identify if we have very large ints?
          // Standard int.parse handles decent size.
          // Or use naive chunks of 3.
          // Let's use NumberFormat for safety, but check overflow?
          // If purely string manipulation:
          final buffer = StringBuffer();
          int count = 0;
          for (int i = integerPart.length - 1; i >= 0; i--) {
            buffer.write(integerPart[i]);
            count++;
            if (count % 3 == 0 && i > 0) {
              buffer.write('.');
            }
          }
          formattedInteger = buffer.toString().split('').reversed.join('');
        } catch (_) {
          formattedInteger = integerPart;
        }
      }

      if (hasDecimal) {
        return "$formattedInteger,$decimalPart";
      } else {
        return formattedInteger;
      }
    });
  }

  String _getCurrencySymbol(CurrencyType type, [String? customName]) {
    switch (type) {
      case CurrencyType.usd:
        return "\$";
      case CurrencyType.eur:
        return "€";
      case CurrencyType.custom:
        return customName ?? "Pers.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratesAsync = ref.watch(ratesProvider);
    final state = ref.watch(conversionProvider);

    // Dynamic formatter based on rounding preference
    final formatter = state.isRoundingEnabled
        ? NumberFormat("#,##0.00", "es_VE")
        : NumberFormat("#,##0.########", "es_VE");

    // Calculate final display values
    double activeRate = _getEffectiveRate(ref);
    double rawMathValue = double.tryParse(_result) ?? 0.0;
    double finalConvertedValue = 0.0;

    if (activeRate > 0) {
      if (_isDivisaToBs) {
        finalConvertedValue = rawMathValue * activeRate;
      } else {
        finalConvertedValue = rawMathValue / activeRate;
      }
    }

    // Get custom rate name if applicable
    String? customRateName;
    if (state.currency == CurrencyType.custom) {
      final customRates = ref.watch(customRatesProvider);
      if (customRates.isNotEmpty && state.selectedCustomRateId != null) {
        final cr = customRates.firstWhere(
          (r) => r.id == state.selectedCustomRateId,
          orElse: () => customRates.first,
        );
        customRateName = cr.name;
      }
    }

    // --- Formatting Logic ---

    String formatValue(
      double value,
      bool isBs,
      CurrencyType? type,
      String? customName,
    ) {
      String formattedValue = formatter.format(value);

      if (isBs) {
        return "$formattedValue Bs";
      }

      if (type == CurrencyType.custom) {
        return "$formattedValue ${customName ?? 'Pers.'}";
      }

      return "${_getCurrencySymbol(type!)}$formattedValue";
    }

    // For the interactive input widget
    String inputPrefix = "";
    String inputSuffix = "";

    if (_isDivisaToBs) {
      // Divisa -> Bs: Show currency symbol as suffix
      if (state.currency == CurrencyType.custom) {
        inputSuffix = " ${customRateName ?? 'Pers.'}";
      } else {
        inputSuffix = " ${_getCurrencySymbol(state.currency)}";
      }
    } else {
      // Bs -> Divisa: Show Bs as suffix
      inputSuffix = " Bs";
    }

    String mainDisplayText;
    String sourceStr = "";
    String targetStr = "";

    if (_isDivisaToBs) {
      // Source: Foreign -> Target: Bs
      sourceStr = formatValue(
        rawMathValue,
        false,
        state.currency,
        customRateName,
      );
      targetStr = formatValue(finalConvertedValue, true, null, null);
      mainDisplayText = "$sourceStr = $targetStr";
    } else {
      // Source: Bs -> Target: Foreign
      sourceStr = formatValue(rawMathValue, true, null, null);
      targetStr = formatValue(
        finalConvertedValue,
        false,
        state.currency,
        customRateName,
      );
      mainDisplayText = "$sourceStr = $targetStr";
    }

    // BCV Equivalent Logic
    // BCV Equivalent Logic
    Widget? bcvLabel;
    if (state.currency == CurrencyType.custom && ratesAsync.hasValue) {
      final rates = ratesAsync.value!;

      // Determine effective use of Tomorrow based on User Selection (State)
      final isToday = state.dateMode == RateDateMode.today;
      final useTom = !isToday && rates.hasTomorrow;

      double bcvRate;
      String symbol;

      if (state.comparisonBase == CurrencyType.usd) {
        bcvRate = useTom ? rates.usdTomorrow : rates.usdToday;
        symbol = "\$";
      } else {
        bcvRate = useTom ? rates.eurTomorrow : rates.eurToday;
        symbol = "€";
      }

      if (bcvRate > 0) {
        double totalBs = _isDivisaToBs
            ? (rawMathValue * activeRate)
            : rawMathValue;
        double bcvEquivalentValue = totalBs / bcvRate;

        bcvLabel = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "BCV: $symbol${formatter.format(bcvEquivalentValue)}",
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                color: AppTheme.textSubtle,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final newBase = state.comparisonBase == CurrencyType.usd
                    ? CurrencyType.eur
                    : CurrencyType.usd;
                ref
                    .read(conversionProvider.notifier)
                    .setComparisonBase(newBase);
              },
              child: const Icon(
                Icons.swap_horiz,
                color: AppTheme.textSubtle,
                size: 18,
              ),
            ),
          ],
        );
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top margin matching Home's padding (34 as requested in ID 241)
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: CurrencyToggles(
                hasTomorrow: ratesAsync.value?.hasTomorrow ?? false,
                tomorrowDate: ratesAsync.value?.tomorrowDate,
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              flex: 7,
              child: CalculatorDisplay(
                expression: _formatExpressionDisplay(_expression),
                result: mainDisplayText,
                bcvEquivalent: bcvLabel,
                inputPrefix: inputPrefix,
                inputSuffix: inputSuffix,
                onSwap: () => setState(() => _isDivisaToBs = !_isDivisaToBs),
                onHistory: _showHistoryDialog,
                onPaste: (text) {
                  setState(() {
                    _expression = _expression + text;
                  });
                },
                onRateClick: state.currency == CurrencyType.custom
                    ? () => _showRateSelectionDialog(ref)
                    : null,
                rateText: formatter.format(activeRate),
                showRateDropdown: state.currency == CurrencyType.custom,
                onToggleRounding: () =>
                    ref.read(conversionProvider.notifier).toggleRounding(),
                isRoundingEnabled: state.isRoundingEnabled,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              flex: 11, // Matching the last user edit in ID 242
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CalculatorKeypad(onKeyPressed: _onKeyPressed),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
