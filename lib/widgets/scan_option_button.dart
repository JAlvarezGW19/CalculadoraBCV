import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScanOptionButton extends StatelessWidget {
  final String label;
  final String symbol;
  final Color color;
  final VoidCallback onTap;

  const ScanOptionButton({
    super.key,
    required this.label,
    required this.symbol,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2), // Updated for Flutter 3+
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              symbol,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
