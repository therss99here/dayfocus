import '../../priorities/domain/entities/priority_entity.dart';
import '../../timeline/domain/entities/time_block.dart';

class DaySummary {
  final DateTime date;
  final List<PriorityEntity> priorities;
  final List<TimeBlockEntity> timeBlocks;

  const DaySummary({
    required this.date,
    required this.priorities,
    required this.timeBlocks,
  });

  int get completedPriorities =>
      priorities.where((p) => p.isDone).length;

  int get totalPriorities => priorities.length;

  int get completedBlocks =>
      timeBlocks.where((b) => b.status == TimeBlockStatus.completed).length;

  int get totalBlocks => timeBlocks.length;

  int get totalScheduledMinutes =>
      timeBlocks.fold(0, (sum, b) => sum + b.durationMinutes);

  bool get isEmpty => priorities.isEmpty && timeBlocks.isEmpty;
}
