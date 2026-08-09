/// Formats a date as a stable string ID used as the DayConfig primary key.
/// e.g. DateTime(2025, 5, 14) → "2025-05-14"
String formatDayId(DateTime date) =>
    '${date.year}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
