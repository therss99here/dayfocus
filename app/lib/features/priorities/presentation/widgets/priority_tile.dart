import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/priority_drag_data.dart';
import '../../../timeline/presentation/providers/timeline_provider.dart';
import '../../domain/entities/priority_entity.dart';
import '../providers/priorities_provider.dart';

class PriorityTile extends ConsumerWidget {
  const PriorityTile({
    super.key,
    required this.priority,
    required this.index,
  });

  final PriorityEntity priority;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(prioritiesNotifierProvider.notifier);
    final timelineNotifier = ref.read(timelineNotifierProvider.notifier);

    // Derive linked-block indicator from timeline state (no linkedBlockId on entity).
    final blocks = ref.watch(timelineNotifierProvider).valueOrNull ?? [];
    final isLinked = blocks.any((b) => b.priorityId == priority.id);

    void onToggle() {
      final newDone = !priority.isDone;
      notifier.toggleDone(priority.id);
      if (isLinked) {
        timelineNotifier.syncFromPriority(priority.id, newDone);
      }
    }

    final body = _TileBody(
      priority: priority,
      isLinked: isLinked,
      onToggle: onToggle,
    );

    // Key must be on the outermost widget returned to ReorderableListView.
    return Padding(
      key: ValueKey(priority.id),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Main body — Draggable onto the timeline
          Expanded(
            child: Draggable<PriorityDragData>(
              data: PriorityDragData(id: priority.id, title: priority.title),
              feedback: _DragFeedback(title: priority.title),
              childWhenDragging: Opacity(opacity: 0.35, child: body),
              child: body,
            ),
          ),
          // Reorder handle — separate from Draggable to avoid gesture conflict
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Icon(
                Icons.drag_indicator,
                size: 14,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TileBody extends StatelessWidget {
  const _TileBody({
    required this.priority,
    required this.isLinked,
    required this.onToggle,
  });

  final PriorityEntity priority;
  final bool isLinked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              priority.isDone ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: priority.isDone
                  ? AppColors.stateCompleted
                  : AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            priority.title,
            style: TextStyle(
              fontSize: 13,
              decoration: priority.isDone ? TextDecoration.lineThrough : null,
              color: priority.isDone ? AppColors.textMuted : null,
            ),
          ),
        ),
        if (isLinked)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              Icons.link,
              size: 11,
              color: AppColors.stateScheduled.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: const Border.fromBorderSide(
            BorderSide(color: AppColors.accent, width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time, size: 13, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
