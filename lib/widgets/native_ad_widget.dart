import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/bcv_provider.dart';
import '../theme/app_theme.dart';
import '../utils/ad_helper.dart';

class NativeAdWidget extends ConsumerStatefulWidget {
  final int assignedTabIndex;
  const NativeAdWidget({super.key, required this.assignedTabIndex});

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  Timer? _debounceTimer;

  // Track previous state to detect specific changes
  CurrencyType? _prevCurrency;
  RateDateMode? _prevDateMode;
  String? _prevCustomRateId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    if (mounted) {
      setState(() => _isAdLoaded = false);
    }

    if (!_shouldShowAd()) return;

    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      // No factoryId -> Uses standard Native Template
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: AppTheme.cardBackground,
        cornerRadius: 24.0, // Match app card radius
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: AppTheme.background,
          backgroundColor: AppTheme.textAccent,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppTheme.textSubtle,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppTheme.textSubtle,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
      ),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isAdLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  bool _shouldShowAd() {
    final state = ref.read(conversionProvider);
    final customRates = ref.read(customRatesProvider);

    if (state.currency == CurrencyType.custom) {
      if (customRates.isEmpty) {
        // Only hide on Home Screen (index 0) where the "Create Rate" UI takes space.
        // On Calculator (index 1), layout is static, so keep Ad visible.
        if (widget.assignedTabIndex == 0) {
          return false;
        }
      }
    }
    return true;
  }

  void _triggerRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _loadAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider changes for triggers
    ref.listen(conversionProvider, (prev, next) {
      bool shouldRefresh = false;

      // 1. Currency Toggle
      if (next.currency != _prevCurrency) {
        shouldRefresh = true;
        _prevCurrency = next.currency;
      }
      // 2. Date Toggle
      if (next.dateMode != _prevDateMode) {
        shouldRefresh = true;
        _prevDateMode = next.dateMode;
      }
      // Custom Rate Change
      if (next.selectedCustomRateId != _prevCustomRateId) {
        shouldRefresh = true;
        _prevCustomRateId = next.selectedCustomRateId;
      }

      if (shouldRefresh) {
        _triggerRefresh();
      }
    });

    // Check visibility logic again for render
    if (!_shouldShowAd()) {
      return const SizedBox(height: 90.0);
    }

    // Check if this tab is active
    final activeTab = ref.watch(activeTabProvider);
    if (activeTab != widget.assignedTabIndex) {
      // If not active tab, dispose ad to save resources and run only one instance
      _nativeAd?.dispose();
      _nativeAd = null;
      _isAdLoaded = false;
      return const SizedBox(height: 90.0);
    } else {
      // Active tab, load if not loaded
      if (_nativeAd == null) {
        Future.microtask(() => _loadAd());
      }
    }

    // If Ad is NOT loaded (e.g. offline, loading, error), return empty space (invisible)
    if (!_isAdLoaded || _nativeAd == null) {
      return const SizedBox(height: 90.0);
    }

    // Ad Loaded: Show Native Ad (height 90)
    return SizedBox(
      height: 90.0,
      width: double.infinity,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
