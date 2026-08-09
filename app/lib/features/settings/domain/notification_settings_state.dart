import 'package:flutter/material.dart' show TimeOfDay;

class NotificationSettingsState {
  final bool morningEnabled;
  final TimeOfDay morningTime;
  final bool eveningEnabled;
  final TimeOfDay eveningTime;

  const NotificationSettingsState({
    this.morningEnabled = false,
    this.morningTime = const TimeOfDay(hour: 8, minute: 0),
    this.eveningEnabled = false,
    this.eveningTime = const TimeOfDay(hour: 18, minute: 0),
  });

  NotificationSettingsState copyWith({
    bool? morningEnabled,
    TimeOfDay? morningTime,
    bool? eveningEnabled,
    TimeOfDay? eveningTime,
  }) =>
      NotificationSettingsState(
        morningEnabled: morningEnabled ?? this.morningEnabled,
        morningTime: morningTime ?? this.morningTime,
        eveningEnabled: eveningEnabled ?? this.eveningEnabled,
        eveningTime: eveningTime ?? this.eveningTime,
      );
}
