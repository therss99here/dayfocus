import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/brain_dump_dao.dart';
import '../domain/brain_dump_content.dart';

class BrainDumpRepository {
  BrainDumpRepository(this._dao);
  final BrainDumpDao _dao;

  Stream<BrainDumpContent> watchForDay(String dayConfigId) =>
      _dao.watchForDay(dayConfigId).map(_noteToContent);

  Future<BrainDumpContent> getForDay(String dayConfigId) async {
    final note = await _dao.getForDay(dayConfigId);
    return _noteToContent(note);
  }

  Future<void> save({
    required String dayConfigId,
    required String deltaJson,
  }) async {
    final existing = await _dao.getForDay(dayConfigId);
    final id = existing?.id ?? const Uuid().v4();

    await _dao.upsert(BrainDumpNotesCompanion(
      id: Value(id),
      dayConfigId: Value(dayConfigId),
      content: Value(deltaJson),
      contentFormat: const Value('delta'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  BrainDumpContent _noteToContent(BrainDumpNote? note) {
    if (note == null || note.content.isEmpty) return BrainDumpContent.empty;

    if (note.contentFormat == 'delta') {
      return BrainDumpContent(deltaJson: note.content);
    }

    final escaped = jsonEncode(note.content);
    return BrainDumpContent(deltaJson: '[{"insert":$escaped}]');
  }
}
