import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/notifications/notification_service.dart';
import 'core/providers/notification_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/premium/data/premium_service.dart';
import 'features/sync/presentation/providers/sync_provider.dart';
import 'features/timeline/presentation/providers/active_day_provider.dart';
import 'features/timeline/presentation/providers/timeline_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('[Main] NotificationService init failed: $e');
  }

  try {
    await PremiumService.initialize();
  } catch (e) {
    debugPrint('[Main] PremiumService init failed: $e');
  }

  // Supabase is only initialised when credentials are present (env.json filled).
  if (AppConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('[Main] Supabase init failed: $e');
    }
  }

  runApp(const ProviderScope(child: DayfocusApp()));
}

class DayfocusApp extends ConsumerStatefulWidget {
  const DayfocusApp({super.key});

  @override
  ConsumerState<DayfocusApp> createState() => _DayfocusAppState();
}

class _DayfocusAppState extends ConsumerState<DayfocusApp>
    with WidgetsBindingObserver {
  ProviderSubscription<AsyncValue<List>>? _blockSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).requestPermission();
      _blockSub = ref.listenManual(
        timelineNotifierProvider,
        (_, next) => _syncNotifications(next),
        fireImmediately: true,
      );

      // Initial sync on app launch (if signed in)
      if (AppConfig.isConfigured) {
        ref.read(syncNotifierProvider.notifier).syncNow();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint('[Main] App resumed - triggering sync');
      ref.read(syncNotifierProvider.notifier).syncOnResume();
    }
  }

  void _syncNotifications(AsyncValue<dynamic> next) {
    final activeDay = ref.read(activeDayProvider);
    final now = DateTime.now();
    final isToday = activeDay.year == now.year &&
        activeDay.month == now.month &&
        activeDay.day == now.day;
    if (!isToday) return;
    final blocks = next.valueOrNull ?? [];
    ref.read(notificationServiceProvider).rescheduleAll(
          List.from(blocks),
          activeDay,
        );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _blockSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MyDayfocus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
