import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  final ValueChanged<int> onTap;

  const BottomNavItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.iconOutlined,
    required this.iconFilled,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? iconFilled : iconOutlined,
              color: isSelected ? AppTheme.textAccent : AppTheme.textSubtle,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.textAccent : AppTheme.textSubtle,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
