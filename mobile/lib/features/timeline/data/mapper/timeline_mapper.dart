import '../../../schedule/domain/enum/schedule_block_type.dart';
import '../../../task/domain/enum/task_status.dart';
import '../../domain/model/timeline_day.dart';
import '../../domain/model/timeline_financial_event.dart';
import '../../domain/model/timeline_financial_summary.dart';
import '../../domain/model/timeline_item.dart';
import '../../domain/model/timeline_schedule_lite.dart';
import '../../domain/model/timeline_stay_session_lite.dart';
import '../../domain/model/timeline_summary.dart';
import '../../domain/model/timeline_task_lite.dart';
import '../dto/timeline_day_response_dto.dart';
import '../dto/timeline_financial_event_response_dto.dart';
import '../dto/timeline_item_dto.dart';
import '../dto/timeline_schedule_lite_response_dto.dart';
import '../dto/timeline_stay_session_lite_response_dto.dart';
import '../dto/timeline_task_lite_response_dto.dart';

class TimelineMapper {
  const TimelineMapper();

  TimelineDay toDayDomain(TimelineDayResponseDto dto) {
    final tasks = dto.tasks.map(_mapTask).toList();
    final schedules = dto.schedules.map(_mapSchedule).toList();
    final staySessions = dto.staySessions.map(_mapStay).toList();
    final financialEvents = dto.financialEvents.map(_mapFinancial).toList();

    final backendItems = dto.items.map(_mapTimelineItem).toList();
    final items = backendItems.isNotEmpty
        ? backendItems
        : _sortItems([
            ...tasks.where(_hasTimelineTime).map(_taskToItem),
            ...schedules.map(_scheduleToItem),
            ...staySessions.map(_stayToItem),
            ...financialEvents.map(_financialToItem),
          ]);

    return TimelineDay(
      userId: dto.userId ?? '',
      date: DateTime.tryParse(dto.date ?? '') ?? DateTime.now(),
      summary: TimelineSummary(
        totalLocationLogs: dto.summary?.totalLocationLogs ?? 0,
        totalStaySessions: dto.summary?.totalStaySessions ?? 0,
        totalTasks: dto.summary?.totalTasks ?? 0,
        completedTasks: dto.summary?.completedTasks ?? 0,
        totalPlannedBlocks: dto.summary?.totalPlannedBlocks ?? 0,
        topPlaceName: dto.summary?.topPlaceName ?? '',
        topPlaceDurationMinutes: dto.summary?.topPlaceDurationMinutes ?? 0,
      ),
      financialSummary: TimelineFinancialSummary(
        totalFinancialEvents: dto.financialSummary?.totalFinancialEvents ?? 0,
        totalOutgoingAmount: dto.financialSummary?.totalOutgoingAmount ?? 0,
      ),
      tasks: tasks,
      schedules: schedules,
      staySessions: staySessions,
      financialEvents: financialEvents,
      items: items,
    );
  }

  TimelineTaskLite _mapTask(TimelineTaskLiteResponseDto dto) {
    return TimelineTaskLite(
      id: dto.id ?? '',
      title: dto.title ?? '',
      status: TaskStatusX.fromApi(dto.status ?? 'TODO'),
      progressPercent: dto.progressPercent ?? 0,
      category: dto.category,
      dueDate: dto.dueDate == null ? null : DateTime.tryParse(dto.dueDate!),
    );
  }

  TimelineScheduleLite _mapSchedule(TimelineScheduleLiteResponseDto dto) {
    return TimelineScheduleLite(
      scheduleBlockId: dto.scheduleBlockId ?? '',
      userId: dto.userId ?? '',
      title: dto.title ?? '',
      type: ScheduleBlockTypeX.fromApi(dto.type ?? 'OTHER'),
      occurrenceDate:
          DateTime.tryParse(dto.occurrenceDate ?? '') ?? DateTime.now(),
      startDateTime:
          DateTime.tryParse(dto.startDateTime ?? '') ?? DateTime.now(),
      endDateTime: DateTime.tryParse(dto.endDateTime ?? '') ?? DateTime.now(),
    );
  }

  TimelineStaySessionLite _mapStay(TimelineStaySessionLiteResponseDto dto) {
    return TimelineStaySessionLite(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      placeId: dto.placeId,
      placeName: dto.placeName ?? '',
      placeType: dto.placeType ?? '',
      startTime: dto.startTime == null
          ? null
          : DateTime.tryParse(dto.startTime!),
      endTime: dto.endTime == null ? null : DateTime.tryParse(dto.endTime!),
      durationMinutes: dto.durationMinutes ?? 0,
      centerLatitude: dto.centerLatitude ?? 0,
      centerLongitude: dto.centerLongitude ?? 0,
      confidence: dto.confidence ?? 0,
      placeResolutionStatus: dto.placeResolutionStatus ?? '',
      matchedPlaceSource: dto.matchedPlaceSource ?? '',
      placeConfidence: dto.placeConfidence ?? 0,
    );
  }

  TimelineFinancialEvent _mapFinancial(TimelineFinancialEventResponseDto dto) {
    return TimelineFinancialEvent(
      id: dto.id ?? '',
      amount: dto.amount ?? 0,
      currency: dto.currency ?? '',
      merchantName: dto.merchantName ?? '',
      financialEventType: dto.financialEventType ?? '',
      category: dto.category ?? '',
      paidAt: dto.paidAt == null ? null : DateTime.tryParse(dto.paidAt!),
    );
  }

  TimelineItem _mapTimelineItem(TimelineItemResponseDto dto) {
    final normalizedType = (dto.itemType ?? '').trim().toLowerCase();
    final badge = (dto.badge ?? '').trim();
    final status = (dto.status ?? '').trim();
    final source = badge.isNotEmpty
        ? badge
        : (status.isNotEmpty ? status : null);

    return TimelineItem(
      id: dto.itemId ?? '',
      type: normalizedType,
      title: dto.title ?? '',
      subtitle: dto.subtitle,
      startTime: dto.startDateTime == null
          ? null
          : DateTime.tryParse(dto.startDateTime!),
      endTime: dto.endDateTime == null
          ? null
          : DateTime.tryParse(dto.endDateTime!),
      source: source,
    );
  }

  List<TimelineItem> _sortItems(List<TimelineItem> items) {
    items.sort((a, b) {
      final aTime = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });

    return items;
  }

  TimelineItem _taskToItem(TimelineTaskLite task) {
    return TimelineItem(
      id: task.id,
      type: 'task',
      title: task.title,
      subtitle: task.category,
      startTime: task.dueDate,
      endTime: null,
      source: task.status.label,
    );
  }

  TimelineItem _scheduleToItem(TimelineScheduleLite item) {
    return TimelineItem(
      id: item.scheduleBlockId,
      type: 'schedule',
      title: item.title,
      subtitle: item.type.label,
      startTime: item.startDateTime,
      endTime: item.endDateTime,
      source: null,
    );
  }

  TimelineItem _stayToItem(TimelineStaySessionLite item) {
    return TimelineItem(
      id: item.id,
      type: 'stay',
      title: item.placeName,
      subtitle: '${item.placeType} · ${item.durationMinutes} min',
      startTime: item.startTime,
      endTime: item.endTime,
      source: item.matchedPlaceSource,
    );
  }

  TimelineItem _financialToItem(TimelineFinancialEvent item) {
    return TimelineItem(
      id: item.id,
      type: 'financial',
      title: item.merchantName.isEmpty ? 'Spending' : item.merchantName,
      subtitle: '${item.amount.toStringAsFixed(2)} ${item.currency}',
      startTime: item.paidAt,
      endTime: null,
      source: item.category,
    );
  }

  bool _hasTimelineTime(TimelineTaskLite task) => task.dueDate != null;
}
