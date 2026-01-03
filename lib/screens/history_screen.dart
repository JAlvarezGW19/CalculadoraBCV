import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

import '../providers/history_provider.dart';
import '../providers/iap_provider.dart';
import '../providers/bcv_provider.dart'; // For CurrencyType
import '../services/pdf_export_service.dart';
import '../theme/app_theme.dart';
import '../utils/ad_helper.dart';

// Widgets
import '../widgets/history/chart_card.dart';
import '../widgets/history/custom_date_range_picker.dart';
import '../widgets/history/filter_bar.dart';
import '../widgets/history/history_currency_toggle.dart';
import '../widgets/history/history_list_view.dart';
import '../widgets/history/pdf_unlock_dialog.dart';
import '../widgets/history/stats_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  RewardedAd? _rewardedAd;
  bool _isPdfUnlocked = false;
  bool _isExportingPdf = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(historyProvider.notifier).loadHistory();
    });
    _checkPdfUnlockStatus();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _checkPdfUnlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockTimeStr = prefs.getString('pdf_export_unlock_time');

    if (unlockTimeStr != null) {
      final unlockTime = DateTime.parse(unlockTimeStr);
      final now = DateTime.now();

      // Check if within 24 hours
      if (now.difference(unlockTime).inHours < 24) {
        setState(() {
          _isPdfUnlocked = true;
        });
      }
    }
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          // Retry after a short delay
          Future.delayed(const Duration(seconds: 5), _loadRewardedAd);
        },
      ),
    );
  }

  void _showRewardedAd() {
    final l10n = AppLocalizations.of(context)!;
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adNotReady)));
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
        // Unlock Feature
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'pdf_export_unlock_time',
          DateTime.now().toIso8601String(),
        );

        setState(() {
          _isPdfUnlocked = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.featureUnlocked)));
          // Proceed with export
          _exportPdf();
        }
      },
    );
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
    final l10n = AppLocalizations.of(context)!;
    if (state.data.isEmpty) return;

    final iapState = ref.read(iapProvider);

    if (!iapState.isPremium && !_isPdfUnlocked) {
      showDialog(
        context: context,
        builder: (_) => PdfUnlockDialog(onWatchAd: _showRewardedAd),
      );
      return;
    }

    setState(() {
      _isExportingPdf = true;
    });

    try {
      await PdfExportService.exportPdf(
        context: context,
        data: state.data,
        selectedCurrency: state.selectedCurrency,
        headerTitle: l10n.pdfHeader,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final conversionState = ref.watch(conversionProvider);
    final l10n = AppLocalizations.of(context)!;

    // Listen for History Errors
    ref.listen<HistoryState>(historyProvider, (previous, next) {
      if (!next.isLoading &&
          next.error != null &&
          next.error != previous?.error) {
        // Show generic error or specific if no internet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.noInternetConnection,
            ), // Assuming mostly network errors
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

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
                    l10n.history,
                    style: AppTheme.subtitleStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: (state.data.isEmpty || _isExportingPdf)
                        ? null
                        : _exportPdf,
                    icon: _isExportingPdf
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.textAccent,
                            ),
                          )
                        : const Icon(
                            Icons.picture_as_pdf,
                            color: AppTheme.textAccent,
                          ),
                    tooltip: l10n.generatePdf,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Currency Toggle
              Row(
                children: [
                  HistoryCurrencyToggle(
                    type: CurrencyType.usd,
                    label: "USD",
                    isSelected: state.selectedCurrency == CurrencyType.usd,
                    onTap: () => ref
                        .read(historyProvider.notifier)
                        .setCurrency(CurrencyType.usd),
                  ),
                  const SizedBox(width: 12),
                  HistoryCurrencyToggle(
                    type: CurrencyType.eur,
                    label: "EUR",
                    isSelected: state.selectedCurrency == CurrencyType.eur,
                    onTap: () => ref
                        .read(historyProvider.notifier)
                        .setCurrency(CurrencyType.eur),
                  ),
                  const Spacer(),
                  // Rounding Toggle
                  IconButton(
                    onPressed: () =>
                        ref.read(conversionProvider.notifier).toggleRounding(),
                    icon: Icon(
                      Icons.code,
                      color: conversionState.isRoundingEnabled
                          ? AppTheme.textSubtle
                          : AppTheme.textAccent,
                    ),
                    tooltip: "Alternar Redondeo",
                  ),
                  const SizedBox(width: 8),
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
                        ? l10n.viewList
                        : l10n.viewChart,
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
              _buildContent(state, conversionState, l10n),

              const SizedBox(height: 20),

              // Stats (Show always if data exists)
              if (state.data.isNotEmpty)
                HistoryStatsCard(
                  data: state.data,
                  isRoundingEnabled: conversionState.isRoundingEnabled,
                ),

              const SizedBox(height: 80), // Fab space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    HistoryState state,
    ConversionState conversionState,
    AppLocalizations l10n,
  ) {
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
      if (state.error != null) {
        return Container(
          height: 300,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppTheme.textSubtle),
              const SizedBox(height: 16),
              Text(
                l10n.noInternetConnection,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSubtle),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  ref.read(historyProvider.notifier).loadHistory();
                },
                icon: const Icon(Icons.refresh, color: AppTheme.textAccent),
                label: Text(
                  l10n.forceUpdate, // Reuse "Force Update" or similar key
                  style: const TextStyle(color: AppTheme.textAccent),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            l10n.noData,
            style: const TextStyle(color: AppTheme.textSubtle),
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
        isRoundingEnabled: conversionState.isRoundingEnabled,
      );
    } else {
      return HistoryListView(
        dataPoints: state.data,
        isRoundingEnabled: conversionState.isRoundingEnabled,
      );
    }
  }
}
