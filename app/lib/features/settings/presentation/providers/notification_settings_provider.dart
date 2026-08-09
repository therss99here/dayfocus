import 'package:flutter/material.dart' show TimeOfDay;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/notification_providers.dart';
import '../../domain/notification_settings_state.dart';

part 'notification_settings_provider.g.dart';

// SharedPreferences keys
const _kMorningEnabled = 'notif_morning_enabled';
const _kMorningHour = 'notif_morning_hour';
const _kMorningMinute = 'notif_morning_minute';
const _kEveningEnabled = 'notif_evening_enabled';
const _kEveningHour = 'notif_evening_hour';
const _kEveningMinute = 'notif_evening_minute';

@riverpod
class NotificationSettingsNotifier
    extends _$NotificationSettingsNotifier {
  @override
  Future<NotificationSettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettingsState(
      morningEnabled: prefs.getBool(_kMorningEnabled) ?? false,
      morningTime: TimeOfDay(
        hour: prefs.getInt(_kMorningHour) ?? 8,
        minute: prefs.getInt(_kMorningMinute) ?? 0,
      ),
      eveningEnabled: prefs.getBool(_kEveningEnabled) ?? false,
      eveningTime: TimeOfDay(
        hour: prefs.getInt(_kEveningHour) ?? 18,
        minute: prefs.getInt(_kEveningMinute) ?? 0,
      ),
    );
  }

  Future<void> setMorningEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationSettingsState();
    state = AsyncData(current.copyWith(morningEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMorningEnabled, enabled);
    final notif = ref.read(notificationServiceProvider);
    if (enabled) {
      await notif.scheduleMorningReminder(current.morningTime);
    } else {
      await notif.cancelMorningReminder();
    }
  }

  Future<void> setMorningTime(TimeOfDay time) async {
    final current = state.valueOrNull ?? const NotificationSettingsState();
    state = AsyncData(current.copyWith(morningTime: time));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kMorningHour, time.hour);
    await prefs.setInt(_kMorningMinute, time.minute);
    if (current.morningEnabled) {
      await ref.read(notificationServiceProvider).scheduleMorningReminder(time);
    }
  }

  Future<void> setEveningEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationSettingsState();
    state = AsyncData(current.copyWith(eveningEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEveningEnabled, enabled);
    final notif = ref.read(notificationServiceProvider);
    if (enabled) {
      await notif.scheduleEveningReview(current.eveningTime);
    } else {
      await notif.cancelEveningReview();
    }
  }

  Future<void> setEveningTime(TimeOfDay time) async {
    final current = state.valueOrNull ?? const NotificationSettingsState();
    state = AsyncData(current.copyWith(eveningTime: time));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kEveningHour, time.hour);
    await prefs.setInt(_kEveningMinute, time.minute);
    if (current.eveningEnabled) {
      await ref.read(notificationServiceProvider).scheduleEveningReview(time);
    }
  }
}
