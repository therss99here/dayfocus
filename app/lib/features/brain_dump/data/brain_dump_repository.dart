import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';

const _uuid = Uuid();

class BrainDumpRepository {
  BrainDumpRepository(this._db);

  final AppDatabase _db;

  Stream<String?> watchForDay(String dayConfigId) =>
      _db.brainDumpDao.watchForDay(dayConfigId).map((note) => note?.content);

  Future<void> save(String dayConfigId, String content) async {
    final existing = await _db.brainDumpDao.watchForDay(dayConfigId).first;
    final id = existing?.id ?? _uuid.v4();

    await _db.brainDumpDao.upsert(BrainDumpNotesCompanion(
      id: Value(id),
      dayConfigId: Value(dayConfigId),
      content: Value(content),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
