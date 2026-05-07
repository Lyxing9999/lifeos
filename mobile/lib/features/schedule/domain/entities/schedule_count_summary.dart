class ScheduleCountSummary {
  final int total;
  final int active;
  final int inactive;
  final int history;
  const ScheduleCountSummary({
    required this.total,
    required this.active,
    required this.inactive,
    required this.history,
  });

  const ScheduleCountSummary.empty()
    : total = 0,
      active = 0,
      inactive = 0,
      history = 0;
}
