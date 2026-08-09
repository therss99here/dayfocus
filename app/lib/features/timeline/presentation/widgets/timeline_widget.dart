import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../priorities/presentation/providers/priorities_provider.dart';
import '../../domain/entities/time_block.dart';
import '../../domain/entities/time_slot.dart';
import '../providers/active_day_provider.dart';
import '../providers/timeline_provider.dart';
import 'current_time_indicator.dart';
import 'time_block_widget.dart';
import 'time_slot_row.dart';

class TimelineWidget extends ConsumerStatefulWidget {
  const TimelineWidget({super.key});

  @override
  ConsumerState<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends ConsumerState<TimelineWidget> {
  final _scrollController = ScrollController();

  static const _startHour = TimelineNotifier.defaultStartHour;
  static const _endHour = TimelineNotifier.defaultEndHour;
  static final _slots =
      TimeSlot.generate(startHour: _startHour, endHour: _endHour);
  static final _totalHeight = _slots.length * AppSpacing.slotHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToNow() {
    if (!_scrollController.hasClients) return;
    final now = DateTime.now();
    final minutesFromStart = now.hour * 60 + now.minute - _startHour * 60;
    if (minutesFromStart < 0) return;
    final offset =
        minutesFromStart / 30 * AppSpacing.slotHeight - 120;
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  double _timeToOffset(int hour, int minute) {
    final minutes = (hour * 60 + minute) - _startHour * 60;
    return minutes / 30 * AppSpacing.slotHeight;
  }

  double? _currentTimeOffset(DateTime now) {
    final total = now.hour * 60 + now.minute;
    if (total < _startHour * 60 || total > _endHour * 60) return null;
    return _timeToOffset(now.hour, now.minute);
  }

  @override
  Widget build(BuildContext context) {
    final blocks = ref.watch(timelineNotifierProvider).valueOrNull ?? [];
    final notifier = ref.read(timelineNotifierProvider.notifier);
    final prioritiesNotifier = ref.read(prioritiesNotifierProvider.notifier);
    final timeAsync = ref.watch(currentTimeProvider);

    return Column(
      children: [
        const _DayHeader(),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              height: _totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background: slot rows with drop targets
                  Column(
                    children: [
                      for (final slot in _slots)
                        TimeSlotRow(
                          key: ValueKey('slot_${slot.hour}_${slot.minute}'),
                          hour: slot.hour,
                          minute: slot.minute,
                          isOnHour: slot.isOnHour,
                          label: slot.label,
                          onDrop: (data) {
                            notifier.addBlockFromPriority(
                              priorityId: data.id,
                              title: data.title,
                              startHour: slot.hour,
                              startMinute: slot.minute,
                            );
                          },
                          onCreate: (title) => notifier.addBlock(
                            title: title,
                            startHour: slot.hour,
                            startMinute: slot.minute,
                          ),
                        ),
                    ],
                  ),
                  // Foreground: positioned time blocks
                  for (final block in blocks)
                    TimeBlockWidget(
                      key: ValueKey(block.id),
                      block: block,
                      topOffset:
                          _timeToOffset(block.startHour, block.startMinute),
                      height: block.durationMinutes /
                          30 *
                          AppSpacing.slotHeight,
                      onResize: (endH, endM) =>
                          notifier.resizeBlock(block.id, endH, endM),
                      onToggleComplete: () {
                        final wasDone =
                            block.status == TimeBlockStatus.completed;
                        notifier.toggleComplete(block.id);
                        if (block.priorityId != null) {
                          prioritiesNotifier.syncFromBlock(
                              block.priorityId!, !wasDone);
                        }
                      },
                      onDelete: () => notifier.removeBlock(block.id),
                    ),
                  // Current time indicator
                  timeAsync.when(
                    data: (now) {
                      final offset = _currentTimeOffset(now);
                      if (offset == null) return const SizedBox.shrink();
                      return CurrentTimeIndicator(topOffset: offset);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends ConsumerWidget {
  const _DayHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDay = ref.watch(activeDayProvider);
    final notifier = ref.read(activeDayProvider.notifier);
    final now = DateTime.now();
    final isToday = activeDay.year == now.year &&
        activeDay.month == now.month &&
        activeDay.day == now.day;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.chevron_left,
            onTap: notifier.previous,
          ),
          Expanded(
            child: GestureDetector(
              onTap: isToday ? null : notifier.goToToday,
              child: Text(
                isToday
                    ? 'Today'
                    : DateFormat('EEE, MMM d').format(activeDay),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isToday ? AppColors.accent : null,
                ),
              ),
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right,
            onTap: notifier.next,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: AppColors.textMuted),
      ),
    );
  }
}
