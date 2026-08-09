import 'package:drift/drift.dart';
import '../app_database.dart';

part 'priority_dao.g.dart';

@DriftAccessor(tables: [Priorities])
class PriorityDao extends DatabaseAccessor<AppDatabase>
    with _$PriorityDaoMixin {
  PriorityDao(super.db);

  Stream<List<Priority>> watchForDay(String dayConfigId) =>
      (select(priorities)
            ..where((p) => p.dayConfigId.equals(dayConfigId))
            ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
          .watch();

  Future<void> insertOne(PrioritiesCompanion companion) =>
      into(priorities).insert(companion);

  Future<void> updateFields(String id, PrioritiesCompanion companion) =>
      (update(priorities)..where((p) => p.id.equals(id))).write(companion);

  Future<void> deleteById(String id) =>
      (delete(priorities)..where((p) => p.id.equals(id))).go();
}
