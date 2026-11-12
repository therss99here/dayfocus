import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfocus/main.dart';

void main() {
  patrolTest('Day header shows Today initially', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    expect($('Today'), findsOneWidget);
  });

  patrolTest('Navigate back one day changes date', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    await $(Icons.chevron_left).tap();
    await $.pumpAndSettle();

    // Should no longer show "Today"
    expect($('Today'), findsNothing);
  });

  patrolTest('Navigate forward unrestricted', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    await $(Icons.chevron_right).tap();
    await $.pumpAndSettle();

    // Should show tomorrow's date, no premium gate
    expect($('Today'), findsNothing);
    expect($('Upgrade to Premium'), findsNothing);
  });

  patrolTest('Tap date label returns to Today', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    // Navigate back
    await $(Icons.chevron_left).tap();
    await $.pumpAndSettle();

    // Tap the date to go back to today
    // The date text is the formatted date, find any text that isn't "Today"
    // and tap it to trigger goToToday()
    final dateTexts = find.textContaining(',');
    if (dateTexts.evaluate().isNotEmpty) {
      await $.tester.tap(dateTexts.first);
      await $.pumpAndSettle();
    }

    expect($('Today'), findsOneWidget);
  });
}
