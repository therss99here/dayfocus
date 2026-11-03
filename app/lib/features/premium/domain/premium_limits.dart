class PremiumLimits {
  static const int freePrioritiesPerDay = 3;
  static const int freeTimeBlocksPerDay = 3;
  static const int freeHistoryDays = 7;
  static const int freeStartHour = 9;
  static const int freeEndHour = 18;

  static const int freeBlockDurationMinutes = 30;
  static const List<int> premiumBlockDurationOptions = [30, 60, 90, 120, 150, 180];

  static const int premiumPrioritiesPerDay = 999;
  static const int premiumTimeBlocksPerDay = 999;
  static const int premiumHistoryDays = 999;
  static const int premiumStartHour = 0;
  static const int premiumEndHour = 24;
}
