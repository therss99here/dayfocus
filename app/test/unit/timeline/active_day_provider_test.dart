import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/features/timeline/presentation/providers/active_day_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  group('ActiveDay', () {
    test('initial state is today with no time component', () {
      final state = container.read(activeDayProvider);
      final today = _today();
      expect(state, today);
      expect(state.hour, 0);
      expect(state.minute, 0);
      expect(state.second, 0);
    });

    test('previous() subtracts one day', () {
      final notifier = container.read(activeDayProvider.notifier);
      final today = _today();

      notifier.previous();

      final state = container.read(activeDayProvider);
      expect(state, today.subtract(const Duration(days: 1)));
    });

    test('next() adds one day', () {
      final notifier = container.read(activeDayProvider.notifier);
      final today = _today();

      notifier.next();

      final state = container.read(activeDayProvider);
      expect(state, today.add(const Duration(days: 1)));
    });

    test('goToToday() returns to today from a past day', () {
      final notifier = container.read(activeDayProvider.notifier);
      final today = _today();

      notifier.previous();
      notifier.previous();
      notifier.previous();
      notifier.goToToday();

      final state = container.read(activeDayProvider);
      expect(state, today);
    });

    test('goToToday() returns to today from a future day', () {
      final notifier = container.read(activeDayProvider.notifier);
      final today = _today();

      notifier.next();
      notifier.next();
      notifier.goToToday();

      final state = container.read(activeDayProvider);
      expect(state, today);
    });

    test('multiple previous() calls accumulate', () {
      final notifier = container.read(activeDayProvider.notifier);
      final today = _today();

      for (var i = 0; i < 5; i++) {
        notifier.previous();
      }

      final state = container.read(activeDayProvider);
      expect(state, today.subtract(const Duration(days: 5)));
    });

    test('going 8 days back produces correct date (no limit in provider)', () {
      final notifier = container.read(activeDayProvider.notifier);
      final today = _today();

      for (var i = 0; i < 8; i++) {
        notifier.previous();
      }

      final state = container.read(activeDayProvider);
      expect(state, today.subtract(const Duration(days: 8)));
    });

    test('previous then next returns to same day', () {
      final notifier = container.read(activeDayProvider.notifier);
      final today = _today();

      notifier.previous();
      notifier.next();

      final state = container.read(activeDayProvider);
      expect(state, today);
    });
  });
}
