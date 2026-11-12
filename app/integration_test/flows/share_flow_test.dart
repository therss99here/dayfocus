import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayfocus/main.dart';

void main() {
  patrolTest('Share button opens share bottom sheet', ($) async {
    await $.pumpWidgetAndSettle(
      const ProviderScope(child: DayfocusApp(showOnboarding: false)),
    );

    // Tap share button (iOS share icon)
    await $(Icons.ios_share).tap();
    await $.pumpAndSettle();

    // Bottom sheet should show two options
    expect($('Share your day'), findsOneWidget);
    expect($('Share as Text'), findsOneWidget);
    expect($('Share as Image'), findsOneWidget);
  });
}
