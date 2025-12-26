import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class ConversionCard extends ConsumerStatefulWidget {
  final double activeRate;
  final CustomRate? customRate;
  final double? bcvCompRate;
  final DateTime? rateDate;

  const ConversionCard({
    super.key,
    required this.activeRate,
    this.customRate,
    this.bcvCompRate,
    this.rateDate,
  });

  @override
  ConsumerState<ConversionCard> createState() => _ConversionCardState();
}

class _ConversionCardState extends ConsumerState<ConversionCard> {
  final TextEditingController _foreignController = TextEditingController();
  final TextEditingController _vesController = TextEditingController();
  final FocusNode _foreignFocus = FocusNode();
  final FocusNode _vesFocus = FocusNode();

  @override
  void dispose() {
    _foreignController.dispose();
    _vesController.dispose();
    _foreignFocus.dispose();
    _vesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversionProvider);

    // Listener for State Updates to Controllers
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

    return _buildCardContent(
      widget.activeRate,
      state,
      widget.rateDate,
      widget.customRate,
      widget.bcvCompRate,
    );
  }

  Widget _buildCardContent(
    double rate,
    ConversionState state,
    DateTime? rateDate,
    CustomRate? customRate,
    double? bcvCompRate,
  ) {
    // Label & Prefix Logic
    String foreignLabel;
    String foreignPrefix;

    if (state.currency == CurrencyType.custom) {
      if (customRate != null) {
        foreignLabel = customRate.name;
      } else {
        foreignLabel = "Personalizada";
      }
      // No symbol for custom rates as requested
      foreignPrefix = "";
    } else {
      if (state.currency == CurrencyType.usd) {
        foreignLabel = "Dólares";
        foreignPrefix = "\$ ";
      } else {
        foreignLabel = "Euros";
        foreignPrefix = "€ ";
      }
    }

    // Determine Foreign Placeholder
    String foreignPlaceholder;
    if (state.currency == CurrencyType.usd) {
      foreignPlaceholder = "Monto en Dólares";
    } else if (state.currency == CurrencyType.eur) {
      foreignPlaceholder = "Monto en Euros";
    } else {
      // Custom
      if (customRate != null) {
        foreignPlaceholder = "Monto en ${customRate.name}";
      } else {
        foreignPlaceholder = "Monto en Personalizada";
      }
    }

    const String vesLabel = "Bolívares";
    const String vesPrefix = "Bs. ";

    // BCV Equivalence Logic (for Custom Rate mode)
    String? inputsHelper;
    String? resultsHelper;

    if (customRate != null && bcvCompRate != null && bcvCompRate > 0) {
      double val = double.tryParse(_foreignController.text) ?? 0.0;
      if (val > 0) {
        // Foreign Helper
        double totalVes = val * customRate.rate;
        double bcvPurchasingPower = totalVes / bcvCompRate;

        String symbol = state.comparisonBase == CurrencyType.usd ? "\$" : "€";
        inputsHelper =
            "$symbol ${NumberFormat("#,##0.00", "es_VE").format(bcvPurchasingPower)} (BCV)";
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
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
          // Header with Share Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.textSubtle),
                onPressed: () {
                  // Clear via provider which updates listeners which updates controllers
                  ref.read(conversionProvider.notifier).updateForeign("", rate);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.share, color: AppTheme.textSubtle),
                onPressed: () =>
                    _shareConversion(rate, state, rateDate, customRate),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          // Foreign Input
          _buildInputField(
            controller: _foreignController,
            focusNode: _foreignFocus,
            label: foreignLabel,
            placeholder: foreignPlaceholder,
            prefixText: foreignPrefix,
            onChanged: (value) {
              // validate with European format support
              final sanitized = value.replaceAll('.', '').replaceAll(',', '.');
              if (double.tryParse(sanitized) != null || value.isEmpty) {
                ref
                    .read(conversionProvider.notifier)
                    .updateForeign(value, rate);
              }
            },
            canCopy: true,
            helperText: inputsHelper,
            maxIntegerDigits: 10,
            maxDecimalDigits: 3,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Icon(
              Icons.swap_vert_rounded,
              color: AppTheme.textSubtle,
              size: 24,
            ),
          ),

          // VES Input
          _buildInputField(
            controller: _vesController,
            focusNode: _vesFocus,
            label: vesLabel,
            placeholder: "Monto en Bolívares",
            prefixText: vesPrefix,
            onChanged: (value) {
              final sanitized = value.replaceAll('.', '').replaceAll(',', '.');
              if (double.tryParse(sanitized) != null || value.isEmpty) {
                ref.read(conversionProvider.notifier).updateVES(value, rate);
              }
            },
            canCopy: true,
            helperText: resultsHelper,
            maxIntegerDigits: 12,
            maxDecimalDigits: 4,
          ),
        ],
      ),
    );
  }

  void _shareConversion(
    double rate,
    ConversionState state,
    DateTime? date,
    CustomRate? customRate,
  ) async {
    final foreignAmount = _foreignController.text;
    final vesAmount = _vesController.text;

    if (foreignAmount.isEmpty || vesAmount.isEmpty) return;

    String symbol = state.currency == CurrencyType.usd ? "\$" : "€";
    String rateName = "BCV";
    if (customRate != null) {
      symbol = customRate.name;
      rateName = customRate.name;
    }

    final formattedRate = NumberFormat("#,##0.00", "es_VE").format(rate);

    final msg =
        "El monto es $symbol$foreignAmount ($vesAmount Bs) | Tasa $rateName = $formattedRate Bs";

    try {
      final box = context.findRenderObject() as RenderBox?;
      // ignore: deprecated_member_use
      await Share.share(
        msg,
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (e) {
      debugPrint("Error sharing: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al compartir: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required Function(String) onChanged,
    FocusNode? focusNode,
    bool canCopy = false,
    String? helperText,
    String? prefixText,
    int maxIntegerDigits = 15,
    int maxDecimalDigits = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.inputLabelStyle),
            if (canCopy)
              GestureDetector(
                onTap: () {
                  if (controller.text.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: controller.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Copiado al portapapeles"),
                        duration: Duration(milliseconds: 1000),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.copy,
                    color: AppTheme.textSubtle,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTheme.inputTextStyle.copyWith(fontSize: 22),
                cursorColor: AppTheme.textAccent,
                inputFormatters: [
                  CurrencyInputFormatter(
                    maxIntegerDigits: maxIntegerDigits,
                    maxDecimalDigits: maxDecimalDigits,
                  ),
                ],
                onChanged: onChanged,
                scrollPadding: const EdgeInsets.only(bottom: 200),
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(
                    color: AppTheme.textSubtle.withValues(alpha: 0.5),
                    fontSize: 20,
                  ),
                  prefixIcon: prefixText != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20, right: 4),
                          child: Text(
                            prefixText,
                            style: AppTheme.inputTextStyle.copyWith(
                              color: AppTheme.textSubtle,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : null,
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                    left: prefixText != null ? 0 : 20,
                    right: 20,
                    top: 16,
                    bottom: helperText != null ? 4 : 16,
                  ),
                ),
              ),
              if (helperText != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 8,
                  ),
                  child: Text(
                    helperText,
                    style: TextStyle(
                      color: AppTheme.textSubtle.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
