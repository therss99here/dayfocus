import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/database_providers.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../../timeline/presentation/providers/active_day_provider.dart';
import '../../data/brain_dump_repository.dart';

part 'brain_dump_provider.g.dart';

@riverpod
BrainDumpRepository brainDumpRepository(BrainDumpRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return BrainDumpRepository(db.brainDumpDao);
}

@riverpod
class BrainDumpNotifier extends _$BrainDumpNotifier {
  BrainDumpRepository get _repo => ref.read(brainDumpRepositoryProvider);

  void _triggerSync() {
    ref.read(syncNotifierProvider.notifier).syncOnDataChange();
  }

  @override
  Stream<String> build() async* {
    final activeDay = ref.watch(activeDayProvider);
    final dayId = formatDayId(activeDay);
    final db = ref.read(appDatabaseProvider);
    await db.ensureDayConfig(dayId, activeDay);

    yield* _repo.watchForDay(dayId);
  }

  String get _dayId => formatDayId(ref.read(activeDayProvider));

  Future<void> save(String content) async {
    await _repo.save(dayConfigId: _dayId, content: content);
    _triggerSync();
  }
}
