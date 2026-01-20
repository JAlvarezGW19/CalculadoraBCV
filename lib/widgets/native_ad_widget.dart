import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/bcv_provider.dart';
import '../providers/iap_provider.dart';
import '../theme/app_theme.dart';
import '../providers/ad_provider.dart';
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      // Hide the ad but DO NOT dispose it.
      // We want to keep the ad instance alive so it shows immediately
      // when the user switches back to other tabs.
      return const SizedBox.shrink();
    }

    // Check Global Ad Provider
    final nativeAdState = ref.watch(nativeAdProvider);

    // Responsive Height
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final double adHeight = isTablet ? 200.0 : 118.0;

    // Check Premium State
    final iapState = ref.watch(iapProvider);
    if (iapState.isPremium) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);

    // If not loaded yet, or no ad, show Skeleton
    if (!nativeAdState.isLoaded || nativeAdState.ad == null) {
      // Logic: The provider is triggered by Home.
      // But if we landed here and it's not loading, maybe trigger it as backup?
      // Since nativeAdProvider is a Singleton-like, we can ensure it's loaded.
      // But we did it in Home. So just wait.
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
          child: AdWidget(ad: nativeAdState.ad!), // Use the shared ad
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
