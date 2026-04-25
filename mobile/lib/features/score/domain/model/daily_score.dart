class DailyScore {
  final String id;
  final String userId;
  final DateTime scoreDate;
  final int completionScore;
  final int structureScore;
  final int overallScore;
  final int completedTasks;
  final int totalTasks;
  final int totalPlannedBlocks;
  final int totalStaySessions;
  final String? scoreExplanation;

  const DailyScore({
    required this.id,
    required this.userId,
    required this.scoreDate,
    required this.completionScore,
    required this.structureScore,
    required this.overallScore,
    required this.completedTasks,
    required this.totalTasks,
    required this.totalPlannedBlocks,
    required this.totalStaySessions,
    required this.scoreExplanation,
  });
}
