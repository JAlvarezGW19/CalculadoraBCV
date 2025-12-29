import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:calculadora_bcv/l10n/app_localizations.dart';

class CalculatorDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final String? bcvEquivalent;
  final String inputPrefix;
  final String inputSuffix;
  final VoidCallback onSwap;
  final VoidCallback onHistory;
  final VoidCallback? onRateClick;
  final String rateText;
  final bool showRateDropdown;
  final VoidCallback onToggleRounding;
  final bool isRoundingEnabled;

  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.bcvEquivalent,
    required this.inputPrefix,
    required this.inputSuffix,
    required this.onSwap,
    required this.onHistory,
    this.onRateClick,
    required this.rateText,
    this.showRateDropdown = false,
    required this.onToggleRounding,
    required this.isRoundingEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  onTap: onRateClick,
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.rateLabel}: $rateText",
                        style: AppTheme.subtitleStyle.copyWith(
                          fontSize: 12,
                          color: AppTheme.textAccent,
                        ),
                      ),
                      if (showRateDropdown) ...[
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

              // Icons Row (Rounding, Swap, History)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onToggleRounding,
                    icon: Icon(
                      Icons.code,
                      color: isRoundingEnabled
                          ? AppTheme.textSubtle
                          : AppTheme.textAccent,
                    ),
                    tooltip: "Alternar Redondeo",
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onSwap,
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
                    onPressed: onHistory,
                    icon: const Icon(Icons.history, color: AppTheme.textSubtle),
                    tooltip: "Historial",
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Input Expression
          Expanded(
            flex: 2,
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Text(
                expression.isEmpty
                    ? "0"
                    : "$inputPrefix$expression$inputSuffix",
                textAlign: TextAlign.right,
                style: GoogleFonts.montserrat(
                  color: AppTheme.textSubtle,
                  fontSize: 70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Main Result
          Expanded(
            flex: 3,
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Text(
                result,
                style: GoogleFonts.montserrat(
                  color: AppTheme.textAccent,
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (bcvEquivalent != null) ...[
            const SizedBox(height: 4),
            Text(
              bcvEquivalent!,
              textAlign: TextAlign.right,
              style: GoogleFonts.montserrat(
                color: AppTheme.textSubtle,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
