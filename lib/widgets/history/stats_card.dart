import 'package:flutter/material.dart';
import '../../models/history_point.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class HistoryStatsCard extends StatelessWidget {
  final List<HistoryPoint> data;

  const HistoryStatsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final first = data.first.rate;
    final last = data.last.rate;
    final change = last - first;
    final percent = (change / first) * 100;

    final sortedRates = data.map((e) => e.rate).toList()..sort();
    final min = sortedRates.first;
    final max = sortedRates.last;

    // Average
    final avg = sortedRates.reduce((a, b) => a + b) / sortedRates.length;

    // Volatility (Standard Deviation) - Optional/Bonus

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Estadísticas del Periodo", style: AppTheme.subtitleStyle),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                "Cambio",
                "${percent.toStringAsFixed(2)}%",
                isPositive: percent >= 0,
                colored: true,
              ),
              _buildStatItem("Mínimo", _fmt(min)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Promedio", _fmt(avg)),
              _buildStatItem("Máximo", _fmt(max)),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double val) =>
      "${NumberFormat("#,##0.00", "es_VE").format(val)} Bs";

  Widget _buildStatItem(
    String label,
    String value, {
    bool colored = false,
    bool isPositive = true,
  }) {
    Color valColor = Colors.white;
    if (colored) {
      valColor = isPositive ? AppTheme.textAccent : Colors.redAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSubtle, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
