import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum TimeBlockStatus { scheduled, inProgress, completed, missed }

extension TimeBlockStatusX on TimeBlockStatus {
  Color get color => switch (this) {
        TimeBlockStatus.scheduled => AppColors.stateScheduled,
        TimeBlockStatus.inProgress => AppColors.stateInProgress,
        TimeBlockStatus.completed => AppColors.stateCompleted,
        TimeBlockStatus.missed => AppColors.stateMissed,
      };

  Color get dimColor => switch (this) {
        TimeBlockStatus.scheduled => AppColors.stateScheduledDim,
        TimeBlockStatus.inProgress => AppColors.stateInProgressDim,
        TimeBlockStatus.completed => AppColors.stateCompletedDim,
        TimeBlockStatus.missed => AppColors.stateMissedDim,
      };
}

class TimeBlockEntity {
  final String id;
  final String title;
  final String? priorityId;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final TimeBlockStatus status;

  const TimeBlockEntity({
    required this.id,
    required this.title,
    this.priorityId,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    this.status = TimeBlockStatus.scheduled,
  });

  int get startTotalMinutes => startHour * 60 + startMinute;
  int get endTotalMinutes => endHour * 60 + endMinute;
  int get durationMinutes => endTotalMinutes - startTotalMinutes;

  TimeBlockEntity copyWith({
    String? title,
    String? priorityId,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    TimeBlockStatus? status,
  }) =>
      TimeBlockEntity(
        id: id,
        title: title ?? this.title,
        priorityId: priorityId ?? this.priorityId,
        startHour: startHour ?? this.startHour,
        startMinute: startMinute ?? this.startMinute,
        endHour: endHour ?? this.endHour,
        endMinute: endMinute ?? this.endMinute,
        status: status ?? this.status,
      );
}
