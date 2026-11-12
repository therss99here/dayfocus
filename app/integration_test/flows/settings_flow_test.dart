import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfocus/main.dart';

void main() {
  patrolTest('Settings screen shows all sections', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    // Navigate to settings
    await $(Icons.settings_outlined).tap();
    await $.pumpAndSettle();

    // Verify sections
    expect($('Settings'), findsOneWidget);
    expect($('PREMIUM'), findsOneWidget);
    expect($('Upgrade to Premium'), findsOneWidget);
    expect($('NOTIFICATIONS'), findsOneWidget);
    expect($('FEEDBACK'), findsOneWidget);
    expect($('Report a Bug'), findsOneWidget);
    expect($('Send Feedback'), findsOneWidget);
    expect($('ABOUT'), findsOneWidget);
    expect($('Terms of Use'), findsOneWidget);
    expect($('Privacy Policy'), findsOneWidget);
  });

  patrolTest('Notification toggles work', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    await $(Icons.settings_outlined).tap();
    await $.pumpAndSettle();

    // Toggle morning reminder on
    final switches = $(Switch);
    await switches.at(0).tap();
    await $.pumpAndSettle();

    // Time picker should appear
    expect($('Reminder time'), findsOneWidget);
  });
}
