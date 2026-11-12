import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dayfocus/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const OnboardingScreen(),
          routes: {
            '/trial-offer': (_) => const Scaffold(body: Text('Trial Offer')),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Board')),
              );
            }
            return null;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows 3 page indicator dots', (tester) async {
    await pumpOnboarding(tester);
    final dots = find.byType(AnimatedContainer);
    expect(dots, findsNWidgets(3));
  });

  testWidgets('first page shows "Plan your day with focus"', (tester) async {
    await pumpOnboarding(tester);
    expect(find.textContaining('Plan your day'), findsOneWidget);
  });

  testWidgets('shows Continue button on first page', (tester) async {
    await pumpOnboarding(tester);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text("Let's go!"), findsNothing);
  });

  testWidgets('Skip button is visible on first page', (tester) async {
    await pumpOnboarding(tester);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('after swiping to page 3, shows Let\'s go! button',
      (tester) async {
    await pumpOnboarding(tester);

    // Swipe to page 2
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Swipe to page 3
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text("Let's go!"), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('Skip button is hidden on last page', (tester) async {
    await pumpOnboarding(tester);

    // Swipe to last page
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsNothing);
  });
}
