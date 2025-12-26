import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/history_point.dart';
import '../../theme/app_theme.dart';

class HistoryListView extends StatelessWidget {
  final List<HistoryPoint> dataPoints;
  // Assume dataPoints are sorted ASCENDING (oldest to newest) from the provider?
  // Actually, usually charts need ASC sorted.
  // For List View, we prefer DESC (Newest first).

  const HistoryListView({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No hay datos",
            style: TextStyle(color: AppTheme.textSubtle),
          ),
        ),
      );
    }

    // Create a local reversed copy for display (Newest top)
    final reversedData = List<HistoryPoint>.from(dataPoints.reversed);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: reversedData.length,
        separatorBuilder: (ctx, i) => const Divider(color: Colors.white10),
        itemBuilder: (ctx, i) {
          final point = reversedData[i];
          final currentRate = point.rate;

          double? changePercent;

          // Compare with PREVIOUS day (which is i + 1 in this reversed list)
          if (i + 1 < reversedData.length) {
            final prevRate = reversedData[i + 1].rate;
            if (prevRate > 0) {
              changePercent = ((currentRate - prevRate) / prevRate) * 100;
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildDateBox(point.date),
                const SizedBox(width: 16),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${NumberFormat("#,##0.00", "es_VE").format(currentRate)} Bs",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildChangeBadge(changePercent),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateBox(DateTime date) {
    return Container(
      width: 55, // Fixed width for alignment
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('dd').format(date),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            DateFormat('MMM', 'es_VE').format(date).toUpperCase(),
            style: const TextStyle(color: AppTheme.textSubtle, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeBadge(double? percent) {
    if (percent == null) {
      return const Text("-", style: TextStyle(color: AppTheme.textSubtle));
    }

    final isPositive = percent >= 0;
    final color = isPositive ? AppTheme.textAccent : Colors.redAccent;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    // Low noise filter
    if (percent.abs() < 0.01) {
      return const Text(
        "0.00%",
        style: TextStyle(
          color: AppTheme.textSubtle,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            "${percent.abs().toStringAsFixed(2)}%",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
