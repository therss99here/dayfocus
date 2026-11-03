import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../../../core/config/app_config.dart';

class AnalyticsService {
  static bool _initialized = false;

  static bool get isConfigured =>
      AppConfig.posthogApiKey.isNotEmpty && _initialized;

  static Future<void> initialize() async {
    if (AppConfig.posthogApiKey.isEmpty) return;

    try {
      final config = PostHogConfig(AppConfig.posthogApiKey);
      config.host = 'https://us.i.posthog.com';
      config.captureApplicationLifecycleEvents = true;
      config.debug = kDebugMode;
      await Posthog().setup(config);
      _initialized = true;
      debugPrint('[AnalyticsService] Initialized successfully');
    } catch (e) {
      debugPrint('[AnalyticsService] Failed to initialize: $e');
      _initialized = false;
    }
  }

  static void identify(String userId) {
    if (!isConfigured) return;
    Posthog().identify(userId: userId);
  }

  static void reset() {
    if (!isConfigured) return;
    Posthog().reset();
  }

  static void _track(String event, [Map<String, Object>? properties]) {
    if (!isConfigured) return;
    Posthog().capture(eventName: event, properties: properties);
  }

  static void trackScreen(String name) =>
      _track('\$screen', {'\$screen_name': name});

  static void trackAppOpened() => _track('app_opened');

  static void trackPriorityToggled({required bool isDone}) =>
      _track('priority_toggled', {'is_done': isDone});

  static void trackTimeBlockCompleted() => _track('time_block_completed');

  static void trackTimeBlockCreated() => _track('time_block_created');

  static void trackAllPrioritiesDone() => _track('all_priorities_done');

  static void trackPaywallViewed({required String source}) =>
      _track('paywall_viewed', {'source': source});

  static void trackTrialStarted({required String productId}) =>
      _track('trial_started', {'product_id': productId});

  static void trackPurchaseCompleted({required String productId}) =>
      _track('purchase_completed', {'product_id': productId});

  static void trackPurchaseCancelled() => _track('purchase_cancelled');

  static void trackOnboardingCompleted({required int page}) =>
      _track('onboarding_completed', {'page': page});

  static void trackOnboardingSkipped({required int page}) =>
      _track('onboarding_skipped', {'page': page});
}
