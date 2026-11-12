import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/core/database/app_database.dart';
import 'package:dayfocus/features/priorities/data/priority_repository.dart';

void main() {
  late AppDatabase db;
  late PriorityRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PriorityRepository(db);
    await db.ensureDayConfig('day1', DateTime(2026, 1, 1));
    await db.ensureDayConfig('day2', DateTime(2026, 1, 2));
  });

  tearDown(() => db.close());

  test('add a priority and verify it appears in watchForDay stream', () async {
    final id = await repo.add(
      dayConfigId: 'day1',
      title: 'Exercise',
      sortOrder: 0,
    );

    final priorities = await repo.watchForDay('day1').first;
    expect(priorities, hasLength(1));
    expect(priorities.first.id, id);
    expect(priorities.first.title, 'Exercise');
    expect(priorities.first.isDone, false);
    expect(priorities.first.sortOrder, 0);
    expect(priorities.first.estimatedMinutes, isNull);
  });

  test('add multiple priorities and verify sort ordering', () async {
    await repo.add(dayConfigId: 'day1', title: 'Third', sortOrder: 2);
    await repo.add(dayConfigId: 'day1', title: 'First', sortOrder: 0);
    await repo.add(dayConfigId: 'day1', title: 'Second', sortOrder: 1);

    final priorities = await repo.watchForDay('day1').first;
    expect(priorities, hasLength(3));
    expect(priorities[0].title, 'First');
    expect(priorities[1].title, 'Second');
    expect(priorities[2].title, 'Third');
  });

  test('setDone persists the change', () async {
    final id = await repo.add(
      dayConfigId: 'day1',
      title: 'Read',
      sortOrder: 0,
    );

    await repo.setDone(id, isDone: true);

    final priorities = await repo.watchForDay('day1').first;
    expect(priorities.first.isDone, true);
  });

  test('delete removes the priority', () async {
    final id = await repo.add(
      dayConfigId: 'day1',
      title: 'Code',
      sortOrder: 0,
    );

    await repo.delete(id);

    final priorities = await repo.watchForDay('day1').first;
    expect(priorities, isEmpty);
  });

  test('priorities are isolated per dayConfigId', () async {
    await repo.add(dayConfigId: 'day1', title: 'Day1 task', sortOrder: 0);

    final day1 = await repo.watchForDay('day1').first;
    final day2 = await repo.watchForDay('day2').first;
    expect(day1, hasLength(1));
    expect(day2, isEmpty);
  });

  test('add with estimatedMinutes stores the value', () async {
    final id = await repo.add(
      dayConfigId: 'day1',
      title: 'Deep work',
      sortOrder: 0,
      estimatedMinutes: 90,
    );

    final priorities = await repo.watchForDay('day1').first;
    expect(priorities.first.id, id);
    expect(priorities.first.estimatedMinutes, 90);
  });
}
