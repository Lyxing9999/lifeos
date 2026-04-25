class TodayResponseDto {
  final Map<String, dynamic>? user;
  final String? date;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? score;
  final Map<String, dynamic>? timeline;
  final Map<String, dynamic>? currentScheduleBlock;
  final Map<String, dynamic>? topActiveTask;
  final Map<String, dynamic>? topPlaceInsight;
  final Map<String, dynamic>? financialInsight;

  const TodayResponseDto({
    required this.user,
    required this.date,
    required this.summary,
    required this.score,
    required this.timeline,
    required this.currentScheduleBlock,
    required this.topActiveTask,
    required this.topPlaceInsight,
    required this.financialInsight,
  });

  factory TodayResponseDto.fromJson(Map<String, dynamic> json) {
    return TodayResponseDto(
      user: json['user'] as Map<String, dynamic>?,
      date: json['date'] as String?,
      summary: json['summary'] as Map<String, dynamic>?,
      score: json['score'] as Map<String, dynamic>?,
      timeline: json['timeline'] as Map<String, dynamic>?,
      currentScheduleBlock:
          json['currentScheduleBlock'] as Map<String, dynamic>?,
      topActiveTask: json['topActiveTask'] as Map<String, dynamic>?,
      topPlaceInsight: json['topPlaceInsight'] as Map<String, dynamic>?,
      financialInsight: json['financialInsight'] as Map<String, dynamic>?,
    );
  }
}
