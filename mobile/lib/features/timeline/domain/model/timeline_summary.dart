class TimelineSummary {
  final int totalLocationLogs;
  final int totalStaySessions;
  final int totalTasks;
  final int completedTasks;
  final int totalPlannedBlocks;
  final String topPlaceName;
  final int topPlaceDurationMinutes;

  const TimelineSummary({
    required this.totalLocationLogs,
    required this.totalStaySessions,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalPlannedBlocks,
    required this.topPlaceName,
    required this.topPlaceDurationMinutes,
  });
}
