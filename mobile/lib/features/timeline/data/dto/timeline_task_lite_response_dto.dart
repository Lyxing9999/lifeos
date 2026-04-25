class TimelineTaskLiteResponseDto {
  final String? id;
  final String? title;
  final String? status;
  final int? progressPercent;
  final String? category;
  final String? dueDate;

  const TimelineTaskLiteResponseDto({
    required this.id,
    required this.title,
    required this.status,
    required this.progressPercent,
    required this.category,
    required this.dueDate,
  });

  factory TimelineTaskLiteResponseDto.fromJson(Map<String, dynamic> json) {
    return TimelineTaskLiteResponseDto(
      id: json['id'] as String?,
      title: json['title'] as String?,
      status: json['status'] as String?,
      progressPercent: (json['progressPercent'] as num?)?.toInt(),
      category: json['category'] as String?,
      dueDate: json['dueDate'] as String?,
    );
  }
}
