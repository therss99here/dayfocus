import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/core/database/app_database.dart';
import 'package:dayfocus/features/priorities/data/priority_repository.dart';

void main() {
  late AppDatabase db;
  late PriorityRepository repo;

  const dayId = '2026-11-13';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.ensureDayConfig(dayId, DateTime(2026, 11, 13));
    repo = PriorityRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PriorityRepository', () {
    test('add creates a priority with correct fields', () async {
      final id = await repo.add(
        dayConfigId: dayId,
        title: 'Exercise',
        sortOrder: 0,
      );

      expect(id, isNotEmpty);

      final priorities = await repo.watchForDay(dayId).first;
      expect(priorities, hasLength(1));
      expect(priorities.first.title, 'Exercise');
      expect(priorities.first.isDone, false);
      expect(priorities.first.sortOrder, 0);
      expect(priorities.first.estimatedMinutes, isNull);
    });

    test('add with estimatedMinutes stores duration', () async {
      await repo.add(
        dayConfigId: dayId,
        title: 'Deep work',
        sortOrder: 0,
        estimatedMinutes: 90,
      );

      final priorities = await repo.watchForDay(dayId).first;
      expect(priorities.first.estimatedMinutes, 90);
    });

    test('sortOrder 0 for first item in empty list', () async {
      await repo.add(dayConfigId: dayId, title: 'First', sortOrder: 0);

      final priorities = await repo.watchForDay(dayId).first;
      expect(priorities.first.sortOrder, 0);
    });

    test('multiple priorities maintain sort order', () async {
      await repo.add(dayConfigId: dayId, title: 'A', sortOrder: 0);
      await repo.add(dayConfigId: dayId, title: 'B', sortOrder: 1);
      await repo.add(dayConfigId: dayId, title: 'C', sortOrder: 2);

      final priorities = await repo.watchForDay(dayId).first;
      expect(priorities.map((p) => p.title).toList(), ['A', 'B', 'C']);
    });

    test('setDone toggles completion', () async {
      final id = await repo.add(
        dayConfigId: dayId,
        title: 'Task',
        sortOrder: 0,
      );

      await repo.setDone(id, isDone: true);
      var priorities = await repo.watchForDay(dayId).first;
      expect(priorities.first.isDone, true);

      await repo.setDone(id, isDone: false);
      priorities = await repo.watchForDay(dayId).first;
      expect(priorities.first.isDone, false);
    });

    test('updateSortOrder changes order', () async {
      final id1 = await repo.add(dayConfigId: dayId, title: 'A', sortOrder: 0);
      final id2 = await repo.add(dayConfigId: dayId, title: 'B', sortOrder: 1);

      await repo.updateSortOrder(id1, 1);
      await repo.updateSortOrder(id2, 0);

      final priorities = await repo.watchForDay(dayId).first;
      expect(priorities.map((p) => p.title).toList(), ['B', 'A']);
    });

    test('delete removes priority', () async {
      final id = await repo.add(
        dayConfigId: dayId,
        title: 'Temporary',
        sortOrder: 0,
      );

      await repo.delete(id);

      final priorities = await repo.watchForDay(dayId).first;
      expect(priorities, isEmpty);
    });

    test('priorities are isolated per day', () async {
      const day2 = '2026-11-14';
      await db.ensureDayConfig(day2, DateTime(2026, 11, 14));

      await repo.add(dayConfigId: dayId, title: 'Day 1 task', sortOrder: 0);
      await repo.add(dayConfigId: day2, title: 'Day 2 task', sortOrder: 0);

      final day1Priorities = await repo.watchForDay(dayId).first;
      final day2Priorities = await repo.watchForDay(day2).first;

      expect(day1Priorities, hasLength(1));
      expect(day1Priorities.first.title, 'Day 1 task');
      expect(day2Priorities, hasLength(1));
      expect(day2Priorities.first.title, 'Day 2 task');
    });

    test('updateTitle changes the title', () async {
      final id = await repo.add(
        dayConfigId: dayId,
        title: 'Old title',
        sortOrder: 0,
      );

      await repo.updateTitle(id, 'New title');

      final priorities = await repo.watchForDay(dayId).first;
      expect(priorities.first.title, 'New title');
    });
  });
}
