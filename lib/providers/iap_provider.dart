import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/home_widget_service.dart';
import 'bcv_provider.dart'; // To access apiServiceProvider

final iapProvider = NotifierProvider<IapNotifier, IapState>(IapNotifier.new);

class IapState {
  final bool isAvailable;
  final bool isPremium;
  final bool isLoading;
  final List<ProductDetails> products;

  IapState({
    this.isAvailable = false,
    this.isPremium = false,
    this.isLoading = true,
    this.products = const [],
  });

  IapState copyWith({
    bool? isAvailable,
    bool? isPremium,
    bool? isLoading,
    List<ProductDetails>? products,
  }) {
    return IapState(
      isAvailable: isAvailable ?? this.isAvailable,
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
    );
  }
}

class IapNotifier extends Notifier<IapState> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const String _premiumId = 'remove_ads_permanent';

  @override
  IapState build() {
    _initialize();

    // Register disposal logic
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return IapState();
  }

  Future<void> _initialize() async {
    try {
      // 1. Check local cache first (instant premium check)
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('is_premium') ?? false;
      state = state.copyWith(isPremium: isPremium);

      // 2. Listen to purchases
      final purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {
          _subscription?.cancel();
        },
        onError: (error) {
          debugPrint("IAP Error: $error");
        },
      );

      // 3. Check store availability
      final bool available = await _iap.isAvailable();
      if (!available) {
        state = state.copyWith(isAvailable: false, isLoading: false);
        return;
      }

      // 4. Query Products
      const Set<String> kIds = <String>{_premiumId};
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        kIds,
      );

      if (response.error == null) {
        state = state.copyWith(
          isAvailable: true,
          products: response.productDetails,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isAvailable: true, isLoading: false);
      }

      // 5. Restore purchases if needed (or verify receipt)
      // For now, we rely on streams. Maybe auto-restore on first load?
      // io.restorePurchases();
    } catch (e) {
      debugPrint("Error initializing IAP: $e");
      state = state.copyWith(isAvailable: false, isLoading: false);
    }
  }

  Future<void> buyPremium() async {
    state = state.copyWith(isLoading: true); // Show loading UI

    if (state.products.isEmpty) {
      if (kDebugMode) {
        // SIMULATION MODE (Only in Debug)
        // Helps testing UI flow before Play Console setup is complete.
        debugPrint("IAP: Simulation Mode (Debug Only) - Granting Premium");
        await Future.delayed(const Duration(seconds: 2));
        await _grantPremium();
        state = state.copyWith(isLoading: false);
        return;
      } else {
        // PRODUCTION MODE
        // If products are missing in Release, it means Play Console setup is incomplete
        // or there's a network error. Do NOT grant free premium.
        debugPrint("IAP: No products found in Release mode.");
        state = state.copyWith(isLoading: false);
        // You might want to throw an error or show a snackbar here via a listener
        return;
      }
    }

    // Real Flow
    final ProductDetails productDetails = state.products.firstWhere(
      (product) => product.id == _premiumId,
      orElse: () => state.products.first,
    );

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    // Initiate (Result handled by stream listener)
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    // Note: isLoading will remain true until stream updates or UI handles it
    // But for better UX let's toggle it back shortly if stream doesn't fire immediately
    // or let the stream listener handle state.
    // Usually stream fires 'pending' quickly.
    // For safety in this hybrid mode:
    Future.delayed(const Duration(seconds: 5), () {
      if (state.isLoading) state = state.copyWith(isLoading: false);
    });
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle Error
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Grant Premium
          _grantPremium();
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _grantPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    state = state.copyWith(isPremium: true);

    // Update Widget Premium Status
    // Update Widget Premium Status
    try {
      // Trigger API refresh to update widget with real data immediately
      await ref.read(apiServiceProvider).fetchRates(forceRefresh: true);
    } catch (_) {
      // Fallback: Just update status if API fails
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
