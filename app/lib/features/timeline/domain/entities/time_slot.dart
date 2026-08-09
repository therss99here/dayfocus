class TimeSlot {
  final int hour;
  final int minute;

  const TimeSlot(this.hour, this.minute);

  int get totalMinutes => hour * 60 + minute;
  bool get isOnHour => minute == 0;

  String get label {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static List<TimeSlot> generate({
    required int startHour,
    required int endHour,
  }) {
    return [
      for (var h = startHour; h < endHour; h++) ...[
        TimeSlot(h, 0),
        TimeSlot(h, 30),
      ],
    ];
  }
}
