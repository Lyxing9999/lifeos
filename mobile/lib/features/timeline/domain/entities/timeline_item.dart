import '../../../../core/utils/time_window_status.dart';
import '../enum/timeline_item_type.dart';

class TimelineItem {
  final String id;
  final TimelineItemType type; // STRICT ENUM
  final String title;
  final String? subtitle;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? badge;
  final String? status;

  const TimelineItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.startTime,
    this.endTime,
    this.badge,
    this.status,
  });
}

enum TimelineTemporalState { now, upcoming, completed, open }

extension TimelineItemX on TimelineItem {
  bool get isTask => type == TimelineItemType.task;
  bool get isSchedule => type == TimelineItemType.schedule;
  bool get isStay => type == TimelineItemType.stay;

  bool get isCompletedTask =>
      isTask && (status ?? '').trim().toUpperCase() == 'COMPLETED';

  DateTime? get timelineMoment => startTime ?? endTime;

  TimelineTemporalState temporalStateAt(DateTime now) {
    if (isNowAt(now)) return TimelineTemporalState.now;
    if (isCompletedAt(now)) return TimelineTemporalState.completed;
    if (isUpcomingAt(now)) return TimelineTemporalState.upcoming;
    return TimelineTemporalState.open;
  }

  bool isNowAt(DateTime now) {
    if (startTime == null || endTime == null || isTask) return false;
    return timeWindowStatus(start: startTime!, end: endTime!, now: now) ==
        TimeWindowStatus.now;
  }

  bool isCompletedAt(DateTime now) {
    if (isCompletedTask) return true;
    final comparisonMoment = endTime ?? (isTask ? null : startTime);
    if (comparisonMoment == null) return false;
    return !comparisonMoment.toUtc().isAfter(now.toUtc()) && !isNowAt(now);
  }

  bool isUpcomingAt(DateTime now) {
    if (startTime == null || isCompletedAt(now)) return false;
    return startTime!.toUtc().isAfter(now.toUtc());
  }

  bool isRemainingAt(DateTime now) => !isCompletedAt(now);
}
