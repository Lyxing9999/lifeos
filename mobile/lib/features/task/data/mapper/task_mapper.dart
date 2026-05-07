import '../../domain/entities/task_overview.dart';
import '../../domain/entities/task_section.dart';
import '../../domain/entities/task_surface.dart';
import '../../domain/entities/task_count_summary.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_tag.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_recurrence_type.dart';
import '../../domain/enum/task_status.dart';
import '../dto/task_count_summary_response_dto.dart';
import '../dto/task_overview_response_dto.dart';
import '../dto/task_response_dto.dart';
import '../dto/task_section_response_dto.dart';
import '../dto/task_surface_response_dto.dart';

class TaskMapper {
  const TaskMapper();

  Task toDomain(TaskResponseDto dto) => dto.toDomain();

  TaskOverview toOverviewDomain(TaskOverviewResponseDto dto) => dto.toDomain();

  TaskSection toSectionDomain(TaskSectionResponseDto dto) => dto.toDomain();

  TaskSurfaceOverview toSurfaceDomain(TaskSurfaceResponseDto dto) {
    return dto.toDomain();
  }
}

extension TaskResponseDtoMapper on TaskResponseDto {
  Task toDomain() {
    return Task(
      id: (id ?? '').trim(),
      userId: (userId ?? '').trim(),
      title: (title ?? '').trim(),
      description: _nullIfBlank(description),
      category: _nullIfBlank(category),
      status: TaskStatusX.fromApi(status),
      taskMode: TaskModeX.fromApi(taskMode),
      priority: TaskPriorityX.fromApi(priority),
      dueDate: _parseDate(dueDate),
      dueDateTime: _parseDateTime(dueDateTime),
      progressPercent: progressPercent ?? 0,
      startedAt: _parseDateTime(startedAt),
      completedAt: _parseDateTime(completedAt),
      achievedDate: _parseDate(achievedDate),
      doneClearedAt: _parseDateTime(doneClearedAt),
      archived: archived ?? false,
      paused: paused ?? false,
      pausedAt: _parseDateTime(pausedAt),
      pauseUntil: _parseDate(pauseUntil),
      recurrenceType: TaskRecurrenceTypeX.fromApi(recurrenceType),
      recurrenceStartDate: _parseDate(recurrenceStartDate),
      recurrenceEndDate: _parseDate(recurrenceEndDate),
      recurrenceDaysOfWeek: _parseRecurrenceDays(recurrenceDaysOfWeek),
      linkedScheduleBlockId: _nullIfBlank(linkedScheduleBlockId),
      tags: tags
          .map((tag) => TaskTag(name: (tag.name ?? '').trim()))
          .where((tag) => tag.name.isNotEmpty)
          .toList(),
    );
  }
}

extension TaskResponseDtoListMapper on List<TaskResponseDto> {
  List<Task> toDomainList() {
    return map((item) => item.toDomain()).toList(growable: false);
  }
}

extension TaskSurfaceResponseDtoMapper on TaskSurfaceResponseDto {
  TaskSurfaceOverview toDomain() {
    final parsedDate = _parseDate(date) ?? _today();

    return TaskSurfaceOverview(
      date: parsedDate,
      filter: filter ?? 'ACTIVE',

      dueTasks: dueTasks.toDomainList(),
      inboxTasks: inboxTasks.toDomainList(),
      doneTasks: doneTasks.toDomainList(),
      historyTasks: historyTasks.toDomainList(),
      pausedTasks: pausedTasks.toDomainList(),
      archivedTasks: archivedTasks.toDomainList(),
      allTasks: allTasks.toDomainList(),

      dueCounts: dueCounts?.toDomain() ?? const TaskCountSummary.empty(),
      inboxCounts: inboxCounts?.toDomain() ?? const TaskCountSummary.empty(),
      doneCounts: doneCounts?.toDomain() ?? const TaskCountSummary.empty(),
      historyCounts:
          historyCounts?.toDomain() ?? const TaskCountSummary.empty(),
      pausedCounts: pausedCounts?.toDomain() ?? const TaskCountSummary.empty(),
      archivedCounts:
          archivedCounts?.toDomain() ?? const TaskCountSummary.empty(),
      allCounts: allCounts?.toDomain() ?? const TaskCountSummary.empty(),
    );
  }
}

extension TaskCountSummaryResponseDtoMapper on TaskCountSummaryResponseDto {
  TaskCountSummary toDomain() {
    return TaskCountSummary(
      total: total,
      active: active,
      completed: completed,
      urgent: urgent,
      daily: daily,
      progress: progress,
    );
  }
}

extension TaskOverviewResponseDtoMapper on TaskOverviewResponseDto {
  TaskOverview toDomain() {
    return TaskOverview(
      date: _parseDate(date) ?? _today(),
      currentTask: currentTask?.toDomain(),
      currentUrgentTask: currentUrgentTask?.toDomain(),
      currentDailyTask: currentDailyTask?.toDomain(),
      currentProgressTask: currentProgressTask?.toDomain(),
      todaySections: todaySections?.toDomain() ?? const TaskSection.empty(),
      last3DaySections:
          last3DaySections?.toDomain() ?? const TaskSection.empty(),
      last7DaySections:
          last7DaySections?.toDomain() ?? const TaskSection.empty(),
      last30DaySections:
          last30DaySections?.toDomain() ?? const TaskSection.empty(),
      todayCounts: todayCounts?.toDomain() ?? const TaskCountSummary.empty(),
      last3DayCounts:
          last3DayCounts?.toDomain() ?? const TaskCountSummary.empty(),
      last7DayCounts:
          last7DayCounts?.toDomain() ?? const TaskCountSummary.empty(),
      last30DayCounts:
          last30DayCounts?.toDomain() ?? const TaskCountSummary.empty(),
      anytimeCounts:
          anytimeCounts?.toDomain() ?? const TaskCountSummary.empty(),
      anytimePreviewTasks: anytimePreviewTasks.toDomainList(),
      recentCompletedTasks: recentCompletedTasks.toDomainList(),
    );
  }
}

extension TaskSectionResponseDtoMapper on TaskSectionResponseDto {
  TaskSection toDomain() {
    return TaskSection(
      urgentTasks: urgentTasks.toDomainList(),
      dailyTasks: dailyTasks.toDomainList(),
      progressTasks: progressTasks.toDomainList(),
      standardTasks: standardTasks.toDomainList(),
    );
  }
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String? _nullIfBlank(String? value) {
  final text = (value ?? '').trim();
  return text.isEmpty ? null : text;
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;

  final parsed = DateTime.tryParse(value.trim());
  if (parsed == null) return null;

  return DateTime(parsed.year, parsed.month, parsed.day);
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim());
}

List<String> _parseRecurrenceDays(Object? value) {
  if (value == null) return const [];

  if (value is List<dynamic>) {
    return value
        .map((item) => item.toString().trim().toUpperCase())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  if (value is String) {
    return value
        .split(',')
        .map((item) => item.trim().toUpperCase())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  return const [];
}
