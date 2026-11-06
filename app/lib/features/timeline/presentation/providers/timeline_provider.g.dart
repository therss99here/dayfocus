// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timelineNotifierHash() => r'353b225534444be2c5f7bb06ca9914a1ac71cc98';

/// See also [TimelineNotifier].
@ProviderFor(TimelineNotifier)
final timelineNotifierProvider =
    AutoDisposeStreamNotifierProvider<
      TimelineNotifier,
      List<TimeBlockEntity>
    >.internal(
      TimelineNotifier.new,
      name: r'timelineNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timelineNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TimelineNotifier = AutoDisposeStreamNotifier<List<TimeBlockEntity>>;
String _$currentTimeHash() => r'06fb5560d080f2b66ddb08b88833b3a1b99a5e1c';

/// See also [CurrentTime].
@ProviderFor(CurrentTime)
final currentTimeProvider =
    AutoDisposeStreamNotifierProvider<CurrentTime, DateTime>.internal(
      CurrentTime.new,
      name: r'currentTimeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentTimeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentTime = AutoDisposeStreamNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
