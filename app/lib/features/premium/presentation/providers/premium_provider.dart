import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/premium_service.dart';

part 'premium_provider.g.dart';

@riverpod
PremiumService premiumService(Ref ref) => PremiumService();

@riverpod
class PremiumNotifier extends _$PremiumNotifier {
  @override
  Future<bool> build() async {
    final service = ref.read(premiumServiceProvider);
    return service.isPremium();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(premiumServiceProvider);
      return service.isPremium();
    });
  }

  Future<bool> purchase(StoreProduct product) async {
    final service = ref.read(premiumServiceProvider);
    final success = await service.purchase(product);
    if (success) {
      state = const AsyncData(true);
    }
    return success;
  }

  Future<bool> restore() async {
    final service = ref.read(premiumServiceProvider);
    final success = await service.restore();
    if (success) {
      state = const AsyncData(true);
    }
    return success;
  }
}

@riverpod
Future<List<StoreProduct>> premiumProducts(Ref ref) async {
  final service = ref.read(premiumServiceProvider);
  return service.getProducts();
}
