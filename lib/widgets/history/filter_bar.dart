import 'package:flutter/material.dart';
import '../../providers/history_provider.dart';
import '../../theme/app_theme.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

class HistoryFilterBar extends StatelessWidget {
  final HistoryRange selectedRange;
  final Function(HistoryRange) onSelect;

  const HistoryFilterBar({
    super.key,
    required this.selectedRange,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(l10n.rangeWeek, HistoryRange.week), // "1 Sem"
          const SizedBox(width: 8),
          _buildChip(l10n.rangeMonth, HistoryRange.month), // "1 Mes"
          const SizedBox(width: 8),
          _buildChip(
            l10n.rangeThreeMonths,
            HistoryRange.threeMonths,
          ), // "3 Meses"
          const SizedBox(width: 8),
          _buildChip(l10n.rangeYear, HistoryRange.year), // "1 Año"
          const SizedBox(width: 8),
          _buildChip(
            l10n.rangeCustom,
            HistoryRange.custom,
            isIcon: true,
          ), // "Personalizado"
        ],
      ),
    );
  }

  Widget _buildChip(String label, HistoryRange range, {bool isIcon = false}) {
    final isSelected = selectedRange == range;
    return ChoiceChip(
      label: isIcon
          ? Row(
              children: [
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Text(label),
              ],
            )
          : Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(range),
      backgroundColor: AppTheme.cardBackground,
      selectedColor: AppTheme.textAccent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textSubtle,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.textAccent : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }
}
