import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfocus/main.dart';

void main() {
  patrolTest('Create time block by tapping empty slot', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    // Find and tap the 10:00 slot
    await $('10:00').tap();
    await $.pumpAndSettle();

    // Type a block title
    await $(TextField).tap();
    await $.tester.enterText(find.byType(TextField).last, 'Standup');
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndSettle();

    // Block should appear
    expect($('Standup'), findsOneWidget);
  });

  patrolTest('Tap block toggles completion', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    // Create a block first
    await $('10:00').tap();
    await $.pumpAndSettle();
    await $(TextField).tap();
    await $.tester.enterText(find.byType(TextField).last, 'Deep work');
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndSettle();

    // Tap the block to toggle complete
    await $('Deep work').tap();
    await $.pumpAndSettle();

    // Block should be marked as completed (check icon should appear)
    expect($(Icons.check), findsWidgets);
  });

  patrolTest('Long-press block shows delete option', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    // Create a block
    await $('10:00').tap();
    await $.pumpAndSettle();
    await $(TextField).tap();
    await $.tester.enterText(find.byType(TextField).last, 'Review');
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
    await $.pumpAndSettle();

    // Long-press the block
    await $('Review').longPress();
    await $.pumpAndSettle();

    // Bottom sheet with delete option should appear
    expect($('Delete block'), findsOneWidget);
  });
}
