import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../data/premium_service.dart';

part 'premium_provider.g.dart';

@riverpod
PremiumService premiumService(Ref ref) => PremiumService();

@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  @override
  Future<bool> build() async {
    final service = ref.read(premiumServiceProvider);
    final isPremium = await service.isPremium();
    // Sync premium status to server on initial check
    _syncPremiumStatus();
    return isPremium;
  }

  void _syncPremiumStatus() {
    ref.read(syncNotifierProvider.notifier).syncPremiumStatus();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(premiumServiceProvider);
      return service.isPremium();
    });
    _syncPremiumStatus();
  }

  Future<bool> purchase(StoreProduct product) async {
    final service = ref.read(premiumServiceProvider);
    final success = await service.purchase(product);
    if (success) {
      state = const AsyncData(true);
      _syncPremiumStatus();
    }
    return success;
  }

  Future<bool> restore() async {
    final service = ref.read(premiumServiceProvider);
    final success = await service.restore();
    if (success) {
      state = const AsyncData(true);
      _syncPremiumStatus();
    }
    return success;
  }
}

@riverpod
Future<List<StoreProduct>> premiumProducts(Ref ref) async {
  final service = ref.read(premiumServiceProvider);
  return service.getProducts();
}
