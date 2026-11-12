import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/core/database/app_database.dart';
import 'package:dayfocus/core/providers/database_providers.dart';
import 'package:dayfocus/features/priorities/presentation/widgets/add_priority_field.dart';
import 'package:dayfocus/features/premium/presentation/providers/premium_provider.dart';
import 'package:dayfocus/features/sync/presentation/providers/sync_provider.dart';

class _TestPremiumNotifier extends PremiumNotifier {
  _TestPremiumNotifier(this._value);
  final bool _value;

  @override
  Future<bool> build() async => _value;
}

class _TestSyncNotifier extends SyncNotifier {
  @override
  Future<void> build() async {}
}

Widget _buildField({bool isPremium = false}) {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      premiumNotifierProvider
          .overrideWith(() => _TestPremiumNotifier(isPremium)),
      syncNotifierProvider.overrideWith(() => _TestSyncNotifier()),
    ],
    child: const MaterialApp(
      home: Scaffold(body: AddPriorityField()),
    ),
  );
}

void main() {
  group('AddPriorityField', () {
    testWidgets('shows text field with hint', (tester) async {
      await tester.pumpWidget(_buildField());
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Add a priority...'), findsOneWidget);
    });

    testWidgets('shows add icon', (tester) async {
      await tester.pumpWidget(_buildField());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('empty submission does not add priority', (tester) async {
      await tester.pumpWidget(_buildField());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      // Should still show the text field (not a duration picker)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('typing text shows in field', (tester) async {
      await tester.pumpWidget(_buildField());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'New task');
      expect(find.text('New task'), findsOneWidget);
    });
  });
}
