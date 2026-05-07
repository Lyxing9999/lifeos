import '../enum/schedule_block_type.dart';
import '../enum/schedule_recurrence_type.dart';

class ScheduleOccurrence {
  final String scheduleBlockId;
  final String userId;
  final String title;
  final ScheduleBlockType type;
  final ScheduleRecurrenceType recurrenceType; // NEW ADD
  final DateTime occurrenceDate;
  final DateTime startDateTime;
  final DateTime endDateTime;

  const ScheduleOccurrence({
    required this.scheduleBlockId,
    required this.userId,
    required this.title,
    required this.type,
    required this.recurrenceType, // NEW ADD
    required this.occurrenceDate,
    required this.startDateTime,
    required this.endDateTime,
  });
}
