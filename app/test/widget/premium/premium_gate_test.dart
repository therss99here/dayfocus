import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/features/premium/presentation/providers/premium_provider.dart';
import 'package:dayfocus/features/premium/presentation/widgets/premium_gate.dart';

import '../../helpers/test_helpers.dart';

void main() {
  Widget buildTestWidget() {
    return Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showPremiumGate(
          context,
          title: 'Test Title',
          message: 'Test message',
          source: 'test',
        ),
        child: const Text('Open Gate'),
      ),
    );
  }

  Future<void> openGate(WidgetTester tester) async {
    await pumpApp(
      tester,
      child: buildTestWidget(),
      extraOverrides: [
        premiumProductsProvider.overrideWith((ref) async => []),
      ],
    );
    await tester.tap(find.text('Open Gate'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the title and message', (tester) async {
    await openGate(tester);
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test message'), findsOneWidget);
  });

  testWidgets('shows diamond icon', (tester) async {
    await openGate(tester);
    expect(find.byIcon(Icons.diamond_rounded), findsOneWidget);
  });

  testWidgets('shows 3 benefit chips', (tester) async {
    await openGate(tester);
    expect(find.text('Unlimited'), findsOneWidget);
    expect(find.text('Full history'), findsOneWidget);
    expect(find.text('Sync'), findsOneWidget);
  });

  testWidgets('shows Upgrade to Premium CTA button', (tester) async {
    await openGate(tester);
    expect(find.text('Upgrade to Premium'), findsOneWidget);
  });

  testWidgets('shows Maybe later button', (tester) async {
    await openGate(tester);
    expect(find.text('Maybe later'), findsOneWidget);
  });

  testWidgets('tapping Maybe later dismisses the sheet', (tester) async {
    await openGate(tester);
    expect(find.text('Test Title'), findsOneWidget);
    await tester.tap(find.text('Maybe later'));
    await tester.pumpAndSettle();
    expect(find.text('Test Title'), findsNothing);
  });
}
