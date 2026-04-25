import '../../../task/domain/model/task.dart';
import '../../../timeline/domain/model/timeline_day.dart';
import '../../domain/model/today_current_schedule.dart';
import '../../domain/model/today_financial_insight.dart';
import '../../domain/model/today_place_insight.dart';
import '../../../summary/domain/model/daily_summary.dart';
import '../../../score/domain/model/daily_score.dart';

class TodayOverview {
  final String userId;
  final String userName;
  final String userEmail;
  final String timezone;
  final String locale;
  final DateTime date;

  final DailySummary? summary;
  final DailyScore? score;
  final TimelineDay? timeline;
  final TodayCurrentSchedule? currentScheduleBlock;
  final Task? topActiveTask;
  final TodayPlaceInsight? topPlaceInsight;
  final TodayFinancialInsight? financialInsight;

  const TodayOverview({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.timezone,
    required this.locale,
    required this.date,
    required this.summary,
    required this.score,
    required this.timeline,
    required this.currentScheduleBlock,
    required this.topActiveTask,
    required this.topPlaceInsight,
    required this.financialInsight,
  });

  int get overallScore => score?.overallScore ?? 0;
  int get completionScore => score?.completionScore ?? 0;
  int get structureScore => score?.structureScore ?? 0;

  String get summaryText => summary?.summaryText ?? '';
  String get topPlaceName => summary?.topPlaceName ?? '';
  int get totalTasks => summary?.totalTasks ?? 0;
  int get completedTasks => summary?.completedTasks ?? 0;
  int get totalPlannedBlocks => summary?.totalPlannedBlocks ?? 0;
  int get totalStaySessions => summary?.totalStaySessions ?? 0;
}
