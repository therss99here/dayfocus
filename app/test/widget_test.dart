import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dayfocus/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const ProviderScope(child: DayfocusApp(showOnboarding: false)),
      );
    });

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
