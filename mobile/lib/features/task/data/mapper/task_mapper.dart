import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_recurrence_type.dart';
import '../../domain/enum/task_status.dart';
import '../../domain/model/task.dart';
import '../../domain/model/task_count_summary.dart';
import '../../domain/model/task_overview.dart';
import '../../domain/model/task_section.dart';
import '../../domain/model/task_tag.dart';
import '../dto/task_count_summary_dto.dart';
import '../dto/task_overview_response_dto.dart';
import '../dto/task_response_dto.dart';
import '../dto/task_section_response_dto.dart';

class TaskMapper {
  const TaskMapper();

  Task toDomain(TaskResponseDto dto) {
    return Task(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      title: dto.title ?? '',
      description: dto.description,
      category: dto.category,
      status: TaskStatusX.fromApi(dto.status),
      taskMode: TaskModeX.fromApi(dto.taskMode),
      priority: TaskPriorityX.fromApi(dto.priority),
      dueDate: _parseDateTime(dto.dueDate),
      dueDateTime: _parseDateTime(dto.dueDateTime),
      progressPercent: dto.progressPercent ?? 0,
      startedAt: _parseDateTime(dto.startedAt),
      completedAt: _parseDateTime(dto.completedAt),
      archived: dto.archived ?? false,
      recurrenceType: TaskRecurrenceTypeX.fromApi(dto.recurrenceType),
      recurrenceStartDate: _parseDateTime(dto.recurrenceStartDate),
      recurrenceEndDate: _parseDateTime(dto.recurrenceEndDate),
      recurrenceDaysOfWeek: dto.recurrenceDaysOfWeek ?? const [],
      linkedScheduleBlockId: dto.linkedScheduleBlockId,
      tags: (dto.tags ?? const [])
          .map((tag) => TaskTag(name: (tag.name ?? '').trim()))
          .where((tag) => tag.name.isNotEmpty)
          .toList(),
    );
  }

  TaskOverview toOverviewDomain(TaskOverviewResponseDto dto) {
    return TaskOverview(
      date: _parseDateTime(dto.date) ?? DateTime.now(),
      currentTask: dto.currentTask == null ? null : toDomain(dto.currentTask!),
      currentUrgentTask: dto.currentUrgentTask == null
          ? null
          : toDomain(dto.currentUrgentTask!),
      currentDailyTask: dto.currentDailyTask == null
          ? null
          : toDomain(dto.currentDailyTask!),
      currentProgressTask: dto.currentProgressTask == null
          ? null
          : toDomain(dto.currentProgressTask!),
      todaySections: _toSection(dto.todaySections),
      last3DaySections: _toSection(dto.last3DaySections),
      last7DaySections: _toSection(dto.last7DaySections),
      last30DaySections: _toSection(dto.last30DaySections),
      todayCounts: _toCountSummary(dto.todayCounts),
      last3DayCounts: _toCountSummary(dto.last3DayCounts),
      last7DayCounts: _toCountSummary(dto.last7DayCounts),
      last30DayCounts: _toCountSummary(dto.last30DayCounts),
      recentCompletedTasks: dto.recentCompletedTasks.map(toDomain).toList(),
    );
  }

  TaskSection toSectionDomain(TaskSectionResponseDto dto) => _toSection(dto);

  TaskSection _toSection(TaskSectionResponseDto? dto) {
    if (dto == null) return const TaskSection.empty();

    return TaskSection(
      urgentTasks: dto.urgentTasks.map(toDomain).toList(),
      dailyTasks: dto.dailyTasks.map(toDomain).toList(),
      progressTasks: dto.progressTasks.map(toDomain).toList(),
      standardTasks: dto.standardTasks.map(toDomain).toList(),
    );
  }

  TaskCountSummary _toCountSummary(TaskCountSummaryDto? dto) {
    if (dto == null) return const TaskCountSummary.empty();

    return TaskCountSummary(
      total: dto.total ?? 0,
      active: dto.active ?? 0,
      completed: dto.completed ?? 0,
      urgent: dto.urgent ?? 0,
      daily: dto.daily ?? 0,
      progress: dto.progress ?? 0,
    );
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
