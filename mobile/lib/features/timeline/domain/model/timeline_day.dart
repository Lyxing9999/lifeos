import 'timeline_financial_event.dart';
import 'timeline_financial_summary.dart';
import 'timeline_item.dart';
import 'timeline_schedule_lite.dart';
import 'timeline_stay_session_lite.dart';
import 'timeline_summary.dart';
import 'timeline_task_lite.dart';

class TimelineDay {
  final String userId;
  final DateTime date;
  final TimelineSummary summary;
  final TimelineFinancialSummary financialSummary;
  final List<TimelineTaskLite> tasks;
  final List<TimelineScheduleLite> schedules;
  final List<TimelineStaySessionLite> staySessions;
  final List<TimelineFinancialEvent> financialEvents;
  final List<TimelineItem> items;

  const TimelineDay({
    required this.userId,
    required this.date,
    required this.summary,
    required this.financialSummary,
    required this.tasks,
    required this.schedules,
    required this.staySessions,
    required this.financialEvents,
    required this.items,
  });
}
