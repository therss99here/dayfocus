import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../data/sync_service.dart';

part 'sync_provider.g.dart';

@riverpod
SyncService syncService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final client = AppConfig.isConfigured ? Supabase.instance.client : null;
  if (client == null) {
    throw Exception('Supabase not configured');
  }

  Future<bool> isPremiumCallback() async {
    final premiumState = ref.read(premiumNotifierProvider);
    return premiumState.valueOrNull ?? false;
  }

  return SyncService(db, client, isPremiumCallback);
}

@Riverpod(keepAlive: true)
class SyncNotifier extends _$SyncNotifier {
  Timer? _periodicTimer;
  Timer? _debounceTimer;
  DateTime? _lastSyncTime;

  static const _syncInterval = Duration(minutes: 5);
  static const _debounceDelay = Duration(seconds: 5);

  @override
  FutureOr<void> build() {
    _startPeriodicSync();
    ref.onDispose(() {
      _periodicTimer?.cancel();
      _debounceTimer?.cancel();
    });
  }

  void _startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_syncInterval, (_) {
      debugPrint('[Sync] Periodic sync triggered');
      syncNow();
    });
  }

  Future<void> syncNow() async {
    if (!AppConfig.isConfigured) return;

    // Prevent rapid successive syncs
    if (_lastSyncTime != null &&
        DateTime.now().difference(_lastSyncTime!) < const Duration(seconds: 30)) {
      debugPrint('[Sync] Skipping sync - too recent');
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(syncServiceProvider);
      await service.syncAll();
      _lastSyncTime = DateTime.now();
    });
  }

  void syncOnDataChange() {
    if (!AppConfig.isConfigured) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      debugPrint('[Sync] Debounced sync after data change');
      syncNow();
    });
  }

  Future<void> syncOnResume() async {
    if (!AppConfig.isConfigured) return;

    // Only sync if last sync was more than 1 minute ago
    if (_lastSyncTime != null &&
        DateTime.now().difference(_lastSyncTime!) < const Duration(minutes: 1)) {
      debugPrint('[Sync] Skipping resume sync - recent sync exists');
      return;
    }

    debugPrint('[Sync] App resumed - syncing');
    await syncNow();
  }

  Future<void> syncPremiumStatus() async {
    if (!AppConfig.isConfigured) return;

    try {
      final service = ref.read(syncServiceProvider);
      await service.syncPremiumStatusOnly();
    } catch (e) {
      debugPrint('[Sync] Error syncing premium status: $e');
    }
  }
}
