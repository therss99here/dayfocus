import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfocus/main.dart';

void main() {
  patrolTest('Premium gate shows when navigating 8+ days back', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    // Navigate back 8 days using the back arrow
    for (var i = 0; i < 8; i++) {
      await $(Icons.chevron_left).tap();
      await $.pumpAndSettle();
    }

    // Premium gate should appear
    expect($('Upgrade to Premium'), findsWidgets);
  });

  patrolTest('Premium gate Maybe later dismisses the sheet', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    // Navigate back 8 days
    for (var i = 0; i < 8; i++) {
      await $(Icons.chevron_left).tap();
      await $.pumpAndSettle();
    }

    // Dismiss with Maybe later
    await $('Maybe later').tap();
    await $.pumpAndSettle();

    // Should still be on the board screen
    expect($('MyDayfocus'), findsOneWidget);
  });
}
