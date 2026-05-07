class ScheduleCountSummaryResponseDto {
  final int total;
  final int active;
  final int inactive;
  final int history;
  const ScheduleCountSummaryResponseDto({
    required this.total,
    required this.active,
    required this.inactive,
    required this.history,
  });

  factory ScheduleCountSummaryResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ScheduleCountSummaryResponseDto(
        total: 0,
        active: 0,
        inactive: 0,
        history: 0,
      );
    }

    return ScheduleCountSummaryResponseDto(
      total: json['total'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
      inactive: json['inactive'] as int? ?? 0,
      history: json['history'] as int? ?? 0,
    );
  }
}
