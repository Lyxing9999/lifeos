enum TodayWeatherInsightSeverity {
  neutral,
  helpful,
  caution,
}

class TodayWeatherInsight {
  final String title;
  final String message;
  final String actionHint;
  final TodayWeatherInsightSeverity severity;
  final bool isRealData;
  final bool isSelectedToday;

  const TodayWeatherInsight({
    required this.title,
    required this.message,
    required this.actionHint,
    required this.severity,
    required this.isRealData,
    required this.isSelectedToday,
  });

  factory TodayWeatherInsight.placeholder({
    required bool isSelectedToday,
  }) {
    return TodayWeatherInsight(
      title: 'Weather context',
      message: isSelectedToday
          ? 'Coming soon for commute, outdoor routines, and planning risk.'
          : 'Weather context is most useful for the current day.',
      actionHint: 'Later: rain, heat, and commute-aware suggestions.',
      severity: TodayWeatherInsightSeverity.neutral,
      isRealData: false,
      isSelectedToday: isSelectedToday,
    );
  }

  factory TodayWeatherInsight.fromConditions({
    required String condition,
    required int temperatureCelsius,
    required int rainChancePercent,
    required bool isSelectedToday,
  }) {
    if (rainChancePercent >= 60) {
      return TodayWeatherInsight(
        title: 'Rain may affect your day',
        message:
            '$rainChancePercent% chance of rain. Check commute, errands, or outdoor exercise.',
        actionHint: 'Review schedule blocks that require travel.',
        severity: TodayWeatherInsightSeverity.caution,
        isRealData: true,
        isSelectedToday: isSelectedToday,
      );
    }

    if (temperatureCelsius >= 34) {
      return TodayWeatherInsight(
        title: 'Hot day ahead',
        message:
            '$temperatureCelsius°C. Outdoor routines may need lighter timing.',
        actionHint: 'Plan exercise or errands outside peak heat.',
        severity: TodayWeatherInsightSeverity.caution,
        isRealData: true,
        isSelectedToday: isSelectedToday,
      );
    }

    return TodayWeatherInsight(
      title: 'Weather looks stable',
      message:
          '$condition, $temperatureCelsius°C. No obvious weather risk for your plan.',
      actionHint: 'Keep focus on tasks and planned blocks.',
      severity: TodayWeatherInsightSeverity.helpful,
      isRealData: true,
      isSelectedToday: isSelectedToday,
    );
  }
}