class TimelineSummaryResponseDto {
  final int? totalLocationLogs;
  final int? totalStaySessions;
  final int? totalTasks;
  final int? completedTasks;
  final int? totalPlannedBlocks;
  final String? topPlaceName;
  final int? topPlaceDurationMinutes;

  const TimelineSummaryResponseDto({
    required this.totalLocationLogs,
    required this.totalStaySessions,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalPlannedBlocks,
    required this.topPlaceName,
    required this.topPlaceDurationMinutes,
  });

  factory TimelineSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return TimelineSummaryResponseDto(
      totalLocationLogs: (json['totalLocationLogs'] as num?)?.toInt(),
      totalStaySessions: (json['totalStaySessions'] as num?)?.toInt(),
      totalTasks: (json['totalTasks'] as num?)?.toInt(),
      completedTasks: (json['completedTasks'] as num?)?.toInt(),
      totalPlannedBlocks: (json['totalPlannedBlocks'] as num?)?.toInt(),
      topPlaceName: json['topPlaceName'] as String?,
      topPlaceDurationMinutes: (json['topPlaceDurationMinutes'] as num?)
          ?.toInt(),
    );
  }
}
