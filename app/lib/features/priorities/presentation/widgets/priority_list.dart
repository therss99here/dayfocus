import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/priorities_provider.dart';
import 'add_priority_field.dart';
import 'priority_tile.dart';

class PriorityList extends ConsumerWidget {
  const PriorityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priorities = ref.watch(prioritiesNotifierProvider).valueOrNull ?? [];
    final sorted = [...priorities]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final notifier = ref.read(prioritiesNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sorted.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            onReorder: notifier.reorder,
            proxyDecorator: _proxyDecorator,
            itemBuilder: (context, index) => PriorityTile(
              key: ValueKey(sorted[index].id),
              priority: sorted[index],
              index: index,
            ),
          ),
        const AddPriorityField(),
      ],
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Material(
        elevation: 4 * animation.value,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: child,
      ),
    );
  }
}
