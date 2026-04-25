class SummaryResponseDto {
  final String? id;
  final String? userId;
  final String? summaryDate;
  final String? summaryText;
  final String? topPlaceName;
  final int? totalTasks;
  final int? completedTasks;
  final int? totalPlannedBlocks;
  final int? totalStaySessions;
  final String? scoreExplanationText;
  final String? optionalInsight;

  const SummaryResponseDto({
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

  factory SummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return SummaryResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      summaryDate: json['summaryDate'] as String?,
      summaryText: json['summaryText'] as String?,
      topPlaceName: json['topPlaceName'] as String?,
      totalTasks: (json['totalTasks'] as num?)?.toInt(),
      completedTasks: (json['completedTasks'] as num?)?.toInt(),
      totalPlannedBlocks: (json['totalPlannedBlocks'] as num?)?.toInt(),
      totalStaySessions: (json['totalStaySessions'] as num?)?.toInt(),
      scoreExplanationText: json['scoreExplanationText'] as String?,
      optionalInsight: json['optionalInsight'] as String?,
    );
  }
}
