import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/config/app_config.dart';

class PremiumService {
  static const monthlyProductId = 'dayfocus_premium_monthly';
  static const yearlyProductId = 'dayfocus_premium_yearly';
  static const entitlementId = 'dayfocus Pro';

  static bool _initialized = false;

  static bool get isConfigured =>
      AppConfig.revenuecatApiKey.isNotEmpty && _initialized;

  static Future<void> initialize() async {
    if (AppConfig.revenuecatApiKey.isEmpty) return;

    try {
      await Purchases.configure(
        PurchasesConfiguration(AppConfig.revenuecatApiKey)..appUserID = null,
      );
      _initialized = true;
      debugPrint('[PremiumService] Initialized successfully');
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
      return info.entitlements.active.containsKey(entitlementId);
    } catch (_) {
      return false;
    }
  }

  Future<List<StoreProduct>> getProducts() async {
    if (!isConfigured) {
      debugPrint('[PremiumService] Not configured, returning empty products');
      return [];
    }
    try {
      debugPrint('[PremiumService] Fetching products...');
      final products = await Purchases.getProducts(
        [monthlyProductId, yearlyProductId],
        productCategory: ProductCategory.subscription,
      );
      debugPrint('[PremiumService] Got ${products.length} products');
      return products;
    } catch (e) {
      debugPrint('[PremiumService] Error fetching products: $e');
      return [];
    }
  }

  Future<bool> purchase(StoreProduct product) async {
    if (!isConfigured) return false;
    try {
      await Purchases.purchase(PurchaseParams.storeProduct(product));
      final info = await Purchases.getCustomerInfo();
      debugPrint('[PremiumService] Active entitlements: ${info.entitlements.active.keys.toList()}');
      debugPrint('[PremiumService] Looking for: $entitlementId');
      final hasPremium = info.entitlements.active.containsKey(entitlementId);
      debugPrint('[PremiumService] Has premium: $hasPremium');
      return hasPremium;
    } on PurchasesErrorCode catch (e) {
      debugPrint('[PremiumService] Purchase error: $e');
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
      return info.entitlements.active.containsKey(entitlementId);
    } catch (_) {
      return false;
    }
  }
}
