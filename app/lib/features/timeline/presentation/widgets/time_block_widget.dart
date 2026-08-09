import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/time_block.dart';

class TimeBlockWidget extends StatefulWidget {
  const TimeBlockWidget({
    super.key,
    required this.block,
    required this.topOffset,
    required this.height,
    required this.onResize,
    required this.onToggleComplete,
    required this.onDelete,
  });

  final TimeBlockEntity block;
  final double topOffset;
  final double height;
  final void Function(int endHour, int endMinute) onResize;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  @override
  State<TimeBlockWidget> createState() => _TimeBlockWidgetState();
}

class _TimeBlockWidgetState extends State<TimeBlockWidget> {
  double _resizeDelta = 0;

  void _commitResize() {
    final slotsAdded = (_resizeDelta / AppSpacing.slotHeight).round();
    final newEndTotal = widget.block.endTotalMinutes + slotsAdded * 30;
    widget.onResize(newEndTotal ~/ 60, newEndTotal % 60);
    setState(() => _resizeDelta = 0);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.block.status.color;
    final dimColor = widget.block.status.dimColor;
    final isCompleted = widget.block.status == TimeBlockStatus.completed;
    final displayHeight =
        (widget.height + _resizeDelta).clamp(AppSpacing.slotHeight, 9999.0);

    return Positioned(
      top: widget.topOffset,
      left: AppSpacing.timelineLabelWidth + 2,
      right: 4,
      height: displayHeight,
      child: GestureDetector(
        onTap: widget.onToggleComplete,
        onLongPress: () => _showOptions(context),
        child: Container(
          decoration: BoxDecoration(
            color: dimColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 6, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.block.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? AppColors.textMuted : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.check_circle,
                          size: 11,
                          color: AppColors.stateCompleted,
                        ),
                      ),
                  ],
                ),
              ),
              // Resize handle — bottom strip
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (d) =>
                      setState(() => _resizeDelta += d.delta.dy),
                  onVerticalDragEnd: (_) => _commitResize(),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeRow,
                    child: Container(
                      height: 12,
                      alignment: Alignment.center,
                      child: Container(
                        width: 28,
                        height: 3,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                widget.block.status == TimeBlockStatus.completed
                    ? Icons.radio_button_unchecked
                    : Icons.check_circle_outline,
                color: AppColors.stateCompleted,
              ),
              title: Text(
                widget.block.status == TimeBlockStatus.completed
                    ? 'Mark incomplete'
                    : 'Mark complete',
              ),
              onTap: () {
                Navigator.of(context).pop();
                widget.onToggleComplete();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppColors.stateMissed),
              title: const Text('Delete block'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
