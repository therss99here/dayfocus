// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brain_dump_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$brainDumpRepositoryHash() =>
    r'3490b1e4e9e691a7366291919198b9b53ca2ff1d';

/// See also [brainDumpRepository].
@ProviderFor(brainDumpRepository)
final brainDumpRepositoryProvider =
    AutoDisposeProvider<BrainDumpRepository>.internal(
      brainDumpRepository,
      name: r'brainDumpRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$brainDumpRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BrainDumpRepositoryRef = AutoDisposeProviderRef<BrainDumpRepository>;
String _$brainDumpNotifierHash() => r'756fb61a0676b599ae3cc0ba769881d7f79b9053';

/// See also [BrainDumpNotifier].
@ProviderFor(BrainDumpNotifier)
final brainDumpNotifierProvider =
    AutoDisposeStreamNotifierProvider<
      BrainDumpNotifier,
      BrainDumpContent
    >.internal(
      BrainDumpNotifier.new,
      name: r'brainDumpNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$brainDumpNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BrainDumpNotifier = AutoDisposeStreamNotifier<BrainDumpContent>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
