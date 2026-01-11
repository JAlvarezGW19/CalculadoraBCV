import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/bcv_provider.dart';
import '../providers/iap_provider.dart';
import '../theme/app_theme.dart';
import '../utils/ad_helper.dart';
import 'premium_benefits_dialog.dart';
import 'package:calculadora_bcv/l10n/app_localizations.dart';

class NativeAdWidget extends ConsumerStatefulWidget {
  final int assignedTabIndex;
  const NativeAdWidget({super.key, required this.assignedTabIndex});

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget>
    with SingleTickerProviderStateMixin {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  Timer? _debounceTimer;

  // Track previous state to detect specific changes
  CurrencyType? _prevCurrency;
  RateDateMode? _prevDateMode;
  String? _prevCustomRateId;

  bool _adFailed = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(_animationController);

    // Load immediately (using microtask to ensuring context/ref availability if needed,
    // though for ad request usually context is for UI params which we handle)
    // We move the load trigger here to be as fast as possible.
    if (widget.assignedTabIndex == 0) {
      Future.microtask(() => _loadAd());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nativeAd?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    if (mounted) {
      setState(() {
        _isAdLoaded = false;
        _adFailed = false;
      });
    }

    if (!_shouldShowAd()) return;

    // Responsive logic (Calculate inside loadAd to apply correct template style)
    // Tablets usually have a shortest side >= 600
    // If context is somehow invalid (rare here due to microtask), default to phone.
    bool isTablet = false;
    try {
      isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    } catch (_) {}

    // On phones: ~118 is safe and compact.
    // On tablets: 200 ensures no clipping errors.
    final double cornerRadius = isTablet ? 12.0 : 20.0;

    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      // No factoryId -> Uses standard Native Template
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: AppTheme.cardBackground,
        cornerRadius: cornerRadius,
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
            setState(() {
              _isAdLoaded = true;
              _adFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _adFailed = true;
            });
          }
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
    // Responsive Height calculation for the Container
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final double adHeight = isTablet ? 200.0 : 118.0;

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
      return const SizedBox.shrink(); // Collapsed if logic says hide
    }

    // Check Premium State
    final iapState = ref.watch(iapProvider);
    if (iapState.isPremium) {
      return const SizedBox.shrink();
    }

    // Check if this tab is active
    final activeTab = ref.watch(activeTabProvider);
    if (activeTab != widget.assignedTabIndex) {
      // If not active tab, dispose ad to save resources and run only one instance
      _nativeAd?.dispose();
      _nativeAd = null;
      _isAdLoaded = false;
      return const SizedBox.shrink();
    } else {
      // Active tab, load if not loaded
      if (_nativeAd == null && !_adFailed) {
        Future.microtask(() => _loadAd());
      }
    }

    final l10n = AppLocalizations.of(context);

    // If Ad Failed, show nothing (collapsed)
    if (_adFailed) {
      return const SizedBox.shrink();
    }

    // If Ad is NOT loaded yet, Show Skeleton (pulsing placeholder)
    if (!_isAdLoaded || _nativeAd == null) {
      return _buildSkeleton(context, adHeight);
    }

    // Ad Loaded: Show Native Ad

    // Ad Loaded: Show Native Ad (height responsive) + Remove Ads link
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Spacer to push ad down if needed
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 8),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const PremiumBenefitsDialog(),
              );
            },
            child: Text(
              l10n?.removeAdsLink ?? "Quitar anuncios",
              style: TextStyle(
                color: AppTheme.textSubtle.withValues(alpha: 0.5),
                fontSize: 10,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        SizedBox(
          height: adHeight,
          width: double.infinity,
          child: AdWidget(ad: _nativeAd!),
        ),
        // Bottom margin
        const SizedBox(height: 0),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context, double height) {
    final l10n = AppLocalizations.of(context);
    // Return structure matching the simple Column layout of the real ad
    // Text is outside skeleton animation. Only the ad box pulses.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 8),
          child: Text(
            l10n?.removeAdsLink ?? "Quitar anuncios",
            style: TextStyle(
              color: AppTheme.textSubtle.withValues(alpha: 0.5),
              fontSize: 10,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              // Outer container: Full height to keep spacing fixed
              child: SizedBox(
                height: height,
                child: Align(
                  alignment: Alignment.topCenter,
                  // Visual container: 20% shorter (height * 0.8)
                  child: Container(
                    height: height * 0.8,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 80,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 0),
      ],
    );
  }
}
