import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/features/premium/domain/premium_limits.dart';

void main() {
  group('PremiumLimits - Free tier', () {
    test('freePrioritiesPerDay is 3', () {
      expect(PremiumLimits.freePrioritiesPerDay, 3);
    });

    test('freeTimeBlocksPerDay is 3', () {
      expect(PremiumLimits.freeTimeBlocksPerDay, 3);
    });

    test('freeHistoryDays is 7', () {
      expect(PremiumLimits.freeHistoryDays, 7);
    });

    test('freeStartHour is 9', () {
      expect(PremiumLimits.freeStartHour, 9);
    });

    test('freeEndHour is 18', () {
      expect(PremiumLimits.freeEndHour, 18);
    });

    test('freeBlockDurationMinutes is 30', () {
      expect(PremiumLimits.freeBlockDurationMinutes, 30);
    });
  });

  group('PremiumLimits - Premium tier', () {
    test('premiumPrioritiesPerDay is 999', () {
      expect(PremiumLimits.premiumPrioritiesPerDay, 999);
    });

    test('premiumTimeBlocksPerDay is 999', () {
      expect(PremiumLimits.premiumTimeBlocksPerDay, 999);
    });

    test('premiumHistoryDays is 999', () {
      expect(PremiumLimits.premiumHistoryDays, 999);
    });

    test('premiumStartHour is 0', () {
      expect(PremiumLimits.premiumStartHour, 0);
    });

    test('premiumEndHour is 24', () {
      expect(PremiumLimits.premiumEndHour, 24);
    });

    test('premiumBlockDurationOptions has correct values', () {
      expect(
        PremiumLimits.premiumBlockDurationOptions,
        [30, 60, 90, 120, 150, 180],
      );
    });
  });
}
