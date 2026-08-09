import 'dart:io';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../features/timeline/domain/entities/time_block.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _blockChannelId = 'block_alerts';
  static const _reminderChannelId = 'daily_reminders';
  static const _morningReminderId = 900001;
  static const _eveningReviewId = 900002;

  // ── Initialisation ────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      // Falls back to UTC; edge-case on some emulators.
    }

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    // Android notification channels (no-op on other platforms)
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      _blockChannelId,
      'Block Alerts',
      description: 'Start and overrun alerts for time blocks',
      importance: Importance.high,
    ));
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      _reminderChannelId,
      'Daily Reminders',
      description: 'Morning planning and evening review nudges',
      importance: Importance.defaultImportance,
    ));
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (Platform.isMacOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return true;
  }

  // ── Block notifications ───────────────────────────────────────────────────

  /// Cancel and reschedule all block notifications for [date].
  /// Call this whenever the block list changes (add / resize / delete / toggle).
  Future<void> rescheduleAll(
      List<TimeBlockEntity> blocks, DateTime date) async {
    final now = DateTime.now();

    for (final block in blocks) {
      await cancelForBlock(block.id);
      if (block.status == TimeBlockStatus.completed) continue;

      final startDt = DateTime(
          date.year, date.month, date.day, block.startHour, block.startMinute);
      final endDt = DateTime(
          date.year, date.month, date.day, block.endHour, block.endMinute);

      // 5-min start alert
      final alertAt = startDt.subtract(const Duration(minutes: 5));
      if (alertAt.isAfter(now)) {
        await _scheduleBlockStart(block, alertAt);
      }

      // Overrun warning at block end
      if (endDt.isAfter(now)) {
        await _scheduleBlockOverrun(block, endDt);
      }
    }
  }

  Future<void> cancelForBlock(String blockId) async {
    await _plugin.cancel(_startId(blockId));
    await _plugin.cancel(_overrunId(blockId));
  }

  Future<void> _scheduleBlockStart(
      TimeBlockEntity block, DateTime when) async {
    await _plugin.zonedSchedule(
      _startId(block.id),
      'Starting soon: ${block.title}',
      'Your ${block.title} block starts in 5 minutes.',
      _toTZ(when),
      _blockDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleBlockOverrun(
      TimeBlockEntity block, DateTime when) async {
    await _plugin.zonedSchedule(
      _overrunId(block.id),
      'Time\'s up: ${block.title}',
      'Your ${block.title} block has ended — time to wrap up!',
      _toTZ(when),
      _blockDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Daily reminders ───────────────────────────────────────────────────────

  Future<void> scheduleMorningReminder(TimeOfDay time) async {
    await _plugin.zonedSchedule(
      _morningReminderId,
      'Plan your day',
      'Your timebox is ready. What are today\'s top 3 priorities?',
      _nextInstanceOfTime(time),
      _reminderDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleEveningReview(TimeOfDay time) async {
    await _plugin.zonedSchedule(
      _eveningReviewId,
      'End-of-day review',
      'How did today go? Review your completed blocks.',
      _nextInstanceOfTime(time),
      _reminderDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelMorningReminder() => _plugin.cancel(_morningReminderId);
  Future<void> cancelEveningReview() => _plugin.cancel(_eveningReviewId);
  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Helpers ───────────────────────────────────────────────────────────────

  tz.TZDateTime _toTZ(DateTime dt) => tz.TZDateTime.from(dt, tz.local);

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  NotificationDetails _blockDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _blockChannelId,
          'Block Alerts',
          channelDescription: 'Start and overrun alerts for time blocks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(sound: 'default'),
        macOS: DarwinNotificationDetails(),
      );

  NotificationDetails _reminderDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          'Daily Reminders',
          channelDescription: 'Morning planning and evening review nudges',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(sound: 'default'),
        macOS: DarwinNotificationDetails(),
      );

  // Use bit-range partitioning so start/overrun IDs never collide.
  // Block IDs are UUIDs; map to 30-bit int, then flip bit 30 for overrun.
  int _startId(String id) => id.hashCode & 0x3FFFFFFF;
  int _overrunId(String id) => (id.hashCode & 0x3FFFFFFF) | 0x40000000;
}
