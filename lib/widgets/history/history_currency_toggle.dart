import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../providers/bcv_provider.dart';

class HistoryCurrencyToggle extends StatelessWidget {
  final CurrencyType type;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const HistoryCurrencyToggle({
    super.key,
    required this.type,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textAccent : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.white10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSubtle,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
