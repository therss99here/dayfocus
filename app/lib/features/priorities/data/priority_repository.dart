import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../domain/entities/priority_entity.dart';

const _uuid = Uuid();

class PriorityRepository {
  PriorityRepository(this._db);

  final AppDatabase _db;

  Stream<List<PriorityEntity>> watchForDay(String dayConfigId) =>
      _db.priorityDao
          .watchForDay(dayConfigId)
          .map((rows) => rows.map(_toEntity).toList());

  Future<String> add({
    required String dayConfigId,
    required String title,
    required int sortOrder,
  }) async {
    final id = _uuid.v4();
    await _db.priorityDao.insertOne(PrioritiesCompanion.insert(
      id: id,
      dayConfigId: dayConfigId,
      title: title,
      sortOrder: sortOrder,
    ));
    return id;
  }

  Future<void> updateTitle(String id, String title) =>
      _db.priorityDao.updateFields(
        id,
        PrioritiesCompanion(
          title: Value(title),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> setDone(String id, {required bool isDone}) =>
      _db.priorityDao.updateFields(
        id,
        PrioritiesCompanion(
          isDone: Value(isDone),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> updateSortOrder(String id, int sortOrder) =>
      _db.priorityDao.updateFields(
        id,
        PrioritiesCompanion(
          sortOrder: Value(sortOrder),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> delete(String id) => _db.priorityDao.deleteById(id);

  PriorityEntity _toEntity(Priority row) => PriorityEntity(
        id: row.id,
        title: row.title,
        isDone: row.isDone,
        sortOrder: row.sortOrder,
      );
}
