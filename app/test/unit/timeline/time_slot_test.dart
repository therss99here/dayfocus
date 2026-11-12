import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/features/timeline/domain/entities/time_slot.dart';

void main() {
  group('TimeSlot.generate', () {
    test('free hours (9-18) produces 18 slots', () {
      final slots = TimeSlot.generate(startHour: 9, endHour: 18);
      expect(slots, hasLength(18));
    });

    test('full day (0-24) produces 48 slots', () {
      final slots = TimeSlot.generate(startHour: 0, endHour: 24);
      expect(slots, hasLength(48));
    });

    test('first two slots for startHour=9 are (9,0) and (9,30)', () {
      final slots = TimeSlot.generate(startHour: 9, endHour: 18);
      expect(slots[0].hour, 9);
      expect(slots[0].minute, 0);
      expect(slots[1].hour, 9);
      expect(slots[1].minute, 30);
    });

    test('slots alternate between on-hour and half-hour', () {
      final slots = TimeSlot.generate(startHour: 9, endHour: 11);
      expect(slots, hasLength(4));
      expect(slots[0].minute, 0);
      expect(slots[1].minute, 30);
      expect(slots[2].minute, 0);
      expect(slots[3].minute, 30);
    });
  });

  group('TimeSlot properties', () {
    test('isOnHour is true for minute=0', () {
      expect(const TimeSlot(10, 0).isOnHour, true);
    });

    test('isOnHour is false for minute=30', () {
      expect(const TimeSlot(10, 30).isOnHour, false);
    });

    test('label format pads single digits', () {
      expect(const TimeSlot(9, 0).label, '09:00');
      expect(const TimeSlot(9, 30).label, '09:30');
      expect(const TimeSlot(14, 0).label, '14:00');
    });

    test('totalMinutes computes correctly', () {
      expect(const TimeSlot(10, 30).totalMinutes, 630);
      expect(const TimeSlot(0, 0).totalMinutes, 0);
      expect(const TimeSlot(23, 30).totalMinutes, 1410);
    });
  });
}
