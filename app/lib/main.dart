import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/notifications/notification_service.dart';
import 'core/providers/notification_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/premium/data/premium_service.dart';
import 'features/timeline/presentation/providers/active_day_provider.dart';
import 'features/timeline/presentation/providers/timeline_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await PremiumService.initialize();

  // Supabase is only initialised when credentials are present (env.json filled).
  if (AppConfig.isConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  runApp(const ProviderScope(child: DayfocusApp()));
}

class DayfocusApp extends ConsumerStatefulWidget {
  const DayfocusApp({super.key});

  @override
  ConsumerState<DayfocusApp> createState() => _DayfocusAppState();
}

class _DayfocusAppState extends ConsumerState<DayfocusApp> {
  ProviderSubscription<AsyncValue<List>>? _blockSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).requestPermission();
      _blockSub = ref.listenManual(
        timelineNotifierProvider,
        (_, next) => _syncNotifications(next),
        fireImmediately: true,
      );
    });
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
    _blockSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dayfocus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
