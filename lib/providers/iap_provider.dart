import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/home_widget_service.dart';
import 'bcv_provider.dart';

final iapProvider = NotifierProvider<IapNotifier, IapState>(IapNotifier.new);

class IapState {
  final bool isAvailable;
  final bool isPremium;
  final bool isLoading;
  final List<ProductDetails> products;
  final String? error;

  IapState({
    this.isAvailable = false,
    this.isPremium = false,
    this.isLoading = true,
    this.products = const [],
    this.error,
  });

  IapState copyWith({
    bool? isAvailable,
    bool? isPremium,
    bool? isLoading,
    List<ProductDetails>? products,
    String? error,
  }) {
    return IapState(
      isAvailable: isAvailable ?? this.isAvailable,
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error,
    );
  }
}

class IapNotifier extends Notifier<IapState> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Ensure this ID matches your Google Play Console Product ID exactly
  static const String _premiumId = 'remove_ads_permanent';

  @override
  IapState build() {
    _initialize();

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return IapState();
  }

  Future<void> _initialize() async {
    // 1. Check local cache for immediate UI response
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium') ?? false;
    state = state.copyWith(isPremium: isPremium);

    // 2. Listen to purchase stream
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint("IAP Stream Error: $error");
        state = state.copyWith(error: error.toString());
      },
    );

    // 3. Check Store Availability
    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        state = state.copyWith(isAvailable: false, isLoading: false);
        return;
      }

      // 4. Query Products from Store
      const Set<String> kIds = <String>{_premiumId};
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        kIds,
      );

      if (response.error != null) {
        debugPrint("IAP Query Error: ${response.error!.message}");
        state = state.copyWith(
          isAvailable: true,
          isLoading: false,
          error: response.error!.message,
        );
        return;
      }

      if (response.productDetails.isEmpty) {
        debugPrint(
          "IAP: No products found. Check Google Play Console configuration.",
        );
      }

      state = state.copyWith(
        isAvailable: true,
        products: response.productDetails,
        isLoading: false,
      );
    } catch (e) {
      debugPrint("IAP Init Exception: $e");
      state = state.copyWith(
        isAvailable: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> buyPremium() async {
    if (state.products.isEmpty) {
      debugPrint("IAP: Cannot buy, no products available.");
      state = state.copyWith(error: "No products available");
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final ProductDetails productDetails = state.products.firstWhere(
        (product) => product.id == _premiumId,
        orElse: () => state.products.first,
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      // Initiate purchase
      // 'buyNonConsumable' is correct for one-time permanent purchases
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint("IAP Buy Error: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _iap.restorePurchases();
      // The stream listener will handle the results of restoration
    } catch (e) {
      debugPrint("IAP Restore Error: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    bool hasPurchased = false;

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Pending state - UI handles this via isLoading usually
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("IAP Purchase Error: ${purchaseDetails.error}");
          state = state.copyWith(
            isLoading: false,
            error: purchaseDetails.error?.message,
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Validate purchase if necessary (server-side verification recommended for high value)
          // For this app, we trust the status for now
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _grantPremium();
            hasPurchased = true;
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }

    if (hasPurchased) {
      state = state.copyWith(isLoading: false);
    }
    // If we finished processing a restore batch (though stream gives chunks),
    // we might want to stop loading. Hard to know exactly when restore is "done"
    // completely without external signal, but usually handling the list is enough.
    // We'll set loading to false after a short delay if it's still true.
    if (state.isLoading) {
      Future.delayed(const Duration(seconds: 1), () {
        state = state.copyWith(isLoading: false);
      });
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Implement server-side verification here if needed.
    // For local-only unlocking, return true.
    return true;
  }

  Future<void> _grantPremium() async {
    if (state.isPremium) return; // Already premium

    debugPrint("IAP: Granting Premium Status");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    state = state.copyWith(isPremium: true);

    // Update Widget and trigger generic refreshes
    try {
      await ref.read(apiServiceProvider).fetchRates(forceRefresh: true);
    } catch (_) {
      try {
        await HomeWidgetService.updateWidgetData(
          usdRate: 0.0,
          eurRate: 0.0,
          rateDate: DateTime.now().toIso8601String(),
          isPremium: true,
        );
      } catch (_) {}
    }
  }
}
