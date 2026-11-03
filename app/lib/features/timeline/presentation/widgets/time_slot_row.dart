import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/priority_drag_data.dart';
import '../../../premium/domain/premium_limits.dart';

class TimeSlotRow extends StatefulWidget {
  const TimeSlotRow({
    super.key,
    required this.hour,
    required this.minute,
    required this.isOnHour,
    required this.label,
    required this.onDrop,
    required this.onCreate,
    required this.isPremium,
  });

  final int hour;
  final int minute;
  final bool isOnHour;
  final String label;
  final void Function(PriorityDragData data, int durationMinutes) onDrop;
  final void Function(String title, int durationMinutes) onCreate;
  final bool isPremium;

  @override
  State<TimeSlotRow> createState() => _TimeSlotRowState();
}

class _TimeSlotRowState extends State<TimeSlotRow> {
  bool _isEditing = false;
  bool _pickingDuration = false;
  String _pendingTitle = '';
  int _selectedDuration = 30;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing && !_pickingDuration) {
        _reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _isEditing = false;
      _pickingDuration = false;
      _pendingTitle = '';
      _selectedDuration = 30;
    });
    _controller.clear();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _submit(String value) {
    final title = value.trim();
    if (title.isEmpty) {
      _reset();
      return;
    }

    if (widget.isPremium) {
      setState(() {
        _pendingTitle = title;
        _pickingDuration = true;
        _isEditing = false;
      });
    } else {
      widget.onCreate(title, PremiumLimits.freeBlockDurationMinutes);
      _reset();
    }
  }

  void _confirmDuration() {
    widget.onCreate(_pendingTitle, _selectedDuration);
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _pickingDuration ? AppSpacing.slotHeight + 44 : AppSpacing.slotHeight,
      child: DragTarget<PriorityDragData>(
        onAcceptWithDetails: (d) =>
            widget.onDrop(d.data, widget.isPremium ? _selectedDuration : PremiumLimits.freeBlockDurationMinutes),
        builder: (context, candidates, _) {
          final isHovered = candidates.isNotEmpty;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: AppSpacing.slotHeight,
                child: Row(
                  children: [
                    _TimeLabel(label: widget.label, isOnHour: widget.isOnHour),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: (_isEditing || _pickingDuration) ? null : _startEditing,
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
                                  decoration: const InputDecoration(
                                    hintText: 'Block title...',
                                    hintStyle: TextStyle(
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
                              : _pickingDuration
                                  ? Text(
                                      _pendingTitle,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_pickingDuration)
                _DurationPicker(
                  selectedDuration: _selectedDuration,
                  onSelect: (d) => setState(() => _selectedDuration = d),
                  onConfirm: _confirmDuration,
                  onCancel: _reset,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    required this.selectedDuration,
    required this.onSelect,
    required this.onConfirm,
    required this.onCancel,
  });

  final int selectedDuration;
  final ValueChanged<int> onSelect;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  static String _label(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '$h.${m == 30 ? '5' : m}h';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.timelineLabelWidth,
          right: 4,
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final d in PremiumLimits.premiumBlockDurationOptions)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => onSelect(d),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: selectedDuration == d
                                  ? AppColors.accent
                                  : Theme.of(context).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              _label(d),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selectedDuration == d
                                    ? Colors.white
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onCancel,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 18, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onConfirm,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.check, size: 18, color: AppColors.accent),
              ),
            ),
          ],
        ),
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
