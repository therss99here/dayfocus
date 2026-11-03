import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const _kLastPromptDate = 'review_last_prompt_date';
  static const _kLifetimePrompts = 'review_lifetime_prompts';
  static const _kFirstDayTriggered = 'review_first_day_triggered';
  static const _kAllPrioritiesCount = 'review_all_priorities_count';

  static const _cooldownDays = 60;
  static const _maxLifetimePrompts = 3;
  static const _maxAllPrioritiesTriggers = 3;

  static Future<bool> maybeRequestReview({required String trigger}) async {
    final prefs = await SharedPreferences.getInstance();

    final lifetimePrompts = prefs.getInt(_kLifetimePrompts) ?? 0;
    if (lifetimePrompts >= _maxLifetimePrompts) return false;

    final lastPrompt = prefs.getString(_kLastPromptDate);
    if (lastPrompt != null) {
      final lastDate = DateTime.tryParse(lastPrompt);
      if (lastDate != null &&
          DateTime.now().difference(lastDate).inDays < _cooldownDays) {
        return false;
      }
    }

    if (trigger == 'first_day_complete') {
      if (prefs.getBool(_kFirstDayTriggered) ?? false) return false;
      await prefs.setBool(_kFirstDayTriggered, true);
    }

    if (trigger == 'all_priorities_done') {
      final count = prefs.getInt(_kAllPrioritiesCount) ?? 0;
      if (count >= _maxAllPrioritiesTriggers) return false;
      await prefs.setInt(_kAllPrioritiesCount, count + 1);
    }

    final inAppReview = InAppReview.instance;
    if (!await inAppReview.isAvailable()) return false;

    debugPrint('[ReviewService] Requesting review (trigger: $trigger)');
    await inAppReview.requestReview();
    await prefs.setString(_kLastPromptDate, DateTime.now().toIso8601String());
    await prefs.setInt(_kLifetimePrompts, lifetimePrompts + 1);
    return true;
  }
}
