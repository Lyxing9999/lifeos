class TimelineScheduleOccurrence {
  final String scheduleBlockId;
  final String userId;
  final String title;
  final String type;
  final DateTime occurrenceDate;
  final DateTime startDateTime;
  final DateTime endDateTime;

  const TimelineScheduleOccurrence({
    required this.scheduleBlockId,
    required this.userId,
    required this.title,
    required this.type,
    required this.occurrenceDate,
    required this.startDateTime,
    required this.endDateTime,
  });
}
