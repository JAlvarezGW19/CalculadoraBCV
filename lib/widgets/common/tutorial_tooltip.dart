import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TutorialTooltip extends StatelessWidget {
  final String title;
  final String description;
  final int step;
  final int totalSteps;
  final VoidCallback? onFinished;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const TutorialTooltip({
    super.key,
    required this.title,
    required this.description,
    required this.step,
    required this.totalSteps,
    this.onFinished,
    this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      width: 280,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Auto height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Steps
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.textAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$step/$totalSteps",
                    style: const TextStyle(
                      color: AppTheme.textAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (step < totalSteps) ...[
                  // SKIP Button
                  TextButton(
                    onPressed: onSkip,
                    child: const Text(
                      "Omitir",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // NEXT Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onNext,
                    child: const Text(
                      "Siguiente",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ] else ...[
                  // FINISH Button (Last Step)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onFinished,
                    child: const Text(
                      "Finalizar",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
