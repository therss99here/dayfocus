import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/features/priorities/domain/entities/priority_entity.dart';
import 'package:dayfocus/features/priorities/presentation/widgets/priority_tile.dart';
import 'package:dayfocus/features/priorities/presentation/providers/priorities_provider.dart';
import 'package:dayfocus/features/premium/presentation/providers/premium_provider.dart';
import 'package:dayfocus/features/sync/presentation/providers/sync_provider.dart';
import 'package:dayfocus/features/timeline/presentation/providers/timeline_provider.dart';
import 'package:dayfocus/features/timeline/domain/entities/time_block.dart';

class _TestPrioritiesNotifier extends PrioritiesNotifier {
  @override
  Stream<List<PriorityEntity>> build() async* {
    yield [];
  }

  @override
  Future<void> toggleDone(String id) async {}
}

class _TestPremiumNotifier extends PremiumNotifier {
  @override
  Future<bool> build() async => false;
}

class _TestSyncNotifier extends SyncNotifier {
  @override
  Future<void> build() async {}
}

class _TestTimelineNotifier extends TimelineNotifier {
  _TestTimelineNotifier(this._blocks);
  final List<TimeBlockEntity> _blocks;

  @override
  Stream<List<TimeBlockEntity>> build() async* {
    yield _blocks;
  }

  @override
  Future<void> syncFromPriority(String priorityId, bool isDone) async {}
}

Widget _buildTile(
  PriorityEntity priority, {
  List<TimeBlockEntity> blocks = const [],
}) {
  return ProviderScope(
    overrides: [
      prioritiesNotifierProvider
          .overrideWith(() => _TestPrioritiesNotifier()),
      premiumNotifierProvider.overrideWith(() => _TestPremiumNotifier()),
      syncNotifierProvider.overrideWith(() => _TestSyncNotifier()),
      timelineNotifierProvider
          .overrideWith(() => _TestTimelineNotifier(blocks)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ReorderableListView(
          onReorder: (_, __) {},
          children: [
            PriorityTile(
              key: ValueKey(priority.id),
              priority: priority,
              index: 0,
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('PriorityTile', () {
    const base = PriorityEntity(id: 'p1', title: 'Exercise', sortOrder: 0);

    testWidgets('displays priority title', (tester) async {
      await tester.pumpWidget(_buildTile(base));
      await tester.pumpAndSettle();
      expect(find.text('Exercise'), findsOneWidget);
    });

    testWidgets('shows circle_outlined icon when not done', (tester) async {
      await tester.pumpWidget(_buildTile(base));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    });

    testWidgets('shows check_circle icon when done', (tester) async {
      await tester.pumpWidget(_buildTile(base.copyWith(isDone: true)));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows strikethrough when done', (tester) async {
      await tester.pumpWidget(_buildTile(base.copyWith(isDone: true)));
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(find.text('Exercise'));
      expect(text.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('shows duration badge when estimatedMinutes set',
        (tester) async {
      await tester
          .pumpWidget(_buildTile(base.copyWith(estimatedMinutes: 30)));
      await tester.pumpAndSettle();
      expect(find.text('30m'), findsOneWidget);
    });

    testWidgets('shows hours for 90 min estimate', (tester) async {
      await tester
          .pumpWidget(_buildTile(base.copyWith(estimatedMinutes: 90)));
      await tester.pumpAndSettle();
      expect(find.text('1.5h'), findsOneWidget);
    });

    testWidgets('shows link icon when linked to time block', (tester) async {
      final linkedBlock = TimeBlockEntity(
        id: 'b1',
        title: 'Exercise',
        priorityId: 'p1',
        startHour: 10,
        startMinute: 0,
        endHour: 10,
        endMinute: 30,
      );
      await tester.pumpWidget(_buildTile(base, blocks: [linkedBlock]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('no link icon when not linked', (tester) async {
      await tester.pumpWidget(_buildTile(base));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.link), findsNothing);
    });

    testWidgets('shows drag handle', (tester) async {
      await tester.pumpWidget(_buildTile(base));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.drag_indicator), findsOneWidget);
    });
  });
}
