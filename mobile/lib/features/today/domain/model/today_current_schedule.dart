import '../../../schedule/domain/enum/schedule_block_type.dart';

class TodayCurrentSchedule {
  final String scheduleBlockId;
  final String title;
  final ScheduleBlockType type;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final bool activeNow;

  const TodayCurrentSchedule({
    required this.scheduleBlockId,
    required this.title,
    required this.type,
    required this.startDateTime,
    required this.endDateTime,
    required this.activeNow,
  });
}
