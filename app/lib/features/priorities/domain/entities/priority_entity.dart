class PriorityEntity {
  final String id;
  final String title;
  final bool isDone;
  final int sortOrder;
  final int? estimatedMinutes;

  const PriorityEntity({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.sortOrder,
    this.estimatedMinutes,
  });

  PriorityEntity copyWith({
    String? title,
    bool? isDone,
    int? sortOrder,
    int? estimatedMinutes,
  }) =>
      PriorityEntity(
        id: id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        sortOrder: sortOrder ?? this.sortOrder,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      );
}
