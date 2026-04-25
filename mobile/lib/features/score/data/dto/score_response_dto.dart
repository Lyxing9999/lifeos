class ScoreResponseDto {
  final String? id;
  final String? userId;
  final String? scoreDate;
  final int? completionScore;
  final int? structureScore;
  final int? overallScore;
  final int? completedTasks;
  final int? totalTasks;
  final int? totalPlannedBlocks;
  final int? totalStaySessions;
  final String? scoreExplanation;

  const ScoreResponseDto({
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

  factory ScoreResponseDto.fromJson(Map<String, dynamic> json) {
    return ScoreResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      scoreDate: json['scoreDate'] as String?,
      completionScore: (json['completionScore'] as num?)?.toInt(),
      structureScore: (json['structureScore'] as num?)?.toInt(),
      overallScore: (json['overallScore'] as num?)?.toInt(),
      completedTasks: (json['completedTasks'] as num?)?.toInt(),
      totalTasks: (json['totalTasks'] as num?)?.toInt(),
      totalPlannedBlocks: (json['totalPlannedBlocks'] as num?)?.toInt(),
      totalStaySessions: (json['totalStaySessions'] as num?)?.toInt(),
      scoreExplanation: json['scoreExplanation'] as String?,
    );
  }
}
