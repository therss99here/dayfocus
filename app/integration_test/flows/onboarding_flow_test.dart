import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfocus/main.dart';

void main() {
  patrolTest('First launch shows onboarding, complete flow reaches board', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: true)),
    );

    // Page 1: verify content
    expect($('Plan your day with focus'), findsOneWidget);
    expect($('Continue'), findsOneWidget);
    expect($('Skip'), findsOneWidget);

    // Navigate to page 2
    await $('Continue').tap();
    await $.pumpAndSettle();

    expect($('Set priorities, then timebox'), findsOneWidget);

    // Navigate to page 3
    await $('Continue').tap();
    await $.pumpAndSettle();

    expect($('Complete & reflect'), findsOneWidget);
    expect($("Let's go!"), findsOneWidget);
    // Skip button hidden on page 3
    expect($('Skip'), findsNothing);
  });

  patrolTest('Skip on page 1 goes directly to board', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: true)),
    );

    await $('Skip').tap();
    await $.pumpAndSettle();

    // Should be on the board screen now
    expect($('MyDayfocus'), findsOneWidget);
  });
}
