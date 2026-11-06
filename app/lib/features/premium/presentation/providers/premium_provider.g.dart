// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$premiumServiceHash() => r'f51ff4c60fe2f0b13dd50c75c871dbd7b2862045';

/// See also [premiumService].
@ProviderFor(premiumService)
final premiumServiceProvider = AutoDisposeProvider<PremiumService>.internal(
  premiumService,
  name: r'premiumServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$premiumServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PremiumServiceRef = AutoDisposeProviderRef<PremiumService>;
String _$premiumProductsHash() => r'22e1655c15d4941109f096a47ed032aeff7f67bf';

/// See also [premiumProducts].
@ProviderFor(premiumProducts)
final premiumProductsProvider =
    AutoDisposeFutureProvider<List<StoreProduct>>.internal(
      premiumProducts,
      name: r'premiumProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$premiumProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PremiumProductsRef = AutoDisposeFutureProviderRef<List<StoreProduct>>;
String _$premiumNotifierHash() => r'c86f6f9fb94c113b76a07ee0ab43f88a6afc11c6';

/// See also [PremiumNotifier].
@ProviderFor(PremiumNotifier)
final premiumNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PremiumNotifier, bool>.internal(
      PremiumNotifier.new,
      name: r'premiumNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$premiumNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PremiumNotifier = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
