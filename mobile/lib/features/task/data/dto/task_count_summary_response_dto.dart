class TaskCountSummaryResponseDto {
  final int total;
  final int active;
  final int completed;
  final int urgent;
  final int daily;
  final int progress;

  const TaskCountSummaryResponseDto({
    required this.total,
    required this.active,
    required this.completed,
    required this.urgent,
    required this.daily,
    required this.progress,
  });

  const TaskCountSummaryResponseDto.empty()
    : total = 0,
      active = 0,
      completed = 0,
      urgent = 0,
      daily = 0,
      progress = 0;

  factory TaskCountSummaryResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TaskCountSummaryResponseDto.empty();

    return TaskCountSummaryResponseDto(
      total: _asInt(json['total']) ?? 0,
      active: _asInt(json['active']) ?? 0,
      completed: _asInt(json['completed']) ?? 0,
      urgent: _asInt(json['urgent']) ?? 0,
      daily: _asInt(json['daily']) ?? 0,
      progress: _asInt(json['progress']) ?? 0,
    );
  }

  static int? _asInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
