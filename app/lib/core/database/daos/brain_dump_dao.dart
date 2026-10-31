import 'package:drift/drift.dart';
import '../app_database.dart';

part 'brain_dump_dao.g.dart';

@DriftAccessor(tables: [BrainDumpNotes])
class BrainDumpDao extends DatabaseAccessor<AppDatabase>
    with _$BrainDumpDaoMixin {
  BrainDumpDao(super.db);

  Stream<BrainDumpNote?> watchForDay(String dayConfigId) =>
      (select(brainDumpNotes)
            ..where((n) => n.dayConfigId.equals(dayConfigId)))
          .watchSingleOrNull();

  Future<BrainDumpNote?> getForDay(String dayConfigId) =>
      (select(brainDumpNotes)
            ..where((n) => n.dayConfigId.equals(dayConfigId)))
          .getSingleOrNull();

  Future<void> upsert(BrainDumpNotesCompanion companion) =>
      into(brainDumpNotes).insertOnConflictUpdate(companion);
}
