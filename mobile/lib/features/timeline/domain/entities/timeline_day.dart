import 'timeline_item.dart';
import 'timeline_schedule_lite.dart';
import 'timeline_stay_session_lite.dart';
import 'timeline_summary.dart';
import 'timeline_task_lite.dart';
// import 'timeline_financial_event.dart';
// import 'timeline_financial_summary.dart';

class TimelineDay {
  final String userId;
  final DateTime date;
  final TimelineSummary summary;

  // -- Skipped for now --
  // final TimelineFinancialSummary financialSummary;
  // final List<TimelineFinancialEvent> financialEvents;

  final List<TimelineItem> items; // The unified chronological list
  final List<TimelineTaskLite> tasks;
  final List<TimelineScheduleLite> schedules;
  final List<TimelineStaySessionLite> staySessions;

  const TimelineDay({
    required this.userId,
    required this.date,
    required this.summary,
    required this.items,
    required this.tasks,
    required this.schedules,
    required this.staySessions,
    // required this.financialSummary,
    // required this.financialEvents,
  });
}
