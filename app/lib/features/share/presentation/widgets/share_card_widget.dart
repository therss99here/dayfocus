import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../timeline/domain/entities/time_block.dart';
import '../../domain/day_summary.dart';

class ShareCardWidget extends StatelessWidget {
  const ShareCardWidget({super.key, required this.summary});

  final DaySummary summary;

  static const double cardWidth = 360;
  static const double cardHeight = 640;

  String _formatTime(int hour, int minute) {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, MMMM d').format(summary.date);

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.bgDark),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              decoration: const BoxDecoration(color: AppColors.accent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MyDayfocus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: summary.isEmpty
                    ? const _EmptyState()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (summary.priorities.isNotEmpty) ...[
                            const _SectionLabel('MY PRIORITIES'),
                            const SizedBox(height: 8),
                            ...summary.priorities.map(
                              (p) => _PriorityRow(
                                title: p.title,
                                isDone: p.isDone,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (summary.timeBlocks.isNotEmpty) ...[
                            const _SectionLabel('MY TIMELINE'),
                            const SizedBox(height: 8),
                            ...summary.timeBlocks.take(6).map(
                                  (b) => _BlockRow(
                                    title: b.title,
                                    time:
                                        '${_formatTime(b.startHour, b.startMinute)} – ${_formatTime(b.endHour, b.endMinute)}',
                                    status: b.status,
                                  ),
                                ),
                            if (summary.timeBlocks.length > 6)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '+${summary.timeBlocks.length - 6} more',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            _SummaryLine(summary: summary),
                          ],
                        ],
                      ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Icon(Icons.sunny,
                      size: 14,
                      color: AppColors.accent.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  const Text(
                    'Made with MyDayfocus',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sunny,
              size: 48, color: AppColors.accent.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Planning starts here',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({required this.title, required this.isDone});
  final String title;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 18,
            color: isDone ? AppColors.stateCompleted : AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDone
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                decoration:
                    isDone ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockRow extends StatelessWidget {
  const _BlockRow({
    required this.title,
    required this.time,
    required this.status,
  });
  final String title;
  final String time;
  final TimeBlockStatus status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.summary});
  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final hours = summary.totalScheduledMinutes ~/ 60;
    final mins = summary.totalScheduledMinutes % 60;
    final duration = hours > 0
        ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
        : '${mins}m';

    return Text(
      '${summary.completedBlocks}/${summary.totalBlocks} completed · $duration planned',
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textMuted,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
