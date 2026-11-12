import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/features/timeline/presentation/widgets/time_block_widget.dart';
import 'package:dayfocus/features/timeline/domain/entities/time_block.dart';

TimeBlockEntity _block({
  TimeBlockStatus status = TimeBlockStatus.scheduled,
  String? priorityId,
}) =>
    TimeBlockEntity(
      id: 'b1',
      title: 'Standup',
      priorityId: priorityId,
      startHour: 10,
      startMinute: 0,
      endHour: 10,
      endMinute: 30,
      status: status,
    );

Widget _buildBlock(TimeBlockEntity block) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          TimeBlockWidget(
            block: block,
            topOffset: 0,
            height: 40,
            onResize: (_, __) {},
            onToggleComplete: () {},
            onDelete: () {},
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('TimeBlockWidget', () {
    testWidgets('displays block title', (tester) async {
      await tester.pumpWidget(_buildBlock(_block()));
      expect(find.text('Standup'), findsOneWidget);
    });

    testWidgets('shows strikethrough when completed', (tester) async {
      await tester
          .pumpWidget(_buildBlock(_block(status: TimeBlockStatus.completed)));
      final text = tester.widget<Text>(find.text('Standup'));
      expect(text.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('no strikethrough when scheduled', (tester) async {
      await tester.pumpWidget(_buildBlock(_block()));
      final text = tester.widget<Text>(find.text('Standup'));
      expect(text.style?.decoration, isNull);
    });

    testWidgets('shows check_circle icon when completed', (tester) async {
      await tester
          .pumpWidget(_buildBlock(_block(status: TimeBlockStatus.completed)));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('no check_circle icon when scheduled', (tester) async {
      await tester.pumpWidget(_buildBlock(_block()));
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('long press shows options bottom sheet', (tester) async {
      await tester.pumpWidget(_buildBlock(_block()));
      await tester.longPress(find.text('Standup'));
      await tester.pumpAndSettle();
      expect(find.text('Mark complete'), findsOneWidget);
      expect(find.text('Delete block'), findsOneWidget);
    });

    testWidgets('long press on completed block shows Mark incomplete',
        (tester) async {
      await tester
          .pumpWidget(_buildBlock(_block(status: TimeBlockStatus.completed)));
      await tester.longPress(find.text('Standup'));
      await tester.pumpAndSettle();
      expect(find.text('Mark incomplete'), findsOneWidget);
    });
  });
}
