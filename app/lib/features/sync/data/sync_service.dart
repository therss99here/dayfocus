import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/app_config.dart';
import '../../../core/database/app_database.dart';
import '../../premium/domain/premium_limits.dart';

class SyncService {
  final AppDatabase _db;
  final SupabaseClient _client;
  final Future<bool> Function() _isPremiumCallback;

  SyncService(this._db, this._client, this._isPremiumCallback);

  String? get _userId => _client.auth.currentUser?.id;

  bool get canSync => AppConfig.isConfigured && _userId != null;

  Future<void> syncAll() async {
    if (!canSync) {
      debugPrint('[Sync] Cannot sync: configured=${AppConfig.isConfigured}, userId=$_userId');
      return;
    }
    debugPrint('[Sync] Starting sync for user $_userId');
    try {
      final isPremium = await _isPremiumCallback();
      final historyDays = isPremium
          ? PremiumLimits.premiumHistoryDays
          : PremiumLimits.freeHistoryDays;
      final cutoffDate = DateTime.now().subtract(Duration(days: historyDays));

      debugPrint('[Sync] Premium: $isPremium, syncing data from ${cutoffDate.toIso8601String()}');

      await _syncPremiumStatus(isPremium);
      await _syncDayConfigs(cutoffDate);
      await _syncPriorities(cutoffDate);
      await _syncTimeBlocks(cutoffDate);
      await _syncBrainDumpNotes(cutoffDate);
      await _syncUserSettings();
      debugPrint('[Sync] Sync completed successfully');
    } catch (e, st) {
      debugPrint('[Sync] Error: $e\n$st');
      rethrow;
    }
  }

  Future<void> syncPremiumStatusOnly() async {
    if (!canSync) return;
    try {
      final isPremium = await _isPremiumCallback();
      await _syncPremiumStatus(isPremium);
    } catch (e) {
      debugPrint('[Sync] Error syncing premium status: $e');
    }
  }

  // ── Premium Status ────────────────────────────────────────────────────────

  Future<void> _syncPremiumStatus(bool isPremium) async {
    final userId = _userId!;
    debugPrint('[Sync] Syncing premium status: $isPremium');

    await _client.from('user_profiles').upsert({
      'user_id': userId,
      'is_premium': isPremium,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ── Day Configs ───────────────────────────────────────────────────────────

  Future<void> _syncDayConfigs(DateTime cutoffDate) async {
    final userId = _userId!;

    // Pull remote changes (only within allowed date range)
    final remote = await _client
        .from('day_configs')
        .select()
        .eq('user_id', userId)
        .gte('date', cutoffDate.toIso8601String());

    for (final row in remote) {
      final existing = await (_db.select(_db.dayConfigs)
            ..where((t) => t.id.equals(row['id'] as String)))
          .getSingleOrNull();

      final remoteUpdated = DateTime.parse(row['updated_at'] as String);

      if (existing == null) {
        await _db.into(_db.dayConfigs).insert(DayConfigsCompanion.insert(
          id: row['id'] as String,
          date: DateTime.parse(row['date'] as String),
          startHour: row['start_hour'] as int,
          startMinute: row['start_minute'] as int,
          endHour: row['end_hour'] as int,
          endMinute: row['end_minute'] as int,
        ));
      } else if (remoteUpdated.isAfter(existing.createdAt)) {
        await (_db.update(_db.dayConfigs)
              ..where((t) => t.id.equals(row['id'] as String)))
            .write(DayConfigsCompanion(
          startHour: Value(row['start_hour'] as int),
          startMinute: Value(row['start_minute'] as int),
          endHour: Value(row['end_hour'] as int),
          endMinute: Value(row['end_minute'] as int),
        ));
      }
    }

    // Push local changes (only within allowed date range)
    final local = await (_db.select(_db.dayConfigs)
          ..where((t) => t.date.isBiggerOrEqualValue(cutoffDate)))
        .get();

    for (final item in local) {
      await _client.from('day_configs').upsert({
        'id': item.id,
        'user_id': userId,
        'date': item.date.toIso8601String(),
        'start_hour': item.startHour,
        'start_minute': item.startMinute,
        'end_hour': item.endHour,
        'end_minute': item.endMinute,
        'created_at': item.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ── Priorities ────────────────────────────────────────────────────────────

  Future<void> _syncPriorities(DateTime cutoffDate) async {
    final userId = _userId!;

    // Get day config IDs within date range
    final validDayConfigIds = await _getValidDayConfigIds(cutoffDate);

    // Pull remote
    final remote = await _client
        .from('priorities')
        .select()
        .eq('user_id', userId)
        .inFilter('day_config_id', validDayConfigIds.isEmpty ? [''] : validDayConfigIds);

    for (final row in remote) {
      final existing = await (_db.select(_db.priorities)
            ..where((t) => t.id.equals(row['id'] as String)))
          .getSingleOrNull();

      final remoteUpdated = DateTime.parse(row['updated_at'] as String);

      if (existing == null) {
        await _db.into(_db.priorities).insert(PrioritiesCompanion.insert(
          id: row['id'] as String,
          dayConfigId: row['day_config_id'] as String,
          title: row['title'] as String,
          sortOrder: row['sort_order'] as int,
          isDone: Value(row['is_done'] as bool? ?? false),
        ));
      } else if (remoteUpdated.isAfter(existing.updatedAt)) {
        await (_db.update(_db.priorities)
              ..where((t) => t.id.equals(row['id'] as String)))
            .write(PrioritiesCompanion(
          title: Value(row['title'] as String),
          isDone: Value(row['is_done'] as bool? ?? false),
          sortOrder: Value(row['sort_order'] as int),
          updatedAt: Value(remoteUpdated),
        ));
      }
    }

    // Push local (only for valid day configs)
    final local = await (_db.select(_db.priorities)
          ..where((t) => t.dayConfigId.isIn(validDayConfigIds)))
        .get();

    for (final item in local) {
      await _client.from('priorities').upsert({
        'id': item.id,
        'user_id': userId,
        'day_config_id': item.dayConfigId,
        'title': item.title,
        'is_done': item.isDone,
        'sort_order': item.sortOrder,
        'created_at': item.createdAt.toIso8601String(),
        'updated_at': item.updatedAt.toIso8601String(),
      });
    }
  }

  // ── Time Blocks ───────────────────────────────────────────────────────────

  Future<void> _syncTimeBlocks(DateTime cutoffDate) async {
    final userId = _userId!;

    final validDayConfigIds = await _getValidDayConfigIds(cutoffDate);

    // Pull remote
    final remote = await _client
        .from('time_blocks')
        .select()
        .eq('user_id', userId)
        .inFilter('day_config_id', validDayConfigIds.isEmpty ? [''] : validDayConfigIds);

    for (final row in remote) {
      final existing = await (_db.select(_db.timeBlocks)
            ..where((t) => t.id.equals(row['id'] as String)))
          .getSingleOrNull();

      final remoteUpdated = DateTime.parse(row['updated_at'] as String);

      if (existing == null) {
        await _db.into(_db.timeBlocks).insert(TimeBlocksCompanion.insert(
          id: row['id'] as String,
          dayConfigId: row['day_config_id'] as String,
          title: row['title'] as String,
          priorityId: Value(row['priority_id'] as String?),
          startHour: row['start_hour'] as int,
          startMinute: row['start_minute'] as int,
          endHour: row['end_hour'] as int,
          endMinute: row['end_minute'] as int,
          status: Value(row['status'] as String? ?? 'scheduled'),
        ));
      } else if (remoteUpdated.isAfter(existing.updatedAt)) {
        await (_db.update(_db.timeBlocks)
              ..where((t) => t.id.equals(row['id'] as String)))
            .write(TimeBlocksCompanion(
          title: Value(row['title'] as String),
          priorityId: Value(row['priority_id'] as String?),
          startHour: Value(row['start_hour'] as int),
          startMinute: Value(row['start_minute'] as int),
          endHour: Value(row['end_hour'] as int),
          endMinute: Value(row['end_minute'] as int),
          status: Value(row['status'] as String? ?? 'scheduled'),
          updatedAt: Value(remoteUpdated),
        ));
      }
    }

    // Push local
    final local = await (_db.select(_db.timeBlocks)
          ..where((t) => t.dayConfigId.isIn(validDayConfigIds)))
        .get();

    for (final item in local) {
      await _client.from('time_blocks').upsert({
        'id': item.id,
        'user_id': userId,
        'day_config_id': item.dayConfigId,
        'title': item.title,
        'priority_id': item.priorityId,
        'start_hour': item.startHour,
        'start_minute': item.startMinute,
        'end_hour': item.endHour,
        'end_minute': item.endMinute,
        'status': item.status,
        'created_at': item.createdAt.toIso8601String(),
        'updated_at': item.updatedAt.toIso8601String(),
      });
    }
  }

  // ── Brain Dump Notes ──────────────────────────────────────────────────────

  Future<void> _syncBrainDumpNotes(DateTime cutoffDate) async {
    final userId = _userId!;

    final validDayConfigIds = await _getValidDayConfigIds(cutoffDate);

    // Pull remote
    final remote = await _client
        .from('brain_dump_notes')
        .select()
        .eq('user_id', userId)
        .inFilter('day_config_id', validDayConfigIds.isEmpty ? [''] : validDayConfigIds);

    for (final row in remote) {
      final existing = await (_db.select(_db.brainDumpNotes)
            ..where((t) => t.id.equals(row['id'] as String)))
          .getSingleOrNull();

      final remoteUpdated = DateTime.parse(row['updated_at'] as String);

      if (existing == null) {
        await _db.into(_db.brainDumpNotes).insert(BrainDumpNotesCompanion.insert(
          id: row['id'] as String,
          dayConfigId: row['day_config_id'] as String,
          content: row['content'] as String,
        ));
      } else if (remoteUpdated.isAfter(existing.updatedAt)) {
        await (_db.update(_db.brainDumpNotes)
              ..where((t) => t.id.equals(row['id'] as String)))
            .write(BrainDumpNotesCompanion(
          content: Value(row['content'] as String),
          updatedAt: Value(remoteUpdated),
        ));
      }
    }

    // Push local
    final local = await (_db.select(_db.brainDumpNotes)
          ..where((t) => t.dayConfigId.isIn(validDayConfigIds)))
        .get();

    for (final item in local) {
      await _client.from('brain_dump_notes').upsert({
        'id': item.id,
        'user_id': userId,
        'day_config_id': item.dayConfigId,
        'content': item.content,
        'updated_at': item.updatedAt.toIso8601String(),
      });
    }
  }

  // ── User Settings ─────────────────────────────────────────────────────────

  Future<void> _syncUserSettings() async {
    final userId = _userId!;

    // Pull remote
    final remote = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId);

    for (final row in remote) {
      final key = row['key'] as String;
      final existing = await (_db.select(_db.userSettings)
            ..where((t) => t.key.equals(key)))
          .getSingleOrNull();

      if (existing == null) {
        await _db.into(_db.userSettings).insert(UserSettingsCompanion.insert(
          key: key,
          value: row['value'] as String,
        ));
      } else {
        await (_db.update(_db.userSettings)
              ..where((t) => t.key.equals(key)))
            .write(UserSettingsCompanion(
          value: Value(row['value'] as String),
        ));
      }
    }

    // Push local
    final local = await _db.select(_db.userSettings).get();
    for (final item in local) {
      await _client.from('user_settings').upsert({
        'user_id': userId,
        'key': item.key,
        'value': item.value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<List<String>> _getValidDayConfigIds(DateTime cutoffDate) async {
    final dayConfigs = await (_db.select(_db.dayConfigs)
          ..where((t) => t.date.isBiggerOrEqualValue(cutoffDate)))
        .get();
    return dayConfigs.map((dc) => dc.id).toList();
  }
}
