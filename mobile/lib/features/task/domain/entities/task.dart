import '../enum/task_mode.dart';
import '../enum/task_priority.dart';
import '../enum/task_recurrence_type.dart';
import '../enum/task_status.dart';
import 'task_tag.dart';

class Task {
  final String id;
  final String userId;

  final String title;
  final String? description;
  final String? category;

  final TaskStatus status;
  final TaskMode taskMode;
  final TaskPriority priority;

  /// LocalDate from backend.
  final DateTime? dueDate;

  /// LocalDateTime from backend.
  final DateTime? dueDateTime;

  final int progressPercent;

  /// Backend Instant.
  final DateTime? startedAt;

  /// Backend Instant.
  final DateTime? completedAt;

  /// LocalDate product completion day.
  final DateTime? achievedDate;

  /// Backend Instant.
  final DateTime? doneClearedAt;

  final bool archived;

  final bool paused;

  /// Backend Instant.
  final DateTime? pausedAt;

  /// LocalDate from backend.
  final DateTime? pauseUntil;

  final TaskRecurrenceType recurrenceType;
  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;

  /// Flutter keeps this as a list.
  ///
  /// Backend sends/stores comma-separated string.
  final List<String> recurrenceDaysOfWeek;

  final String? linkedScheduleBlockId;

  final List<TaskTag> tags;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.category,
    required this.status,
    required this.taskMode,
    required this.priority,
    this.dueDate,
    this.dueDateTime,
    required this.progressPercent,
    this.startedAt,
    this.completedAt,
    this.achievedDate,
    this.doneClearedAt,
    required this.archived,
    required this.paused,
    this.pausedAt,
    this.pauseUntil,
    required this.recurrenceType,
    this.recurrenceStartDate,
    this.recurrenceEndDate,
    required this.recurrenceDaysOfWeek,
    this.linkedScheduleBlockId,
    required this.tags,
  });

  bool get isDone => status.isDone;

  bool get isArchived => archived;

  bool get isPaused => paused;

  bool get isRecurring => recurrenceType.isRecurring;

  bool get isScheduleLinked {
    return (linkedScheduleBlockId ?? '').trim().isNotEmpty;
  }

  bool get hasDueDate {
    return dueDate != null || dueDateTime != null;
  }

  bool get isProgressTask {
    return taskMode == TaskMode.progress;
  }

  bool get isActive {
    return status.isActive && !archived && !paused;
  }

  bool get isInbox {
    return status.isActive &&
        !archived &&
        !paused &&
        dueDate == null &&
        dueDateTime == null &&
        !recurrenceType.isRecurring &&
        (linkedScheduleBlockId ?? '').trim().isEmpty;
  }

  bool get isOverdue {
    if (!isActive || isDone) {
      return false;
    }

    final due = dueDateTime ?? dueDate;

    if (due == null) {
      return false;
    }

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final dueDay = DateTime(due.year, due.month, due.day);

    return dueDay.isBefore(today);
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    TaskStatus? status,
    TaskMode? taskMode,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? dueDateTime,
    int? progressPercent,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? achievedDate,
    DateTime? doneClearedAt,
    bool? archived,
    bool? paused,
    DateTime? pausedAt,
    DateTime? pauseUntil,
    TaskRecurrenceType? recurrenceType,
    DateTime? recurrenceStartDate,
    DateTime? recurrenceEndDate,
    List<String>? recurrenceDaysOfWeek,
    String? linkedScheduleBlockId,
    List<TaskTag>? tags,
    bool clearDescription = false,
    bool clearCategory = false,
    bool clearDueDate = false,
    bool clearDueDateTime = false,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
    bool clearAchievedDate = false,
    bool clearDoneClearedAt = false,
    bool clearPausedAt = false,
    bool clearPauseUntil = false,
    bool clearRecurrenceStartDate = false,
    bool clearRecurrenceEndDate = false,
    bool clearRecurrenceDaysOfWeek = false,
    bool clearLinkedScheduleBlockId = false,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: clearDescription ? null : description ?? this.description,
      category: clearCategory ? null : category ?? this.category,
      status: status ?? this.status,
      taskMode: taskMode ?? this.taskMode,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      dueDateTime: clearDueDateTime ? null : dueDateTime ?? this.dueDateTime,
      progressPercent: progressPercent ?? this.progressPercent,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      achievedDate: clearAchievedDate
          ? null
          : achievedDate ?? this.achievedDate,
      doneClearedAt: clearDoneClearedAt
          ? null
          : doneClearedAt ?? this.doneClearedAt,
      archived: archived ?? this.archived,
      paused: paused ?? this.paused,
      pausedAt: clearPausedAt ? null : pausedAt ?? this.pausedAt,
      pauseUntil: clearPauseUntil ? null : pauseUntil ?? this.pauseUntil,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceStartDate: clearRecurrenceStartDate
          ? null
          : recurrenceStartDate ?? this.recurrenceStartDate,
      recurrenceEndDate: clearRecurrenceEndDate
          ? null
          : recurrenceEndDate ?? this.recurrenceEndDate,
      recurrenceDaysOfWeek: clearRecurrenceDaysOfWeek
          ? const []
          : recurrenceDaysOfWeek ?? this.recurrenceDaysOfWeek,
      linkedScheduleBlockId: clearLinkedScheduleBlockId
          ? null
          : linkedScheduleBlockId ?? this.linkedScheduleBlockId,
      tags: tags ?? this.tags,
    );
  }
}
