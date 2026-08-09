import 'package:drift/drift.dart';
import '../app_database.dart';

part 'time_block_dao.g.dart';

@DriftAccessor(tables: [TimeBlocks])
class TimeBlockDao extends DatabaseAccessor<AppDatabase>
    with _$TimeBlockDaoMixin {
  TimeBlockDao(super.db);

  Stream<List<TimeBlock>> watchForDay(String dayConfigId) =>
      (select(timeBlocks)
            ..where((b) => b.dayConfigId.equals(dayConfigId))
            ..orderBy([(b) => OrderingTerm.asc(b.startHour),
                        (b) => OrderingTerm.asc(b.startMinute)]))
          .watch();

  Future<void> upsert(TimeBlocksCompanion companion) =>
      into(timeBlocks).insertOnConflictUpdate(companion);

  Future<void> updateFields(String id, TimeBlocksCompanion companion) =>
      (update(timeBlocks)..where((b) => b.id.equals(id))).write(companion);

  Future<void> deleteById(String id) =>
      (delete(timeBlocks)..where((b) => b.id.equals(id))).go();
}
