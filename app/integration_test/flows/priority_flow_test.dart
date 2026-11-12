import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfocus/main.dart';

void main() {
  patrolTest('Add 3 priorities as free user, 4th triggers premium gate', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    for (final title in ['Exercise', 'Read', 'Code']) {
      await $(TextField).tap();
      await $.tester.enterText(find.byType(TextField).last, title);
      await $.tester.testTextInput.receiveAction(TextInputAction.done);
      await $.pumpAndSettle();
    }

    expect($('Exercise'), findsOneWidget);
    expect($('Read'), findsOneWidget);
    expect($('Code'), findsOneWidget);

    await $(TextField).tap();
    await $.tester.enterText(find.byType(TextField).last, 'Extra');
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndSettle();

    expect($('Upgrade to Premium'), findsWidgets);
  });

  patrolTest('Toggle priority done shows check icon', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    await $(TextField).tap();
    await $.tester.enterText(find.byType(TextField).last, 'Test task');
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndSettle();

    expect($('Test task'), findsOneWidget);

    await $(Icons.circle_outlined).tap();
    await $.pumpAndSettle();

    expect($(Icons.check_circle), findsOneWidget);
  });
}
