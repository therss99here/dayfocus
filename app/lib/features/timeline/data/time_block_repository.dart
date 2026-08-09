import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../domain/entities/time_block.dart';

const _uuid = Uuid();

class TimeBlockRepository {
  TimeBlockRepository(this._db);

  final AppDatabase _db;

  Stream<List<TimeBlockEntity>> watchForDay(String dayConfigId) =>
      _db.timeBlockDao
          .watchForDay(dayConfigId)
          .map((rows) => rows.map(_toEntity).toList());

  Future<String> add({
    required String dayConfigId,
    required String title,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    String? priorityId,
  }) async {
    final id = _uuid.v4();
    await _db.timeBlockDao.upsert(TimeBlocksCompanion.insert(
      id: id,
      dayConfigId: dayConfigId,
      title: title,
      priorityId: Value(priorityId),
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
    ));
    return id;
  }

  Future<void> updateTime(
    String id, {
    required int endHour,
    required int endMinute,
  }) =>
      _db.timeBlockDao.updateFields(
        id,
        TimeBlocksCompanion(
          endHour: Value(endHour),
          endMinute: Value(endMinute),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> setStatus(String id, TimeBlockStatus status) =>
      _db.timeBlockDao.updateFields(
        id,
        TimeBlocksCompanion(
          status: Value(_statusToString(status)),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> delete(String id) => _db.timeBlockDao.deleteById(id);

  TimeBlockEntity _toEntity(TimeBlock row) => TimeBlockEntity(
        id: row.id,
        title: row.title,
        priorityId: row.priorityId,
        startHour: row.startHour,
        startMinute: row.startMinute,
        endHour: row.endHour,
        endMinute: row.endMinute,
        status: _statusFromString(row.status),
      );

  TimeBlockStatus _statusFromString(String s) => switch (s) {
        'in_progress' => TimeBlockStatus.inProgress,
        'completed' => TimeBlockStatus.completed,
        'missed' => TimeBlockStatus.missed,
        _ => TimeBlockStatus.scheduled,
      };

  String _statusToString(TimeBlockStatus s) => switch (s) {
        TimeBlockStatus.inProgress => 'in_progress',
        TimeBlockStatus.completed => 'completed',
        TimeBlockStatus.missed => 'missed',
        TimeBlockStatus.scheduled => 'scheduled',
      };
}
