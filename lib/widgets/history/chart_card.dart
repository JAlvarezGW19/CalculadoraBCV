import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/history_point.dart';
import '../../theme/app_theme.dart';

class HistoryChartCard extends StatelessWidget {
  final List<HistoryPoint> dataPoints;
  final bool isLoading;
  final String currencySymbol;

  const HistoryChartCard({
    super.key,
    required this.dataPoints,
    required this.isLoading,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.textAccent),
        ),
      );
    }

    if (dataPoints.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: Text(
            "No hay datos disponibles",
            style: TextStyle(color: AppTheme.textSubtle),
          ),
        ),
      );
    }

    return Container(
      height: 350,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LineChart(_mainData()),
    );
  }

  LineChartData _mainData() {
    if (dataPoints.isEmpty) return LineChartData();

    // Normalization logic
    final firstDateMs = dataPoints.first.date.millisecondsSinceEpoch;
    final lastDateMs = dataPoints.last.date.millisecondsSinceEpoch;
    final diffMs = (lastDateMs - firstDateMs).toDouble();

    // Helper to map X (0..3) back to Date
    DateTime getDateFromValue(double value) {
      if (diffMs == 0) return dataPoints.first.date;
      final ms = firstDateMs + (value / 3.0 * diffMs).toInt();
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }

    // 1. Prepare Spots (Mapped 0..3)
    final spots = dataPoints.map((e) {
      final ms = e.date.millisecondsSinceEpoch;
      final x = diffMs == 0 ? 0.0 : (ms - firstDateMs) / diffMs * 3.0;
      return FlSpot(x, e.rate);
    }).toList();

    // 2. Min/Max Y
    double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double rangeY = maxY - minY;

    // Add buffer
    minY -= rangeY * 0.1;
    maxY += rangeY * 0.1;
    if (minY < 0) minY = 0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: rangeY == 0 ? 1 : rangeY / 5,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Colors.white10, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1.0, // Exactly 1.0 step for 0, 1, 2, 3
            getTitlesWidget: (value, meta) {
              // Only show valid integer steps 0, 1, 2, 3
              if (value % 1 != 0) return const SizedBox.shrink();

              final date = getDateFromValue(value);
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Transform.rotate(
                  angle: -0.5,
                  child: Text(
                    DateFormat('dd/MM/yy').format(date),
                    style: const TextStyle(
                      color: AppTheme.textSubtle,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget:
                leftTitleWidgets, // Keeping existing logic or move inline? Existing is fine if pure
            reservedSize: 45,
            interval: rangeY == 0 ? 1 : rangeY / 5,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 3, // Normalized 0 to 3
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppTheme.textAccent,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.textAccent.withValues(alpha: 0.3),
                AppTheme.textAccent.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final date = getDateFromValue(touchedSpot.x);
              final dateStr = DateFormat('dd/MM/yy').format(date);
              return LineTooltipItem(
                '$dateStr\n',
                const TextStyle(color: AppTheme.textSubtle, fontSize: 12),
                children: [
                  TextSpan(
                    text:
                        "${NumberFormat("#,##0.00", "es_VE").format(touchedSpot.y)} Bs",
                    style: const TextStyle(
                      color: AppTheme.textAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          // Adjust tooltip styling if needed
          getTooltipColor: (_) => AppTheme.cardBackground,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (value == meta.min || value == meta.max) return const SizedBox.shrink();

    return Text(
      "${NumberFormat.compact(locale: "es_VE").format(value)} ${currencySymbol == 'USD' ? '\$' : '€'}",
      style: const TextStyle(color: AppTheme.textSubtle, fontSize: 10),
      textAlign: TextAlign.left,
    );
  }
}
