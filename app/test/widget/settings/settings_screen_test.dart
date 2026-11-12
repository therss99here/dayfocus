import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/features/settings/presentation/screens/settings_screen.dart';
import 'package:dayfocus/features/settings/presentation/providers/notification_settings_provider.dart';
import 'package:dayfocus/features/settings/domain/notification_settings_state.dart';
import 'package:dayfocus/features/premium/presentation/providers/premium_provider.dart';
import 'package:dayfocus/features/auth/presentation/providers/auth_provider.dart';
import 'package:dayfocus/features/sync/presentation/providers/sync_provider.dart';
import 'package:dayfocus/core/providers/app_info_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _TestPremiumNotifier extends PremiumNotifier {
  _TestPremiumNotifier(this._value);
  final bool _value;

  @override
  Future<bool> build() async => _value;
}

class _TestSyncNotifier extends SyncNotifier {
  @override
  Future<void> build() async {}
}

class _TestNotificationSettingsNotifier extends NotificationSettingsNotifier {
  @override
  Future<NotificationSettingsState> build() async =>
      const NotificationSettingsState();
}

Widget _buildApp({bool isPremium = false}) {
  return ProviderScope(
    overrides: [
      premiumNotifierProvider.overrideWith(() => _TestPremiumNotifier(isPremium)),
      currentUserProvider.overrideWithValue(null),
      syncNotifierProvider.overrideWith(() => _TestSyncNotifier()),
      notificationSettingsNotifierProvider
          .overrideWith(() => _TestNotificationSettingsNotifier()),
      appInfoProvider.overrideWith(
        (ref) async => PackageInfo(
          appName: 'dayfocus',
          packageName: 'app.dayfocus.ios',
          version: '1.4.6',
          buildNumber: '1',
        ),
      ),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('shows Settings in app bar', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows PREMIUM section header', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('PREMIUM'), findsOneWidget);
    });

    testWidgets('shows Upgrade to Premium when not premium', (tester) async {
      await tester.pumpWidget(_buildApp(isPremium: false));
      await tester.pumpAndSettle();
      expect(find.text('Upgrade to Premium'), findsOneWidget);
    });

    testWidgets('shows Dayfocus Pro Active when premium', (tester) async {
      await tester.pumpWidget(_buildApp(isPremium: true));
      await tester.pumpAndSettle();
      expect(find.text('Dayfocus Pro'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows SYNC & ACCOUNT with Connect & Sync when signed out',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('SYNC & ACCOUNT'), findsOneWidget);
      expect(find.text('Connect & Sync'), findsOneWidget);
    });

    testWidgets('shows NOTIFICATIONS section', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('NOTIFICATIONS'), findsOneWidget);
      expect(find.text('Morning reminder'), findsOneWidget);
      expect(find.text('Evening review'), findsOneWidget);
    });

    testWidgets('shows FEEDBACK section with bug report and feedback',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      expect(find.text('FEEDBACK'), findsOneWidget);
      expect(find.text('Report a Bug'), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('shows ABOUT section with terms, privacy, version',
        (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();
      // Scroll down to make the ABOUT section visible
      await tester.scrollUntilVisible(find.text('ABOUT'), 200);
      await tester.pumpAndSettle();
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('Terms of Use'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('1.4.6'), findsOneWidget);
    });
  });
}
