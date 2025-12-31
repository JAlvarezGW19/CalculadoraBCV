import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart'
    show BuildContext, ScaffoldMessenger, SnackBar, Text, Colors, Localizations;
import 'package:calculadora_bcv/l10n/app_localizations.dart';
import '../models/history_point.dart';
import '../providers/bcv_provider.dart';

class PdfExportService {
  static Future<void> exportPdf({
    required BuildContext context,
    required List<HistoryPoint> data,
    required CurrencyType selectedCurrency,
    required String headerTitle,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final doc = pw.Document();
      // Determine font based on locale to support specific characters
      final locale = Localizations.localeOf(context);
      final langCode = locale.languageCode;

      // Load Latin fonts (Montserrat) as the universal fallback for numbers/dates
      final latinFont = await PdfGoogleFonts.montserratRegular();
      final latinBoldFont = await PdfGoogleFonts.montserratBold();

      pw.Font contentFont = latinFont;
      pw.Font contentBoldFont = latinBoldFont;
      List<pw.Font> fallbacks = [];

      // Determine content text direction
      pw.TextDirection textDirection = pw.TextDirection.ltr;

      // Select specific font based on language
      if (langCode == 'zh') {
        contentFont = await PdfGoogleFonts.notoSansSCRegular();
        contentBoldFont = await PdfGoogleFonts.notoSansSCBold();
        fallbacks = [latinFont];
      } else if (langCode == 'ja') {
        contentFont = await PdfGoogleFonts.notoSansJPRegular();
        contentBoldFont = await PdfGoogleFonts.notoSansJPBold();
        fallbacks = [latinFont];
      } else if (langCode == 'ko') {
        contentFont = await PdfGoogleFonts.notoSansKRRegular();
        contentBoldFont = await PdfGoogleFonts.notoSansKRBold();
        fallbacks = [latinFont];
      } else if (langCode == 'ar') {
        contentFont = await PdfGoogleFonts.notoSansArabicRegular();
        contentBoldFont = await PdfGoogleFonts.notoSansArabicBold();
        fallbacks = [latinFont];
        textDirection = pw.TextDirection.rtl;
      } else if (langCode == 'ru' || langCode == 'vi' || langCode == 'tr') {
        // Roboto covers Cyrillic, Vietnamese, Turkish well
        contentFont = await PdfGoogleFonts.robotoRegular();
        contentBoldFont = await PdfGoogleFonts.robotoBold();
        fallbacks = [latinFont];
      } else {
        // Default for Latin languages, use Montserrat directly
        contentFont = latinFont;
        contentBoldFont = latinBoldFont;
      }

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: contentFont,
            bold: contentBoldFont,
            fontFallback: fallbacks,
          ),
          textDirection: textDirection,
          build: (pw.Context context) {
            // Stats Calculation
            final sorted = data.map((e) => e.rate).toList()..sort();
            final first = data.first.rate;
            final last = data.last.rate;
            final change = last - first;
            final percent = (change / first) * 100;
            final min = sorted.first;
            final max = sorted.last;
            final avg = sorted.reduce((a, b) => a + b) / sorted.length;

            final currencySymbol = selectedCurrency == CurrencyType.usd
                ? 'USD'
                : 'EUR';

            final minDataDate = data.first.date;
            final maxDataDate = data.last.date;
            final startDateStr = DateFormat('dd/MM/yyyy').format(minDataDate);
            final endDateStr = DateFormat('dd/MM/yyyy').format(maxDataDate);

            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      headerTitle,
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
                "${l10n.pdfCurrency}: $currencySymbol | ${l10n.pdfRange}: $startDateStr - $endDateStr",
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),

              // Stats Box
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
                      l10n.pdfChangePercent, // Use new localized key
                      "${percent.toStringAsFixed(2)}%",
                      isPositive: percent >= 0,
                    ),
                    _buildPdfStat(l10n.min, "${_fmt(min)} Bs"),
                    _buildPdfStat(l10n.max, "${_fmt(max)} Bs"),
                    _buildPdfStat(l10n.mean, "${_fmt(avg)} Bs"),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Data Table
              pw.Text(
                l10n.pdfDailyDetails, // Localized
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.TableHelper.fromTextArray(
                headers: [
                  l10n.pdfDate,
                  l10n.pdfRate,
                  l10n.pdfChangePercent,
                ], // Localized headers
                data: _buildPdfTableData(data.reversed.toList()),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${l10n.pdfError}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static String _fmt(double val) =>
      NumberFormat("#,##0.00", "es_VE").format(val);

  static pw.Widget _buildPdfStat(
    String label,
    String val, {
    bool isPositive = true,
  }) {
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
            color: label == "Change" || label == "Cambio"
                ? (isPositive ? PdfColors.green700 : PdfColors.red700)
                : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static List<List<String>> _buildPdfTableData(List<HistoryPoint> points) {
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
}
