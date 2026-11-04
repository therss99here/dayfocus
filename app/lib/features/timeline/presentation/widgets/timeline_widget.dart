import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../premium/domain/premium_limits.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
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

  int _startHour(bool isPremium) => isPremium
      ? PremiumLimits.premiumStartHour
      : PremiumLimits.freeStartHour;

  int _endHour(bool isPremium) => isPremium
      ? PremiumLimits.premiumEndHour
      : PremiumLimits.freeEndHour;

  List<TimeSlot> _slots(bool isPremium) =>
      TimeSlot.generate(startHour: _startHour(isPremium), endHour: _endHour(isPremium));

  double _totalHeight(bool isPremium) =>
      _slots(isPremium).length * AppSpacing.slotHeight;

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
    final isPremium =
        ref.read(premiumNotifierProvider).valueOrNull ?? false;
    final now = DateTime.now();
    final minutesFromStart = now.hour * 60 + now.minute - _startHour(isPremium) * 60;
    if (minutesFromStart < 0) return;
    final offset =
        minutesFromStart / 30 * AppSpacing.slotHeight - 120;
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _showOverlapSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This time slot overlaps with an existing block'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  double _timeToOffset(int hour, int minute, bool isPremium) {
    final minutes = (hour * 60 + minute) - _startHour(isPremium) * 60;
    return minutes / 30 * AppSpacing.slotHeight;
  }

  double? _currentTimeOffset(DateTime now, bool isPremium) {
    final total = now.hour * 60 + now.minute;
    if (total < _startHour(isPremium) * 60 || total > _endHour(isPremium) * 60) return null;
    return _timeToOffset(now.hour, now.minute, isPremium);
  }

  @override
  Widget build(BuildContext context) {
    final blocks = ref.watch(timelineNotifierProvider).valueOrNull ?? [];
    final notifier = ref.read(timelineNotifierProvider.notifier);
    final prioritiesNotifier = ref.read(prioritiesNotifierProvider.notifier);
    final timeAsync = ref.watch(currentTimeProvider);
    final isPremium =
        ref.watch(premiumNotifierProvider).valueOrNull ?? false;
    final blockLimit = isPremium
        ? PremiumLimits.premiumTimeBlocksPerDay
        : PremiumLimits.freeTimeBlocksPerDay;

    final slots = _slots(isPremium);
    final totalHeight = _totalHeight(isPremium);

    return Column(
      children: [
        const _DayHeader(),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            controller: _scrollController,
            child: SizedBox(
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background: slot rows with drop targets
                  Column(
                    children: [
                      for (final slot in slots)
                        TimeSlotRow(
                          key: ValueKey('slot_${slot.hour}_${slot.minute}'),
                          hour: slot.hour,
                          minute: slot.minute,
                          isOnHour: slot.isOnHour,
                          label: slot.label,
                          isPremium: isPremium,
                          onDrop: (data, durationMinutes) {
                            if (!isPremium && blocks.length >= blockLimit) {
                              showPremiumGate(
                                context,
                                title: 'Time block limit reached',
                                message:
                                    'Free users can add up to $blockLimit time '
                                    'blocks per day. Upgrade to Premium for '
                                    'unlimited time blocks.',
                                source: 'time_block_limit',
                              );
                              return;
                            }
                            final duration = data.estimatedMinutes ?? durationMinutes;
                            notifier.addBlockFromPriority(
                              priorityId: data.id,
                              title: data.title,
                              startHour: slot.hour,
                              startMinute: slot.minute,
                              durationMinutes: duration,
                            ).then((id) {
                              if (id == null && context.mounted) {
                                _showOverlapSnackbar(context);
                              }
                            });
                          },
                          onCreate: (title, durationMinutes) {
                            if (!isPremium && blocks.length >= blockLimit) {
                              showPremiumGate(
                                context,
                                title: 'Time block limit reached',
                                message:
                                    'Free users can add up to $blockLimit time '
                                    'blocks per day. Upgrade to Premium for '
                                    'unlimited time blocks.',
                                source: 'time_block_limit',
                              );
                              return;
                            }
                            notifier.addBlock(
                              title: title,
                              startHour: slot.hour,
                              startMinute: slot.minute,
                              durationMinutes: durationMinutes,
                            ).then((ok) {
                              if (!ok && context.mounted) {
                                _showOverlapSnackbar(context);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  // Foreground: positioned time blocks
                  for (final block in blocks)
                    TimeBlockWidget(
                      key: ValueKey(block.id),
                      block: block,
                      topOffset:
                          _timeToOffset(block.startHour, block.startMinute, isPremium),
                      height: block.durationMinutes /
                          30 *
                          AppSpacing.slotHeight,
                      onResize: (endH, endM) {
                        notifier.resizeBlock(block.id, endH, endM).then((ok) {
                          if (!ok && context.mounted) {
                            _showOverlapSnackbar(context);
                          }
                        });
                      },
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
                      final offset = _currentTimeOffset(now, isPremium);
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
    final isPremium =
        ref.watch(premiumNotifierProvider).valueOrNull ?? false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
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
            onTap: () {
              final previousDay =
                  activeDay.subtract(const Duration(days: 1));
              final daysBack = today.difference(previousDay).inDays;
              if (!isPremium &&
                  daysBack > PremiumLimits.freeHistoryDays) {
                showPremiumGate(
                  context,
                  title: 'History limit reached',
                  message:
                      'Free users can access the last '
                      '${PremiumLimits.freeHistoryDays} days. '
                      'Upgrade to Premium for full history.',
                  source: 'history_limit',
                );
                return;
              }
              notifier.previous();
            },
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
