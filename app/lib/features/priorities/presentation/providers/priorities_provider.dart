import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../timeline/presentation/providers/active_day_provider.dart';
import '../../data/priority_repository.dart';
import '../../domain/entities/priority_entity.dart';

part 'priorities_provider.g.dart';

@riverpod
class PrioritiesNotifier extends _$PrioritiesNotifier {
  static const softLimit = 3;

  PriorityRepository get _repo => ref.read(priorityRepositoryProvider);

  @override
  Stream<List<PriorityEntity>> build() async* {
    final activeDay = ref.watch(activeDayProvider);
    final dayId = formatDayId(activeDay);
    final db = ref.read(appDatabaseProvider);
    await db.ensureDayConfig(dayId, activeDay);

    yield* ref
        .watch(priorityRepositoryProvider)
        .watchForDay(dayId);
  }

  String get _dayId => formatDayId(ref.read(activeDayProvider));

  Future<void> add(String title) async {
    final t = title.trim();
    if (t.isEmpty) return;
    final current = state.valueOrNull ?? [];
    final maxOrder = current.isEmpty
        ? 0
        : current.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    await _repo.add(
      dayConfigId: _dayId,
      title: t,
      sortOrder: maxOrder,
    );
  }

  Future<void> remove(String id) => _repo.delete(id);

  Future<void> toggleDone(String id) async {
    final current = state.valueOrNull ?? [];
    final p = current.where((p) => p.id == id).firstOrNull;
    if (p == null) return;
    await _repo.setDone(id, isDone: !p.isDone);
  }

  // Called from TimelineWidget when a block is toggled, keeping the linked priority in sync.
  // Caller must pass priorityId (block.priorityId), not the block's own id.
  Future<void> syncFromBlock(String priorityId, bool isDone) async {
    await _repo.setDone(priorityId, isDone: isDone);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final sorted = [...(state.valueOrNull ?? [])]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final item = sorted.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex--;
    sorted.insert(newIndex, item);
    await Future.wait([
      for (var i = 0; i < sorted.length; i++)
        _repo.updateSortOrder(sorted[i].id, i),
    ]);
  }
}
