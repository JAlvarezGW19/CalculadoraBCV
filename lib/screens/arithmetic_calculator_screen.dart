// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_toggles.dart';
import '../widgets/add_rate_dialog.dart';
import '../widgets/native_ad_widget.dart';

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

  // Formatters
  final NumberFormat _displayFormat = NumberFormat("#,##0.00", "es_VE");

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
          // Maybe clear result? Standard calc usually treats result as new entry to be edited.
          // But simpler: if backspace after equal, just reset.
          _expression = _result;
          _shouldResetExpression = false;
        } else if (_isOperator(key)) {
          // Continue calculation with result
          _expression = _result;
          _shouldResetExpression = false;
        } else if (key == '=') {
          // Repeat calculation? For now just do nothing or recalc
          _shouldResetExpression = false;
        } else {
          // Typed a number, start new
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
        if (_isOperator(key) &&
            _expression.isNotEmpty &&
            _isOperator(_expression[_expression.length - 1])) {
          _expression = _expression.substring(0, _expression.length - 1) + key;
        } else {
          _expression += key;
        }
        _calculateResult();
      }
    });
  }

  bool _isOperator(String key) {
    return key == '+' || key == '-' || key == '*' || key == '/';
  }

  void _calculateResult({bool finalCalculation = false}) {
    if (_expression.isEmpty) {
      return;
    }

    try {
      // Replace visual operators with math operators if needed
      String finalExpression = _expression
          .replaceAll('x', '*')
          .replaceAll('÷', '/');

      Parser p = ShuntingYardParser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      // Check for clean integer text if possible
      String resultStr = eval.toString();
      if (resultStr.endsWith(".0")) {
        resultStr = resultStr.substring(0, resultStr.length - 2);
      }

      setState(() {
        _result = resultStr;
        if (finalCalculation) {
          // Add to history
          _sessionHistory.add("$_expression = $_result");
          // Update expression to be the result (ANS behavior)
          _expression = _result;
          _shouldResetExpression = true;
        }
      });
    } catch (e) {
      // debugPrint("Error evaluating: $e");
    }
  }

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
                    // Show newest first? Or oldest? Newest usually at bottom of Calc logic.
                    // Let's reverse to show newest at top of list.
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
                          // Restore history item
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
    final customRates = ref.read(customRatesProvider);
    final state = ref.read(conversionProvider);

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Seleccionar Tasa", style: AppTheme.rateLabelStyle),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppTheme.textAccent,
                      ),
                      onPressed: () async {
                        Navigator.pop(context); // Close sheet
                        final newRate = await showAddEditRateDialog(
                          context,
                          ref,
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
                      final isSelected = rate.id == state.selectedCustomRateId;
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
                          "${NumberFormat("#,##0.00", "es_VE").format(rate.rate)} VES",
                          style: const TextStyle(
                            color: AppTheme.textSubtle,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                                color: AppTheme.textAccent,
                              )
                            : null,
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
  }

  double _getEffectiveRate(WidgetRef ref) {
    final ratesAsync = ref.read(ratesProvider);
    final state = ref.read(conversionProvider);
    final customRates = ref.read(customRatesProvider);

    double rate = 0.0;

    // Simplification for reading current rate synchronously
    // (Relies on provider having data, which is likely if loaded)
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

    // Calculate final display values
    double activeRate = _getEffectiveRate(ref);
    double rawMathValue = double.tryParse(_result) ?? 0.0;
    double finalConvertedValue = 0.0;

    if (activeRate > 0) {
      if (_isDivisaToBs) {
        // Foreign -> Bs
        finalConvertedValue = rawMathValue * activeRate;
      } else {
        // Bs -> Foreign
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

    // Generalized Formatter based on User Rules:
    // - Foreign ($/€) -> Prefix (e.g. "$50")
    // - Bs -> Suffix (e.g. "50 Bs")
    // - Custom -> Suffix (e.g. "50 USDT")
    String formatValue(
      double value,
      bool isBs,
      CurrencyType? type,
      String? customName,
    ) {
      String formattedValue = _displayFormat.format(value);

      if (isBs) {
        // Bs: Suffix (e.g. "14.422,47Bs")
        return "$formattedValue Bs";
      }

      if (type == CurrencyType.custom) {
        // Custom: Suffix (e.g. "20 USDT")
        return "$formattedValue ${customName ?? 'Pers.'}";
      }

      // Foreign Standard ($/€): Prefix (e.g. "$50")
      return "${_getCurrencySymbol(type!)}$formattedValue";
    }

    // Determine Source/Target Strings using the single consistent logic
    String sourceStr;
    String targetStr;

    // For the interactive input widget (Expression code)
    // User Request: All symbols/Bs in the input expression (white text) go to the RIGHT (Suffix).
    String inputPrefix = "";
    String inputSuffix = "";

    if (_isDivisaToBs) {
      // Source: Foreign/Custom
      if (state.currency == CurrencyType.custom) {
        inputSuffix = " ${customRateName ?? 'Pers.'}";
      } else {
        // Foreign Standard -> Suffix for Input Expression
        inputSuffix = " ${_getCurrencySymbol(state.currency)}";
      }
    } else {
      // Source: Bs -> Suffix
      inputSuffix = " Bs";
    }

    if (_isDivisaToBs) {
      // Source: Foreign/Custom -> Target: Bs
      sourceStr = formatValue(
        rawMathValue,
        false,
        state.currency,
        customRateName,
      );
      targetStr = formatValue(finalConvertedValue, true, null, null);
    } else {
      // Source: Bs -> Target: Foreign/Custom
      sourceStr = formatValue(rawMathValue, true, null, null);
      targetStr = formatValue(
        finalConvertedValue,
        false,
        state.currency,
        customRateName,
      );
    }

    // Main Display: "$50 = 14.422,47Bs"
    String mainDisplayText = "$sourceStr = $targetStr";

    // Calculate BCV Equivalent for Custom Mode
    double? bcvEquivalentValue;
    String bcvLabel = "";
    if (state.currency == CurrencyType.custom && ratesAsync.hasValue) {
      final rates = ratesAsync.value!;
      final isToday = state.dateMode == RateDateMode.today;
      double bcvRate = isToday ? rates.usdToday : rates.usdTomorrow;

      if (bcvRate > 0) {
        double totalBs = _isDivisaToBs
            ? (rawMathValue * activeRate)
            : rawMathValue;
        bcvEquivalentValue = totalBs / bcvRate;
        // BCV Equivalent always USD? "$100"
        bcvLabel = "BCV: \$${_displayFormat.format(bcvEquivalentValue)}";
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 34), // Match CalculatorScreen top padding
            // TOP SECTION: Toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Reduced
              child: CurrencyToggles(
                hasTomorrow: ratesAsync.value?.hasTomorrow ?? false,
                tomorrowDate: ratesAsync.value?.tomorrowDate,
              ),
            ),

            const SizedBox(height: 10),

            // MIDDLE SECTION: Display
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), // Reduced margin
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Row: Rate & Swap Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: state.currency == CurrencyType.custom
                                ? () => _showRateSelectionDialog(ref)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Tasa: ${_displayFormat.format(activeRate)}",
                                  style: AppTheme.subtitleStyle.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.textAccent,
                                  ),
                                ),
                                if (state.currency == CurrencyType.custom) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 16,
                                    color: AppTheme.textAccent,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Icons Row (Swap left, History right)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => setState(
                                () => _isDivisaToBs = !_isDivisaToBs,
                              ),
                              icon: const Icon(
                                Icons.swap_vert,
                                color: AppTheme.textSubtle,
                              ),
                              tooltip: "Cambiar dirección",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _showHistoryDialog,
                              icon: const Icon(
                                Icons.history,
                                color: AppTheme.textSubtle,
                              ),
                              tooltip: "Historial",
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Input Expression (Dynamic Prefix/Suffix)
                    Flexible(
                      flex: 1,
                      child: FittedBox(
                        alignment: Alignment.centerRight,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _expression.isEmpty
                              ? "0"
                              : "$inputPrefix$_expression$inputSuffix",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.montserrat(
                            color: AppTheme.textSubtle,
                            fontSize: 46,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Main Result
                    Expanded(
                      flex: 2,
                      child: FittedBox(
                        alignment: Alignment.centerRight,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          mainDisplayText,
                          style: GoogleFonts.montserrat(
                            color: AppTheme.textAccent,
                            fontSize: 70, // Slightly smaller base
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (bcvEquivalentValue != null && rawMathValue != 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        bcvLabel,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.montserrat(
                          color: AppTheme.textSubtle,
                          fontSize: 12, // Small font
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BOTTOM SECTION: Keypad
            Expanded(
              flex: 7, // Even larger keypad
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ), // Reduced margin
                child: Column(
                  children: [
                    _buildKeyRow(['C', '÷', '×', '⌫']),
                    Expanded(child: _buildKeyRow(['7', '8', '9', '-'])),
                    Expanded(child: _buildKeyRow(['4', '5', '6', '+'])),
                    Expanded(child: _buildKeyRow(['1', '2', '3', '='])),
                    Expanded(
                      child: _buildKeyRow(['', '0', '.', '']),
                    ), // 0 in second col to be under 2
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10), // Reduced margin above Ad

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const NativeAdWidget(assignedTabIndex: 1),
            ),
            const SizedBox(height: 20), // Reduced bottom margin to 20
          ],
        ),
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((key) {
          if (key.isEmpty) {
            return const Expanded(
              child: SizedBox.shrink(),
            ); // filler for special layout
          }

          // Special layout for '0' in last row to span 2 cols?
          // Simplified grid for now:

          bool isAction = ['C', '⌫'].contains(key);
          bool isOperator = ['÷', '×', '-', '+', '='].contains(key);

          Color bgColor = Colors.transparent;
          Color textColor = Colors.white;

          if (isAction) {
            textColor = Colors.orangeAccent;
          } else if (isOperator) {
            bgColor = AppTheme.cardBackground;
            textColor = AppTheme.textAccent;
            if (key == '=') {
              bgColor = AppTheme.textAccent;
              textColor = Colors.white;
            }
          }

          // Map display symbols to internal logic
          String val = key;
          if (key == '÷') {
            val = '/';
          }
          if (key == '×') {
            val = '*';
          }

          // Custom flex not needed if we follow standard grid.
          // Last row keys: ['', '0', '.', ''] -> 4 items.
          return Expanded(
            flex: 1,
            // Current list ['0', '.', ''] implies 0 is normal.
            // Let's adjust last row keys.
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _onKeyPressed(val),
                  child: Center(
                    child: isAction && key == '⌫'
                        ? const Icon(
                            Icons.backspace_outlined,
                            color: Colors.orangeAccent,
                          )
                        : Text(
                            key,
                            style: GoogleFonts.montserrat(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
