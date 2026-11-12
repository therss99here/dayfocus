import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/core/database/app_database.dart';
import 'package:dayfocus/core/providers/database_providers.dart';
import 'package:dayfocus/features/premium/presentation/providers/premium_provider.dart';
import 'package:dayfocus/features/priorities/data/priority_repository.dart';
import 'package:dayfocus/features/sync/presentation/providers/sync_provider.dart';
import 'package:dayfocus/features/timeline/data/time_block_repository.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

ProviderScope createTestProviderScope({
  required Widget child,
  AppDatabase? database,
  bool isPremium = false,
  List<Override> extraOverrides = const [],
}) {
  final db = database ?? createTestDatabase();
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      priorityRepositoryProvider
          .overrideWithValue(PriorityRepository(db)),
      timeBlockRepositoryProvider
          .overrideWithValue(TimeBlockRepository(db)),
      premiumNotifierProvider.overrideWith(() => _TestPremiumNotifier(isPremium)),
      syncNotifierProvider.overrideWith(() => _TestSyncNotifier()),
      ...extraOverrides,
    ],
    child: child,
  );
}

Future<void> pumpApp(
  WidgetTester tester, {
  required Widget child,
  AppDatabase? database,
  bool isPremium = false,
  List<Override> extraOverrides = const [],
}) async {
  await tester.pumpWidget(
    createTestProviderScope(
      database: database,
      isPremium: isPremium,
      extraOverrides: extraOverrides,
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
}

class _TestPremiumNotifier extends PremiumNotifier {
  _TestPremiumNotifier(this._isPremium);
  final bool _isPremium;

  @override
  Future<bool> build() async => _isPremium;
}

class _TestSyncNotifier extends SyncNotifier {
  @override
  Future<void> build() async {}
}
