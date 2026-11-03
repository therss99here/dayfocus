import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/notifications/notification_service.dart';
import 'core/providers/notification_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/data/analytics_service.dart';
import 'features/analytics/data/review_service.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/premium/data/premium_service.dart';
import 'features/priorities/presentation/providers/priorities_provider.dart';
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

  try {
    await AnalyticsService.initialize();
  } catch (e) {
    debugPrint('[Main] AnalyticsService init failed: $e');
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

  final showOnboarding = !await isOnboardingCompleted();

  runApp(ProviderScope(child: DayfocusApp(showOnboarding: showOnboarding)));
}

class DayfocusApp extends ConsumerStatefulWidget {
  const DayfocusApp({super.key, required this.showOnboarding});

  final bool showOnboarding;

  @override
  ConsumerState<DayfocusApp> createState() => _DayfocusAppState();
}

class _DayfocusAppState extends ConsumerState<DayfocusApp>
    with WidgetsBindingObserver {
  ProviderSubscription<AsyncValue<List>>? _blockSub;
  ProviderSubscription? _prioritySub;

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
      _prioritySub = ref.listenManual(
        prioritiesNotifierProvider,
        (prev, next) => _checkAllPrioritiesDone(prev, next),
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
      AnalyticsService.trackAppOpened();
      ref.read(syncNotifierProvider.notifier).syncOnResume();
    }
  }

  void _checkAllPrioritiesDone(AsyncValue<dynamic>? prev, AsyncValue<dynamic> next) {
    final list = next.valueOrNull as List?;
    if (list == null || list.isEmpty) return;
    final allDone = list.every((p) => p.isDone == true);
    if (!allDone) return;
    final prevList = prev?.valueOrNull as List?;
    if (prevList != null && prevList.every((p) => p.isDone == true)) return;
    AnalyticsService.trackAllPrioritiesDone();
    ReviewService.maybeRequestReview(trigger: 'all_priorities_done');
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
    _prioritySub?.close();
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
      routerConfig: buildRouter(showOnboarding: widget.showOnboarding),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    );
  }
}
