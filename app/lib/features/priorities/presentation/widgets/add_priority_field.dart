import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../premium/domain/premium_limits.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../../premium/presentation/widgets/premium_gate.dart';
import '../providers/priorities_provider.dart';

class AddPriorityField extends ConsumerStatefulWidget {
  const AddPriorityField({super.key});

  @override
  ConsumerState<AddPriorityField> createState() => _AddPriorityFieldState();
}

class _AddPriorityFieldState extends ConsumerState<AddPriorityField> {
  final _controller = TextEditingController();
  bool _pickingDuration = false;
  String _pendingTitle = '';
  int _selectedDuration = 30;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _pickingDuration = false;
      _pendingTitle = '';
      _selectedDuration = 30;
    });
    _controller.clear();
  }

  void _submit(String value) {
    final title = value.trim();
    if (title.isEmpty) return;

    final count = ref.read(prioritiesNotifierProvider).valueOrNull?.length ?? 0;
    final isPremium =
        ref.read(premiumNotifierProvider).valueOrNull ?? false;

    if (count >= PremiumLimits.freePrioritiesPerDay) {
      if (!isPremium) {
        showPremiumGate(
          context,
          title: 'Priority limit reached',
          message:
              'Free users can add up to ${PremiumLimits.freePrioritiesPerDay} '
              'priorities per day. Upgrade to Premium for unlimited priorities.',
          source: 'priority_limit',
        );
        return;
      }
      _showLimitWarning(title);
    } else if (isPremium) {
      setState(() {
        _pendingTitle = title;
        _pickingDuration = true;
      });
    } else {
      _doAdd(title);
    }
  }

  void _doAdd(String title, {int? estimatedMinutes}) {
    ref.read(prioritiesNotifierProvider.notifier).add(
      title,
      estimatedMinutes: estimatedMinutes,
    );
    _reset();
  }

  void _confirmDuration() {
    _doAdd(_pendingTitle, estimatedMinutes: _selectedDuration);
  }

  void _skipDuration() {
    _doAdd(_pendingTitle);
  }

  void _showLimitWarning(String pendingTitle) {
    final isPremium =
        ref.read(premiumNotifierProvider).valueOrNull ?? false;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Heads up'),
        content: const Text(
          'Most productive days run on 3 priorities.\n'
          'Adding more can dilute your focus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep it at 3'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Add anyway'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        if (isPremium) {
          setState(() {
            _pendingTitle = pendingTitle;
            _pickingDuration = true;
          });
        } else {
          _doAdd(pendingTitle);
        }
      }
    });
  }

  static String _durationLabel(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '$h.${m == 30 ? '5' : m}h';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(Icons.add, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: _pickingDuration
                    ? Text(
                        _pendingTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Add a priority...',
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
                      ),
              ),
            ],
          ),
        ),
        if (_pickingDuration)
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
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
                              onTap: () => setState(() => _selectedDuration = d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedDuration == d
                                      ? AppColors.accent
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHigh,
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                child: Text(
                                  _durationLabel(d),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedDuration == d
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
                  onTap: _skipDuration,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: _confirmDuration,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.check, size: 18, color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
