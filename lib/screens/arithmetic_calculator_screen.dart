import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ArithmeticCalculatorScreen extends StatelessWidget {
  const ArithmeticCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calculate, size: 64, color: AppTheme.textSubtle),
          const SizedBox(height: 16),
          Text("Calculadora Básica", style: AppTheme.subtitleStyle),
          const SizedBox(height: 8),
          const Text(
            "Próximamente disponible",
            style: TextStyle(color: AppTheme.textSubtle),
          ),
        ],
      ),
    );
  }
}
