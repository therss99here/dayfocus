import 'package:intl/intl.dart';
import '../../domain/day_summary.dart';

String formatDaySummary(DaySummary summary) {
  final date = DateFormat('EEEE, MMMM d, y').format(summary.date);
  final buf = StringBuffer('My Day — $date\n');

  if (summary.priorities.isNotEmpty) {
    buf.writeln();
    buf.writeln('Priorities:');
    for (final p in summary.priorities) {
      final mark = p.isDone ? '✓' : '○';
      buf.writeln(' $mark ${p.title}');
    }
  }

  if (summary.timeBlocks.isNotEmpty) {
    final hours = summary.totalScheduledMinutes ~/ 60;
    final mins = summary.totalScheduledMinutes % 60;
    final duration = hours > 0
        ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
        : '${mins}m';
    buf.writeln();
    buf.writeln(
      'Timeline: ${summary.completedBlocks}/${summary.totalBlocks} '
      'blocks completed · $duration planned',
    );
  }

  if (summary.isEmpty) {
    buf.writeln();
    buf.writeln('Planning starts here.');
  }

  buf.writeln();
  buf.write('Made with MyDayfocus');

  return buf.toString();
}
