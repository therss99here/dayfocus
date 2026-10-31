import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/brain_dump_dao.dart';

class BrainDumpRepository {
  BrainDumpRepository(this._dao);
  final BrainDumpDao _dao;

  Stream<String> watchForDay(String dayConfigId) =>
      _dao.watchForDay(dayConfigId).map((note) => note?.content ?? '');

  Future<String> getForDay(String dayConfigId) async {
    final note = await _dao.getForDay(dayConfigId);
    return note?.content ?? '';
  }

  Future<void> save({
    required String dayConfigId,
    required String content,
  }) async {
    final existing = await _dao.getForDay(dayConfigId);
    final id = existing?.id ?? const Uuid().v4();

    await _dao.upsert(BrainDumpNotesCompanion(
      id: Value(id),
      dayConfigId: Value(dayConfigId),
      content: Value(content),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
