import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/core/database/app_database.dart';
import 'package:dayfocus/features/brain_dump/data/brain_dump_repository.dart';
import 'package:dayfocus/features/brain_dump/domain/brain_dump_content.dart';

void main() {
  late AppDatabase db;
  late BrainDumpRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = BrainDumpRepository(db.brainDumpDao);
    await db.ensureDayConfig('day1', DateTime(2026, 1, 1));
    await db.ensureDayConfig('day2', DateTime(2026, 1, 2));
  });

  tearDown(() => db.close());

  test('save delta content and retrieve via getForDay', () async {
    const delta = '[{"insert":"Hello world\\n"}]';
    await repo.save(dayConfigId: 'day1', deltaJson: delta);

    final content = await repo.getForDay('day1');
    expect(content.deltaJson, delta);
  });

  test('empty day returns BrainDumpContent.empty', () async {
    final content = await repo.getForDay('day1');
    expect(content.deltaJson, BrainDumpContent.empty.deltaJson);
  });

  test('upsert: saving to same dayConfigId updates existing', () async {
    await repo.save(dayConfigId: 'day1', deltaJson: '[{"insert":"v1\\n"}]');
    await repo.save(dayConfigId: 'day1', deltaJson: '[{"insert":"v2\\n"}]');

    final content = await repo.getForDay('day1');
    expect(content.deltaJson, '[{"insert":"v2\\n"}]');
  });

  test('legacy plain text is auto-converted to delta format', () async {
    await db.brainDumpDao.upsert(BrainDumpNotesCompanion(
      id: const Value('note1'),
      dayConfigId: const Value('day1'),
      content: const Value('Hello plain text'),
      contentFormat: const Value('plain'),
      updatedAt: Value(DateTime.now()),
    ));

    final content = await repo.getForDay('day1');
    final decoded = jsonDecode(content.deltaJson) as List;
    expect(decoded, hasLength(1));
    expect(decoded[0]['insert'], 'Hello plain text');
  });

  test('content is isolated per dayConfigId', () async {
    await repo.save(dayConfigId: 'day1', deltaJson: '[{"insert":"Day 1\\n"}]');

    final day1 = await repo.getForDay('day1');
    final day2 = await repo.getForDay('day2');
    expect(day1.deltaJson, '[{"insert":"Day 1\\n"}]');
    expect(day2.deltaJson, BrainDumpContent.empty.deltaJson);
  });

  test('watchForDay emits updates on save', () async {
    final stream = repo.watchForDay('day1');

    await repo.save(dayConfigId: 'day1', deltaJson: '[{"insert":"streamed\\n"}]');

    await expectLater(
      stream,
      emits(predicate<BrainDumpContent>(
        (c) => c.deltaJson == '[{"insert":"streamed\\n"}]',
      )),
    );
  });
}
