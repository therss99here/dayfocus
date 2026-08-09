import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/priority_drag_data.dart';

class TimeSlotRow extends StatefulWidget {
  const TimeSlotRow({
    super.key,
    required this.hour,
    required this.minute,
    required this.isOnHour,
    required this.label,
    required this.onDrop,
    required this.onCreate,
  });

  final int hour;
  final int minute;
  final bool isOnHour;
  final String label;
  final void Function(PriorityDragData data) onDrop;
  final void Function(String title) onCreate;

  @override
  State<TimeSlotRow> createState() => _TimeSlotRowState();
}

class _TimeSlotRowState extends State<TimeSlotRow> {
  bool _isEditing = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        setState(() => _isEditing = false);
        _controller.clear();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _submit(String value) {
    final title = value.trim();
    setState(() => _isEditing = false);
    _controller.clear();
    if (title.isNotEmpty) widget.onCreate(title);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.slotHeight,
      child: DragTarget<PriorityDragData>(
        onAcceptWithDetails: (d) => widget.onDrop(d.data),
        builder: (context, candidates, _) {
          final isHovered = candidates.isNotEmpty;
          return Row(
            children: [
              _TimeLabel(label: widget.label, isOnHour: widget.isOnHour),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _isEditing ? null : _startEditing,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: isHovered ? AppColors.accentDim : Colors.transparent,
                      border: Border(
                        top: BorderSide(
                          color: widget.isOnHour
                              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.55)
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    alignment: Alignment.centerLeft,
                    child: _isEditing
                        ? TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: const TextStyle(fontSize: 13),
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Block title...',
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: _submit,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.label, required this.isOnHour});

  final String label;
  final bool isOnHour;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.timelineLabelWidth,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          label,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: isOnHour ? 12 : 10,
            fontWeight: isOnHour ? FontWeight.w500 : FontWeight.w400,
            color: isOnHour
                ? AppColors.textMuted
                : AppColors.textMuted.withValues(alpha: 0.35),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
