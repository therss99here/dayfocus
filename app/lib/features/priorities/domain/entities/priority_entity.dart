class PriorityEntity {
  final String id;
  final String title;
  final bool isDone;
  final int sortOrder;

  const PriorityEntity({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.sortOrder,
  });

  PriorityEntity copyWith({
    String? title,
    bool? isDone,
    int? sortOrder,
  }) =>
      PriorityEntity(
        id: id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}
