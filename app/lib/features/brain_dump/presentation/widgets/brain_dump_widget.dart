import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../timeline/presentation/providers/active_day_provider.dart';
import '../providers/brain_dump_provider.dart';

class BrainDumpWidget extends ConsumerStatefulWidget {
  const BrainDumpWidget({super.key});

  @override
  ConsumerState<BrainDumpWidget> createState() => _BrainDumpWidgetState();
}

class _BrainDumpWidgetState extends ConsumerState<BrainDumpWidget> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String? _lastDayId;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(brainDumpNotifierProvider.notifier).save(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeDay = ref.watch(activeDayProvider);
    final currentDayId = formatDayId(activeDay);
    final contentAsync = ref.watch(brainDumpNotifierProvider);

    return contentAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, _) => Text('Error: $e'),
      data: (content) {
        if (_lastDayId != currentDayId) {
          _controller.text = content;
          _lastDayId = currentDayId;
        }

        return TextField(
          controller: _controller,
          onChanged: _onTextChanged,
          maxLines: null,
          expands: true,
          style: const TextStyle(fontSize: 13, height: 1.6),
          decoration: const InputDecoration(
            hintText: 'Dump ideas, notes, anything...',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
        );
      },
    );
  }
}
