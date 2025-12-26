import 'package:flutter/material.dart';
import '../../providers/history_provider.dart';
import '../../theme/app_theme.dart';

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
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip("1 Sem", HistoryRange.week),
          const SizedBox(width: 8),
          _buildChip("1 Mes", HistoryRange.month),
          const SizedBox(width: 8),
          _buildChip("3 Meses", HistoryRange.threeMonths),
          const SizedBox(width: 8),
          _buildChip("1 Año", HistoryRange.year),
          const SizedBox(width: 8),
          _buildChip("Personalizado", HistoryRange.custom, isIcon: true),
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
