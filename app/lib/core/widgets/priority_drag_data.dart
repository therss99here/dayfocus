class PriorityDragData {
  final String id;
  final String title;
  final int? estimatedMinutes;

  const PriorityDragData({
    required this.id,
    required this.title,
    this.estimatedMinutes,
  });
}
