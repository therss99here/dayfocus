import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/priorities_provider.dart';

class AddPriorityField extends ConsumerStatefulWidget {
  const AddPriorityField({super.key});

  @override
  ConsumerState<AddPriorityField> createState() => _AddPriorityFieldState();
}

class _AddPriorityFieldState extends ConsumerState<AddPriorityField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final title = value.trim();
    if (title.isEmpty) return;

    final count = ref.read(prioritiesNotifierProvider).valueOrNull?.length ?? 0;
    if (count >= PrioritiesNotifier.softLimit) {
      _showLimitWarning(title);
    } else {
      _doAdd(title);
    }
  }

  void _doAdd(String title) {
    ref.read(prioritiesNotifierProvider.notifier).add(title);
    _controller.clear();
  }

  void _showLimitWarning(String pendingTitle) {
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
      if (confirmed == true && mounted) _doAdd(pendingTitle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.add, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Add a priority...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
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
    );
  }
}
