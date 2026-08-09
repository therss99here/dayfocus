import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumService {
  static const _apiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: '',
  );

  static const monthlyProductId = 'dayfocus_premium_monthly';
  static const yearlyProductId = 'dayfocus_premium_yearly';

  static bool _initialized = false;

  static bool get isConfigured => _apiKey.isNotEmpty && _initialized;

  static Future<void> initialize() async {
    if (_apiKey.isEmpty) return;

    try {
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)..appUserID = null,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('[PremiumService] Failed to initialize: $e');
      _initialized = false;
    }
  }

  static Future<void> login(String userId) async {
    if (!isConfigured) return;
    await Purchases.logIn(userId);
  }

  static Future<void> logout() async {
    if (!isConfigured) return;
    await Purchases.logOut();
  }

  Future<bool> isPremium() async {
    if (!isConfigured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey('premium');
    } catch (_) {
      return false;
    }
  }

  Future<List<StoreProduct>> getProducts() async {
    if (!isConfigured) return [];
    try {
      return await Purchases.getProducts(
        [monthlyProductId, yearlyProductId],
        productCategory: ProductCategory.subscription,
      );
    } catch (_) {
      return [];
    }
  }

  Future<bool> purchase(StoreProduct product) async {
    if (!isConfigured) return false;
    try {
      await Purchases.purchase(PurchaseParams.storeProduct(product));
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey('premium');
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> restore() async {
    if (!isConfigured) return false;
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey('premium');
    } catch (_) {
      return false;
    }
  }
}
