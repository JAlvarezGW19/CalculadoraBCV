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
  Timer? _refreshTimer;
  NativeAd? _nativeAd;
  NativeAd? _pendingAd; // For preloading the next ad
  bool _isAdLoaded = false;
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

    // Initial load
    if (widget.assignedTabIndex == 0) {
      Future.microtask(() => _loadInitialAd());
    }

    // Setup periodic refresh (60s)
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _nativeAd?.dispose();
    _pendingAd?.dispose(); // Important: Dispose any loading ad
    _animationController.dispose();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    // User requested rotation every 60s.
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      // Only refresh if this tab is actually visible to the user
      final activeTab = ref.read(activeTabProvider);
      if (activeTab == widget.assignedTabIndex) {
        _preloadAndSwapAd();
      }
    });
  }

  void _loadInitialAd() {
    if (!_shouldShowAd()) return;
    _preloadAndSwapAd(isInitial: true);
  }

  /// Loads a new ad in the background and swaps it only when ready.
  void _preloadAndSwapAd({bool isInitial = false}) {
    // If we are already loading one, don't start another
    if (_pendingAd != null) return;

    // Helper to get styled ad
    final newAd = _createNativeAd();

    _pendingAd = newAd;

    newAd.load();
  }

  NativeAd _createNativeAd() {
    // Responsive sizing logic
    bool isTablet = false;
    try {
      isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    } catch (_) {}

    final double cornerRadius = isTablet ? 12.0 : 20.0;

    return NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
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
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            // SWAP LOGIC
            // 1. Dispose old ad if exists
            _nativeAd?.dispose();

            // 2. Assign new ad
            _nativeAd = ad as NativeAd;
            _pendingAd = null; // Clear pending flag

            _isAdLoaded = true;
            _adFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose(); // Always dispose failed ads
          if (mounted) {
            // Only update UI state if we don't have ANY ad to show
            // If we have an existing ad, we keep showing it (Graceful fallback)
            if (_nativeAd == null) {
              setState(() {
                _pendingAd = null;
                _adFailed = true;
                _isAdLoaded = false;
              });
            } else {
              // Silent failure on refresh - just clear pending
              _pendingAd = null;
            }
          }
        },
      ),
    );
  }

  bool _shouldShowAd() {
    final state = ref.read(conversionProvider);
    final customRates = ref.read(customRatesProvider);

    if (state.currency == CurrencyType.custom) {
      if (customRates.isEmpty) {
        if (widget.assignedTabIndex == 0) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for immediate reactivity
    final conversionState = ref.watch(conversionProvider);
    final customRates = ref.watch(customRatesProvider);

    // Immediate visibility check
    if (widget.assignedTabIndex == 0 &&
        conversionState.currency == CurrencyType.custom &&
        customRates.isEmpty) {
      // Dispose if hidden by logic
      if (_nativeAd != null) {
        _nativeAd?.dispose();
        _nativeAd = null;
        _isAdLoaded = false;
      }
      return const SizedBox.shrink();
    }

    // Check Premium State
    final iapState = ref.watch(iapProvider);
    if (iapState.isPremium) {
      if (_nativeAd != null) {
        _nativeAd?.dispose();
        _nativeAd = null;
        _isAdLoaded = false;
      }
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);

    // Responsive Height
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final double adHeight = isTablet ? 200.0 : 118.0;

    // If Ad Failed AND we have no fallback, collapse (or show empty container?)
    // Decision: Collapse to avoid ugly space.
    if (_adFailed && _nativeAd == null) {
      return const SizedBox.shrink();
    }

    // If not loaded and no ad, show Skeleton
    if (!_isAdLoaded || _nativeAd == null) {
      // If we are waiting for timer or initial load
      // Ensure we trigger load if safe
      if (_nativeAd == null && _pendingAd == null && !_adFailed) {
        Future.microtask(() => _loadInitialAd());
      }
      return _buildSkeleton(context, adHeight);
    }

    // Ad Loaded
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
        // Ad Container with fixed height for stability
        SizedBox(
          height: adHeight,
          width: double.infinity,
          child: AdWidget(ad: _nativeAd!),
        ),
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
