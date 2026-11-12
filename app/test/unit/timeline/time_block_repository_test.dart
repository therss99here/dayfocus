import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/core/database/app_database.dart';
import 'package:dayfocus/features/timeline/data/time_block_repository.dart';
import 'package:dayfocus/features/timeline/domain/entities/time_block.dart';

void main() {
  late AppDatabase db;
  late TimeBlockRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TimeBlockRepository(db);
    await db.ensureDayConfig('day1', DateTime(2026, 1, 1));
    await db.ensureDayConfig('day2', DateTime(2026, 1, 2));
  });

  tearDown(() => db.close());

  test('add a block and verify it appears in watchForDay stream', () async {
    final id = await repo.add(
      dayConfigId: 'day1',
      title: 'Standup',
      startHour: 9,
      startMinute: 0,
      endHour: 9,
      endMinute: 30,
    );

    final blocks = await repo.watchForDay('day1').first;
    expect(blocks, hasLength(1));
    expect(blocks.first.id, id);
    expect(blocks.first.title, 'Standup');
    expect(blocks.first.startHour, 9);
    expect(blocks.first.startMinute, 0);
    expect(blocks.first.endHour, 9);
    expect(blocks.first.endMinute, 30);
    expect(blocks.first.status, TimeBlockStatus.scheduled);
    expect(blocks.first.priorityId, isNull);
  });

  test('blocks are ordered by startHour then startMinute', () async {
    await repo.add(
      dayConfigId: 'day1',
      title: 'Afternoon',
      startHour: 14,
      startMinute: 0,
      endHour: 14,
      endMinute: 30,
    );
    await repo.add(
      dayConfigId: 'day1',
      title: 'Morning',
      startHour: 9,
      startMinute: 0,
      endHour: 9,
      endMinute: 30,
    );
    await repo.add(
      dayConfigId: 'day1',
      title: 'Mid-morning',
      startHour: 9,
      startMinute: 30,
      endHour: 10,
      endMinute: 0,
    );

    final blocks = await repo.watchForDay('day1').first;
    expect(blocks, hasLength(3));
    expect(blocks[0].title, 'Morning');
    expect(blocks[1].title, 'Mid-morning');
    expect(blocks[2].title, 'Afternoon');
  });

  test('updateTime changes end hour and minute', () async {
    final id = await repo.add(
      dayConfigId: 'day1',
      title: 'Deep work',
      startHour: 10,
      startMinute: 0,
      endHour: 10,
      endMinute: 30,
    );

    await repo.updateTime(id, endHour: 11, endMinute: 0);

    final blocks = await repo.watchForDay('day1').first;
    expect(blocks.first.endHour, 11);
    expect(blocks.first.endMinute, 0);
  });

  test('setStatus to completed and verify', () async {
    final id = await repo.add(
      dayConfigId: 'day1',
      title: 'Review',
      startHour: 15,
      startMinute: 0,
      endHour: 15,
      endMinute: 30,
    );

    await repo.setStatus(id, TimeBlockStatus.completed);

    final blocks = await repo.watchForDay('day1').first;
    expect(blocks.first.status, TimeBlockStatus.completed);
  });

  test('delete removes the block', () async {
    final id = await repo.add(
      dayConfigId: 'day1',
      title: 'Temp',
      startHour: 11,
      startMinute: 0,
      endHour: 11,
      endMinute: 30,
    );

    await repo.delete(id);

    final blocks = await repo.watchForDay('day1').first;
    expect(blocks, isEmpty);
  });

  test('blocks are isolated per dayConfigId', () async {
    await repo.add(
      dayConfigId: 'day1',
      title: 'Day1 block',
      startHour: 9,
      startMinute: 0,
      endHour: 9,
      endMinute: 30,
    );

    final day1 = await repo.watchForDay('day1').first;
    final day2 = await repo.watchForDay('day2').first;
    expect(day1, hasLength(1));
    expect(day2, isEmpty);
  });

  test('add with priorityId stores the link', () async {
    await db.priorityDao.insertOne(PrioritiesCompanion.insert(
      id: 'p1',
      dayConfigId: 'day1',
      title: 'Linked priority',
      sortOrder: 0,
    ));

    final id = await repo.add(
      dayConfigId: 'day1',
      title: 'Linked block',
      startHour: 10,
      startMinute: 0,
      endHour: 10,
      endMinute: 30,
      priorityId: 'p1',
    );

    final blocks = await repo.watchForDay('day1').first;
    expect(blocks.first.id, id);
    expect(blocks.first.priorityId, 'p1');
  });
}
