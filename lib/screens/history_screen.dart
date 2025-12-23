import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64, color: AppTheme.textSubtle),
          const SizedBox(height: 16),
          Text("Historial", style: AppTheme.subtitleStyle),
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
