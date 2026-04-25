class DailySummary {
  final String id;
  final String userId;
  final DateTime summaryDate;
  final String summaryText;
  final String topPlaceName;
  final int totalTasks;
  final int completedTasks;
  final int totalPlannedBlocks;
  final int totalStaySessions;
  final String? scoreExplanationText;
  final String? optionalInsight;

  const DailySummary({
    required this.id,
    required this.userId,
    required this.summaryDate,
    required this.summaryText,
    required this.topPlaceName,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalPlannedBlocks,
    required this.totalStaySessions,
    required this.scoreExplanationText,
    required this.optionalInsight,
  });
}
