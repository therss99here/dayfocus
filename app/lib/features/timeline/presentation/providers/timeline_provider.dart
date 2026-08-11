import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../data/time_block_repository.dart';
import '../../domain/entities/time_block.dart';
import 'active_day_provider.dart';

part 'timeline_provider.g.dart';

@riverpod
class TimelineNotifier extends _$TimelineNotifier {
  static const defaultStartHour = 9;
  static const defaultEndHour = 18;

  TimeBlockRepository get _repo => ref.read(timeBlockRepositoryProvider);

  void _triggerSync() {
    ref.read(syncNotifierProvider.notifier).syncOnDataChange();
  }

  @override
  Stream<List<TimeBlockEntity>> build() async* {
    final activeDay = ref.watch(activeDayProvider);
    final dayId = formatDayId(activeDay);
    final db = ref.read(appDatabaseProvider);
    await db.ensureDayConfig(dayId, activeDay);

    yield* ref
        .watch(timeBlockRepositoryProvider)
        .watchForDay(dayId);
  }

  String get _dayId => formatDayId(ref.read(activeDayProvider));

  (int, int) _nextSlot(int hour, int minute) =>
      minute == 0 ? (hour, 30) : (hour + 1, 0);

  // Returns the new block's ID so the caller can use it.
  Future<String> addBlockFromPriority({
    required String priorityId,
    required String title,
    required int startHour,
    required int startMinute,
  }) async {
    final (endH, endM) = _nextSlot(startHour, startMinute);
    final id = await _repo.add(
      dayConfigId: _dayId,
      title: title,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endH,
      endMinute: endM,
      priorityId: priorityId,
    );
    _triggerSync();
    return id;
  }

  Future<void> addBlock({
    required String title,
    required int startHour,
    required int startMinute,
  }) async {
    final (endH, endM) = _nextSlot(startHour, startMinute);
    await _repo.add(
      dayConfigId: _dayId,
      title: title,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endH,
      endMinute: endM,
    );
    _triggerSync();
  }

  Future<void> resizeBlock(String id, int newEndHour, int newEndMinute) async {
    final current = state.valueOrNull ?? [];
    final block = current.where((b) => b.id == id).firstOrNull;
    if (block == null) return;
    final endTotal = newEndHour * 60 + newEndMinute;
    if (endTotal < block.startTotalMinutes + 30) return;
    if (endTotal > defaultEndHour * 60) return;
    await _repo.updateTime(id, endHour: newEndHour, endMinute: newEndMinute);
    _triggerSync();
  }

  Future<void> toggleComplete(String id) async {
    final current = state.valueOrNull ?? [];
    final block = current.where((b) => b.id == id).firstOrNull;
    if (block == null) return;
    final newStatus = block.status == TimeBlockStatus.completed
        ? TimeBlockStatus.scheduled
        : TimeBlockStatus.completed;
    await _repo.setStatus(id, newStatus);
    _triggerSync();
  }

  Future<void> removeBlock(String id) async {
    await _repo.delete(id);
    _triggerSync();
  }

  // Called from PriorityTile when a priority is toggled, keeping linked block in sync.
  Future<void> syncFromPriority(String priorityId, bool isDone) async {
    final current = state.valueOrNull ?? [];
    final block = current.where((b) => b.priorityId == priorityId).firstOrNull;
    if (block == null) return;
    await _repo.setStatus(
      block.id,
      isDone ? TimeBlockStatus.completed : TimeBlockStatus.scheduled,
    );
    _triggerSync();
  }
}

@riverpod
class CurrentTime extends _$CurrentTime {
  @override
  Stream<DateTime> build() async* {
    yield DateTime.now();
    while (true) {
      await Future.delayed(const Duration(seconds: 30));
      yield DateTime.now();
    }
  }
}
