import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../analytics/data/analytics_service.dart';
import '../../../priorities/domain/entities/priority_entity.dart';
import '../../../priorities/presentation/providers/priorities_provider.dart';
import '../../../timeline/domain/entities/time_block.dart';
import '../../../timeline/presentation/providers/active_day_provider.dart';
import '../../../timeline/presentation/providers/timeline_provider.dart';
import '../../domain/day_summary.dart';
import 'share_bottom_sheet.dart';

class ShareButton extends ConsumerWidget {
  const ShareButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _onTap(context, ref),
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(Icons.ios_share, size: 17, color: AppColors.textMuted),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    AnalyticsService.trackShareTapped();

    final activeDay = ref.read(activeDayProvider);
    final priorities = ref.read(prioritiesNotifierProvider).valueOrNull
            ?.cast<PriorityEntity>() ??
        [];
    final blocks = ref.read(timelineNotifierProvider).valueOrNull
            ?.cast<TimeBlockEntity>() ??
        [];

    final summary = DaySummary(
      date: activeDay,
      priorities: priorities,
      timeBlocks: blocks,
    );

    showShareBottomSheet(context, summary: summary);
  }
}
