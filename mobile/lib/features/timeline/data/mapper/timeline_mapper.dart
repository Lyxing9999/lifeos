import '../../../schedule/domain/enum/schedule_block_type.dart';
import '../../../task/domain/enum/task_status.dart';
import '../../domain/enum/timeline_item_type.dart';
import '../../domain/entities/timeline_day.dart';
import '../../domain/entities/timeline_item.dart';
import '../../domain/entities/timeline_schedule_lite.dart';
import '../../domain/entities/timeline_stay_session_lite.dart';
import '../../domain/entities/timeline_summary.dart';
import '../../domain/entities/timeline_task_lite.dart';
import '../dto/timeline_day_response_dto.dart';
import '../dto/timeline_item_dto.dart';
import '../dto/timeline_schedule_lite_response_dto.dart';
import '../dto/timeline_stay_session_lite_response_dto.dart';
import '../dto/timeline_task_lite_response_dto.dart';

class TimelineMapper {
  const TimelineMapper();

  TimelineDay toDayDomain(TimelineDayResponseDto dto) {
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
      // Mapped directly from the BFF backend list perfectly.
      items: dto.items.map(_mapTimelineItem).toList(),
      tasks: dto.tasks.map(_mapTask).toList(),
      schedules: dto.schedules.map(_mapSchedule).toList(),
      staySessions: dto.staySessions.map(_mapStay).toList(),
    );
  }

  TimelineItem _mapTimelineItem(TimelineItemResponseDto dto) {
    return TimelineItem(
      id: dto.itemId ?? '',
      type: TimelineItemType.fromApi(dto.itemType), // Safe strict Enum mapping
      title: dto.title ?? '',
      subtitle: dto.subtitle,
      startTime: dto.startDateTime == null
          ? null
          : DateTime.tryParse(dto.startDateTime!),
      endTime: dto.endDateTime == null
          ? null
          : DateTime.tryParse(dto.endDateTime!),
      badge: dto.badge,
      status: dto.status,
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
}
