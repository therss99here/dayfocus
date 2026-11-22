import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../priorities/domain/entities/priority_entity.dart';
import '../../../priorities/presentation/providers/priorities_provider.dart';
import '../../../share/domain/day_summary.dart';
import '../../../timeline/domain/entities/time_block.dart';
import '../../../timeline/presentation/providers/active_day_provider.dart';
import '../../../timeline/presentation/providers/timeline_provider.dart';
import '../../data/widget_data_service.dart';

part 'widget_sync_provider.g.dart';

@riverpod
class WidgetSync extends _$WidgetSync {
  @override
  void build() {
    final activeDay = ref.watch(activeDayProvider);
    final now = DateTime.now();
    final isToday = activeDay.year == now.year &&
        activeDay.month == now.month &&
        activeDay.day == now.day;
    if (!isToday) return;

    final priorities = ref.watch(prioritiesNotifierProvider).valueOrNull;
    final blocks = ref.watch(timelineNotifierProvider).valueOrNull;
    if (priorities == null || blocks == null) return;

    final summary = DaySummary(
      date: activeDay,
      priorities: priorities.cast<PriorityEntity>(),
      timeBlocks: blocks.cast<TimeBlockEntity>(),
    );

    WidgetDataService.syncToWidget(summary);
  }
}
