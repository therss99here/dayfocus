import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../share/domain/day_summary.dart';
import '../../timeline/domain/entities/time_block.dart';

class WidgetDataService {
  WidgetDataService._();

  static const _appGroupId = 'group.app.dayfocus.ios.widgets';
  static const _iOSWidgetName = 'DayfocusWidgets';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> syncToWidget(DaySummary summary) async {
    try {
      final nextBlock = _findNextBlock(summary.timeBlocks);

      final prioritiesJson = summary.priorities
          .map((p) => {
                'title': p.title,
                'isDone': p.isDone,
                'sortOrder': p.sortOrder,
              })
          .toList();

      await Future.wait([
        HomeWidget.saveWidgetData('priorities_json', jsonEncode(prioritiesJson)),
        HomeWidget.saveWidgetData(
            'completed_priorities', summary.completedPriorities),
        HomeWidget.saveWidgetData('total_priorities', summary.totalPriorities),
        HomeWidget.saveWidgetData('next_block_title', nextBlock?.title),
        HomeWidget.saveWidgetData(
            'next_block_time', nextBlock != null ? _formatTime(nextBlock) : null),
        HomeWidget.saveWidgetData(
            'next_block_status', nextBlock?.status.name),
        HomeWidget.saveWidgetData('completed_blocks', summary.completedBlocks),
        HomeWidget.saveWidgetData('total_blocks', summary.totalBlocks),
        HomeWidget.saveWidgetData('last_updated', DateTime.now().toIso8601String()),
      ]);

      await HomeWidget.updateWidget(iOSName: _iOSWidgetName);
    } catch (e) {
      debugPrint('[WidgetDataService] sync failed: $e');
    }
  }

  static TimeBlockEntity? _findNextBlock(List<TimeBlockEntity> blocks) {
    if (blocks.isEmpty) return null;
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    final sorted = [...blocks]
      ..sort((a, b) => a.startTotalMinutes.compareTo(b.startTotalMinutes));

    final inProgress =
        sorted.where((b) => b.status == TimeBlockStatus.inProgress).firstOrNull;
    if (inProgress != null) return inProgress;

    final upcoming = sorted
        .where((b) =>
            b.status == TimeBlockStatus.scheduled &&
            b.endTotalMinutes > nowMinutes)
        .firstOrNull;
    return upcoming;
  }

  static String _formatTime(TimeBlockEntity block) {
    String fmt(int h, int m) {
      final period = h >= 12 ? 'PM' : 'AM';
      final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '${hour.toString()}:${m.toString().padLeft(2, '0')} $period';
    }

    return '${fmt(block.startHour, block.startMinute)} - ${fmt(block.endHour, block.endMinute)}';
  }
}
