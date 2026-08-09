import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_day_provider.g.dart';

@riverpod
class ActiveDay extends _$ActiveDay {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void previous() => state = state.subtract(const Duration(days: 1));
  void next() => state = state.add(const Duration(days: 1));

  void goToToday() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, now.day);
  }
}
