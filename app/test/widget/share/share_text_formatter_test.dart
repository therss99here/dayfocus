import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/features/share/presentation/utils/share_text_formatter.dart';
import 'package:dayfocus/features/share/domain/day_summary.dart';
import 'package:dayfocus/features/priorities/domain/entities/priority_entity.dart';
import 'package:dayfocus/features/timeline/domain/entities/time_block.dart';

void main() {
  final testDate = DateTime(2026, 11, 13);

  group('formatDaySummary', () {
    test('empty summary contains "Planning starts here." and branding', () {
      final summary = DaySummary(
        date: testDate,
        priorities: [],
        timeBlocks: [],
      );
      final result = formatDaySummary(summary);
      expect(result, contains('Planning starts here.'));
      expect(result, contains('Made with MyDayfocus'));
    });

    test('summary with priorities shows check and circle marks', () {
      final summary = DaySummary(
        date: testDate,
        priorities: [
          const PriorityEntity(id: '1', title: 'Done task', isDone: true, sortOrder: 0),
          const PriorityEntity(id: '2', title: 'Open task', isDone: false, sortOrder: 1),
        ],
        timeBlocks: [],
      );
      final result = formatDaySummary(summary);
      expect(result, contains('✓ Done task'));
      expect(result, contains('○ Open task'));
      expect(result, contains('Priorities:'));
    });

    test('summary with blocks shows completion and duration', () {
      final summary = DaySummary(
        date: testDate,
        priorities: [],
        timeBlocks: [
          const TimeBlockEntity(
            id: '1', title: 'Block A',
            startHour: 9, startMinute: 0, endHour: 10, endMinute: 30,
            status: TimeBlockStatus.completed,
          ),
          const TimeBlockEntity(
            id: '2', title: 'Block B',
            startHour: 11, startMinute: 0, endHour: 12, endMinute: 0,
            status: TimeBlockStatus.scheduled,
          ),
        ],
      );
      final result = formatDaySummary(summary);
      expect(result, contains('1/2 blocks completed'));
      expect(result, contains('2h 30m planned'));
    });

    test('summary with only priorities does not show Timeline line', () {
      final summary = DaySummary(
        date: testDate,
        priorities: [
          const PriorityEntity(id: '1', title: 'Task', sortOrder: 0),
        ],
        timeBlocks: [],
      );
      final result = formatDaySummary(summary);
      expect(result, isNot(contains('Timeline:')));
      expect(result, isNot(contains('Planning starts here.')));
    });

    test('date is formatted correctly', () {
      final summary = DaySummary(
        date: testDate,
        priorities: [],
        timeBlocks: [],
      );
      final result = formatDaySummary(summary);
      expect(result, contains('Friday, November 13, 2026'));
    });

    test('duration shows only hours when no remainder minutes', () {
      final summary = DaySummary(
        date: testDate,
        priorities: [],
        timeBlocks: [
          const TimeBlockEntity(
            id: '1', title: 'Block',
            startHour: 9, startMinute: 0, endHour: 11, endMinute: 0,
            status: TimeBlockStatus.scheduled,
          ),
        ],
      );
      final result = formatDaySummary(summary);
      expect(result, contains('2h planned'));
      expect(result, isNot(contains('2h 0m')));
    });
  });
}
