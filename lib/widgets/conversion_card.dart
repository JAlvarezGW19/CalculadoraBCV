import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    // Label & Prefix Logic
    String foreignLabel;
    String foreignPrefix;

    if (state.currency == CurrencyType.custom) {
      if (customRate != null) {
        foreignLabel = customRate.name;
      } else {
        foreignLabel = l10n.customRate; // "Personalizada" (or similar)
      }
      // No symbol for custom rates as requested
      foreignPrefix = "";
    } else {
      if (state.currency == CurrencyType.usd) {
        foreignLabel = l10n.usd;
        foreignPrefix = "\$ ";
      } else {
        foreignLabel = l10n.eur;
        foreignPrefix = "€ ";
      }
    }

    // Determine Foreign Placeholder
    String foreignPlaceholder;
    if (state.currency == CurrencyType.usd) {
      foreignPlaceholder = l10n.amountDollars;
    } else if (state.currency == CurrencyType.eur) {
      foreignPlaceholder = l10n.amountEuros;
    } else {
      // Custom
      if (customRate != null) {
        foreignPlaceholder = "${l10n.amountCustom} ${customRate.name}";
      } else {
        foreignPlaceholder = "${l10n.amountCustom} ${l10n.customRate}";
      }
    }

    final String vesLabel = l10n.ves; // "Bolívares"
    const String vesPrefix = "Bs. ";

    // BCV Equivalence Logic (for Custom Rate mode)
    Widget? inputsHelper;
    String? resultsHelper;

    if (customRate != null && bcvCompRate != null && bcvCompRate > 0) {
      String clean = _foreignController.text
          .replaceAll(RegExp(r'[^0-9,]'), '')
          .replaceAll(',', '.');
      double val = double.tryParse(clean) ?? 0.0;
      if (val > 0) {
        // Foreign Helper
        double totalVes = val * customRate.rate;
        double bcvPurchasingPower = totalVes / bcvCompRate;

        String symbol = state.comparisonBase == CurrencyType.usd ? "\$" : "€";

        inputsHelper = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$symbol ${NumberFormat("#,##0.00", "es_VE").format(bcvPurchasingPower)} (BCV)",
              style: TextStyle(
                color: AppTheme.textSubtle.withValues(alpha: 0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 6),
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

    // Calculate dynamic scroll padding based on keyboard height
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    const double approxBottomFieldHeight =
        170.0; // Height of input + swap button
    final double standardPadding = keyboardHeight + 20;
    final double topFieldPadding = standardPadding + approxBottomFieldHeight;

    // Determine padding based on position
    // If inverted: VES is Top, Foreign is Bottom
    // If normal: Foreign is Top, VES is Bottom
    final double foreignPadding = state.isInvertedOrder
        ? standardPadding
        : topFieldPadding;
    final double vesPadding = state.isInvertedOrder
        ? topFieldPadding
        : standardPadding;

    // Build Input Fields to facilitate swapping order
    final Widget foreignInput = _buildInputField(
      controller: _foreignController,
      focusNode: _foreignFocus,
      label: foreignLabel,
      placeholder: foreignPlaceholder,
      prefixText: foreignPrefix,
      onChanged: (value) {
        final sanitized = value
            .replaceAll(RegExp(r'[^0-9,]'), '')
            .replaceAll(',', '.');
        if (double.tryParse(sanitized) != null || value.isEmpty) {
          ref.read(conversionProvider.notifier).updateForeign(value, rate);
        }
      },
      canCopy: true,
      helperWidget: inputsHelper,
      maxIntegerDigits: 10,
      maxDecimalDigits: 3,
      scrollPaddingBottom: foreignPadding,
    );

    final Widget vesInput = _buildInputField(
      controller: _vesController,
      focusNode: _vesFocus,
      label: vesLabel,
      placeholder: l10n.amountBolivars,
      prefixText: vesPrefix,
      onChanged: (value) {
        final sanitized = value
            .replaceAll(RegExp(r'[^0-9,]'), '')
            .replaceAll(',', '.');
        if (double.tryParse(sanitized) != null || value.isEmpty) {
          ref.read(conversionProvider.notifier).updateVES(value, rate);
        }
      },
      canCopy: true,
      helperText: resultsHelper,
      maxIntegerDigits: 12,
      maxDecimalDigits: 4,
      scrollPaddingBottom: vesPadding,
    );

    final Widget swapButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: GestureDetector(
        onTap: () {
          ref.read(conversionProvider.notifier).toggleOrder();
        },
        child: const Icon(
          Icons.swap_vert_rounded,
          color: AppTheme.textSubtle,
          size: 24,
        ),
      ),
    );

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
              // Toggle Rounding
              IconButton(
                icon: Icon(
                  Icons.code,
                  color: state.isRoundingEnabled
                      ? AppTheme.textSubtle
                      : AppTheme.textAccent,
                ),
                onPressed: () {
                  ref.read(conversionProvider.notifier).toggleRounding();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
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

          // Inputs with configurable order
          if (state.isInvertedOrder) ...[
            vesInput,
            swapButton,
            foreignInput,
          ] else ...[
            foreignInput,
            swapButton,
            vesInput,
          ],
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
    final l10n = AppLocalizations.of(context)!;
    final foreignAmount = _foreignController.text;
    final vesAmount = _vesController.text;

    if (foreignAmount.isEmpty || vesAmount.isEmpty) return;

    String prefix = "";
    String suffix = "";
    String rateName = "Tasa BCV";

    if (state.currency == CurrencyType.usd) {
      prefix = "\$";
    } else if (state.currency == CurrencyType.eur) {
      prefix = "€";
    } else if (customRate != null) {
      suffix = " ${customRate.name}";
      rateName = customRate.name;
    }

    // Manual localization for the specific intro requested
    String intro;
    switch (Localizations.localeOf(context).languageCode) {
      case 'es':
        intro = "El monto es";
        break;
      case 'fr':
        intro = "Le montant est";
        break;
      case 'it':
        intro = "L'importo è";
        break;
      case 'pt':
        intro = "O valor é";
        break;
      case 'de':
        intro = "Der Betrag ist";
        break;
      case 'tr':
        intro = "Tutar";
        break;
      case 'ru':
        intro = "Сумма составляет";
        break;
      case 'ja':
        intro = "金額は";
        break;
      case 'zh':
        intro = "金额为";
        break;
      case 'ko':
        intro = "금액은";
        break;
      case 'ar':
        intro = "المبلغ هو";
        break;
      case 'hi':
        intro = "राशि है";
        break;
      case 'id':
        intro = "Jumlahnya adalah";
        break;
      case 'vi':
        intro = "Số tiền là";
        break;
      default:
        intro = "The amount is";
    }

    final formattedRate = NumberFormat("#,##0.00", "es_VE").format(rate);

    // Format: "El monto es $100 (5000,00 Bs.) | Tasa BCV = 45,00 Bs."
    final msg =
        "$intro $prefix$foreignAmount$suffix ($vesAmount Bs.) | $rateName = $formattedRate Bs.";

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
            content: Text("${l10n.shareError}: $e"),
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
    Widget? helperWidget,
    String? prefixText,
    int maxIntegerDigits = 15,
    int maxDecimalDigits = 2,
    double scrollPaddingBottom = 120,
  }) {
    final l10n = AppLocalizations.of(context)!;
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
                      SnackBar(
                        content: Text(l10n.copiedClipboard),
                        duration: const Duration(milliseconds: 1000),
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
                style: AppTheme.inputTextStyle.copyWith(fontSize: 26),
                cursorColor: AppTheme.textAccent,
                inputFormatters: [
                  CurrencyInputFormatter(
                    maxIntegerDigits: maxIntegerDigits,
                    maxDecimalDigits: maxDecimalDigits,
                  ),
                ],
                onChanged: onChanged,
                scrollPadding: EdgeInsets.only(bottom: scrollPaddingBottom),
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
                              fontSize: 22,
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
              if (helperWidget != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 8,
                  ),
                  child: helperWidget,
                )
              else if (helperText != null)
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
