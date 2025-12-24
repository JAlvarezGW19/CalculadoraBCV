import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesAsync = ref.watch(ratesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tasas del Banco Central", style: AppTheme.subtitleStyle),
          const SizedBox(height: 16),
          ratesAsync.when(
            data: (rates) {
              final hasTomorrow = rates.hasTomorrow;
              final dateStr = rates.todayDate != null
                  ? DateFormat('dd/MM/yyyy').format(rates.todayDate!)
                  : "---";

              return Column(
                children: [
                  _buildRateRow(
                    "Dólar (USD)",
                    rates.usdToday,
                    rates.usdTomorrow,
                    hasTomorrow,
                    "\$",
                    dateStr,
                  ),
                  const SizedBox(height: 16),
                  _buildRateRow(
                    "Euro (EUR)",
                    rates.eurToday,
                    rates.eurTomorrow,
                    hasTomorrow,
                    "€",
                    dateStr,
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.textAccent),
            ),
            error: (err, stack) => const Text(
              "Error cargando tasas",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(
    String title,
    double today,
    double tomorrow,
    bool hasTomorrow,
    String symbol,
    String dateStr,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTheme.inputLabelStyle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard("Hoy", today, symbol, dateStr, false),
            ),
            if (hasTomorrow) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  "Mañana",
                  tomorrow,
                  symbol,
                  "Próxima",
                  true,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    double value,
    String symbol,
    String dateInfo,
    bool isTomorrow,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: isTomorrow
            ? Border.all(color: AppTheme.textAccent.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTomorrow ? AppTheme.textAccent : AppTheme.textSubtle,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$symbol ${NumberFormat("#,##0.00", "es_VE").format(value)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Bs.",
            style: TextStyle(
              color: AppTheme.textSubtle.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
