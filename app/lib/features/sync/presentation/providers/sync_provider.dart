import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/database_providers.dart';
import '../../data/sync_service.dart';

part 'sync_provider.g.dart';

@riverpod
SyncService syncService(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final client = AppConfig.isConfigured ? Supabase.instance.client : null;
  if (client == null) {
    throw Exception('Supabase not configured');
  }
  return SyncService(db, client);
}

@riverpod
class SyncNotifier extends _$SyncNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> syncNow() async {
    if (!AppConfig.isConfigured) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(syncServiceProvider);
      await service.syncAll();
    });
  }
}
