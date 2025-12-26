import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/history_point.dart'; // Explicit import
import '../providers/history_provider.dart';
import '../providers/bcv_provider.dart'; // For CurrencyType
import '../theme/app_theme.dart';
import '../widgets/history/chart_card.dart';
import '../widgets/history/custom_date_range_picker.dart';
import '../widgets/history/filter_bar.dart';
import '../widgets/history/history_list_view.dart';
import '../widgets/history/stats_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(historyProvider.notifier).loadHistory();
    });
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final state = ref.read(historyProvider);

    // Default initial range: 1 week ago
    // If stored custom date is valid (>= Oct 2021), use it. Otherwise reset to recent.
    final minDate = DateTime(2021, 10, 1);

    DateTime initStart;
    if (state.customStartDate != null &&
        !state.customStartDate!.isBefore(minDate)) {
      initStart = state.customStartDate!;
    } else {
      initStart = now.subtract(const Duration(days: 7));
      // Ensure default week ago isn't before minDate (unlikely for 2025 vs 2021)
      if (initStart.isBefore(minDate)) initStart = minDate;
    }

    DateTime initEnd = state.customEndDate ?? now;
    if (initEnd.isBefore(initStart)) initEnd = initStart;

    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => CustomDateRangePicker(
        initialStartDate: initStart,
        initialEndDate: initEnd,
        firstDate: minDate,
        lastDate: now,
      ),
    );

    if (result != null) {
      ref
          .read(historyProvider.notifier)
          .setRange(HistoryRange.custom, start: result.start, end: result.end);
    }
  }

  Future<void> _exportPdf() async {
    final state = ref.read(historyProvider);
    if (state.data.isEmpty) return;

    // Safely handling PDF generation
    try {
      final doc = pw.Document();
      // Use standard fonts to avoid network crash risks if offline
      // Or bundle a font? We'll use standard helvetica for reliability now.
      // If user REALLY wants custom font in PDF, we can try, but standard is safer against crashes.

      final font = await PdfGoogleFonts.montserratRegular();
      final boldFont = await PdfGoogleFonts.montserratBold();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
          build: (pw.Context context) {
            // Calculate Stats for PDF
            final first = state.data.first.rate;
            final last = state.data.last.rate;
            final change = last - first;
            final percent = (change / first) * 100;
            final sorted = state.data.map((e) => e.rate).toList()..sort();
            final min = sorted.first;
            final max = sorted.last;
            final avg = sorted.reduce((a, b) => a + b) / sorted.length;

            final currency = state.selectedCurrency == CurrencyType.usd
                ? 'USD'
                : 'EUR';

            final minDataDate = state.data.first.date;
            final maxDataDate = state.data.last.date;
            final startDateStr = DateFormat('dd/MM/yyyy').format(minDataDate);
            final endDateStr = DateFormat('dd/MM/yyyy').format(maxDataDate);

            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Historial de Precios BCV",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                "Moneda: ${currency == 'USD' ? 'Dólar (USD)' : 'Euro (EUR)'} | Rango: $startDateStr - $endDateStr",
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),

              // PDF Stats Box
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPdfStat(
                      "Cambio",
                      "${percent.toStringAsFixed(2)}%",
                      isPositive: percent >= 0,
                    ),
                    _buildPdfStat("Mínimo", "${_fmt(min)} Bs"),
                    _buildPdfStat("Máximo", "${_fmt(max)} Bs"),
                    _buildPdfStat("Promedio", "${_fmt(avg)} Bs"),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Data Table
              pw.Text(
                "Detalle Diario (Orden Cronológico Inverso)",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.TableHelper.fromTextArray(
                headers: ['Fecha', 'Tasa (Bs)', 'Cambio % (vs Prev)'],
                data: _buildPdfTableData(state.data.reversed.toList()),
                border: null,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(5),
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'historial_bcv.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al generar PDF: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _fmt(double val) => NumberFormat("#,##0.00", "es_VE").format(val);

  pw.Widget _buildPdfStat(String label, String val, {bool isPositive = true}) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Text(
          val,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: label == "Cambio"
                ? (isPositive ? PdfColors.green700 : PdfColors.red700)
                : PdfColors.black,
          ),
        ),
      ],
    );
  }

  List<List<String>> _buildPdfTableData(List<HistoryPoint> points) {
    List<List<String>> rows = [];
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      String changeStr = "-";

      if (i + 1 < points.length) {
        final prev = points[i + 1].rate;
        if (prev > 0) {
          final pct = ((p.rate - prev) / prev) * 100;
          changeStr = "${pct > 0 ? '+' : ''}${pct.toStringAsFixed(2)}%";
        }
      }

      rows.add([
        DateFormat('dd/MM/yyyy').format(p.date),
        "${_fmt(p.rate)} Bs",
        changeStr,
      ]);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Historial",
                    style: AppTheme.subtitleStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: state.data.isEmpty ? null : _exportPdf,
                    icon: const Icon(
                      Icons.picture_as_pdf,
                      color: AppTheme.textAccent,
                    ),
                    tooltip: "Exportar PDF",
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Currency Toggle
              Row(
                children: [
                  _buildCurrencyToggle(
                    CurrencyType.usd,
                    "USD",
                    state.selectedCurrency == CurrencyType.usd,
                  ),
                  const SizedBox(width: 12),
                  _buildCurrencyToggle(
                    CurrencyType.eur,
                    "EUR",
                    state.selectedCurrency == CurrencyType.eur,
                  ),
                  const Spacer(),
                  // View Toggle
                  IconButton(
                    onPressed: () =>
                        ref.read(historyProvider.notifier).toggleViewMode(),
                    icon: Icon(
                      state.viewMode == HistoryViewMode.chart
                          ? Icons.list
                          : Icons.show_chart,
                      color: Colors.white,
                    ),
                    tooltip: state.viewMode == HistoryViewMode.chart
                        ? "Ver Lista"
                        : "Ver Gráfico",
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Bar
              HistoryFilterBar(
                selectedRange: state.selectedRange,
                onSelect: (range) {
                  if (range == HistoryRange.custom) {
                    _selectDateRange();
                  } else {
                    ref.read(historyProvider.notifier).setRange(range);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Content Switch
              _buildContent(state),

              const SizedBox(height: 20),

              // Stats (Show always if data exists)
              if (state.data.isNotEmpty) HistoryStatsCard(data: state.data),

              const SizedBox(height: 80), // Fab space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HistoryState state) {
    if (state.isLoading) {
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

    if (state.data.isEmpty) {
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

    if (state.viewMode == HistoryViewMode.chart) {
      return HistoryChartCard(
        dataPoints: state.data,
        isLoading: false,
        currencySymbol: state.selectedCurrency == CurrencyType.usd
            ? "USD"
            : "EUR",
      );
    } else {
      return HistoryListView(dataPoints: state.data);
    }
  }

  Widget _buildCurrencyToggle(
    CurrencyType type,
    String label,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(historyProvider.notifier).setCurrency(type);
      },
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
