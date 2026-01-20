import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_helper.dart';
import '../theme/app_theme.dart';

// State to hold the ad
class NativeAdState {
  final NativeAd? ad;
  final bool isLoaded;

  NativeAdState({this.ad, this.isLoaded = false});
}

class NativeAdController extends Notifier<NativeAdState> {
  @override
  NativeAdState build() {
    // Ensure we dispose the ad when this provider is destroyed
    ref.onDispose(() {
      state.ad?.dispose();
    });
    return NativeAdState();
  }

  void loadInitialAd() {
    if (state.isLoaded || state.ad != null) return;

    final ad = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: AppTheme.cardBackground,
        cornerRadius: 20.0,
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
          state = NativeAdState(ad: ad as NativeAd, isLoaded: true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Global NativeAd failed to load: $error');
          ad.dispose();
          state = NativeAdState(ad: null, isLoaded: false);
        },
      ),
    );

    ad.load();
  }

  void forceReload() {
    state.ad?.dispose();
    state = NativeAdState();
    loadInitialAd();
  }
}

final nativeAdProvider = NotifierProvider<NativeAdController, NativeAdState>(
  NativeAdController.new,
);
