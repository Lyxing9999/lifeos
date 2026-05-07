import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_status.dart';

abstract final class TaskStyle {
  // ───────────────────────────────────────────────────────────────────────────
  // Mode
  // ───────────────────────────────────────────────────────────────────────────

  static Color modeColor(TaskMode mode) {
    switch (mode) {
      case TaskMode.urgent:
        return AppColors.warning;
      case TaskMode.progress:
        return AppColors.blue;
      case TaskMode.daily:
        return AppColors.green;
      case TaskMode.standard:
        return AppColors.slate;
    }
  }

  static Color modeBackgroundColor(BuildContext context, TaskMode mode) {
    return AppColors.chipBg(context, modeColor(mode));
  }

  static IconData modeIcon(TaskMode mode) {
    switch (mode) {
      case TaskMode.standard:
        return AppIcons.standardTask;
      case TaskMode.daily:
        return AppIcons.dailyTask;
      case TaskMode.urgent:
        return AppIcons.urgentTask;
      case TaskMode.progress:
        return AppIcons.progressTask;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Priority
  // ───────────────────────────────────────────────────────────────────────────

  static Color priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.slate;
      case TaskPriority.medium:
        return AppColors.blue;
      case TaskPriority.high:
        return AppColors.warning;
      case TaskPriority.critical:
        return AppColors.danger;
    }
  }

  static Color priorityBackgroundColor(
    BuildContext context,
    TaskPriority priority,
  ) {
    return AppColors.chipBg(context, priorityColor(priority));
  }

  static IconData priorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppIcons.lowPriority;
      case TaskPriority.medium:
        return AppIcons.priority;
      case TaskPriority.high:
        return AppIcons.highPriority;
      case TaskPriority.critical:
        return AppIcons.warning;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Status
  // ───────────────────────────────────────────────────────────────────────────

  static Color statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.slate;
      case TaskStatus.inProgress:
        return AppColors.blue;
      case TaskStatus.completed:
        return AppColors.green;
      case TaskStatus.cancelled:
        return AppColors.slate;
    }
  }

  static Color statusBackgroundColor(BuildContext context, TaskStatus status) {
    return AppColors.chipBg(context, statusColor(status));
  }

  static IconData statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppIcons.incomplete;
      case TaskStatus.inProgress:
        return AppIcons.time;
      case TaskStatus.completed:
        return AppIcons.complete;
      case TaskStatus.cancelled:
        return AppIcons.close;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Overview / dashboard semantic colors
  // ───────────────────────────────────────────────────────────────────────────

  static Color activeColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color completedColor() {
    return AppColors.green;
  }

  static Color urgentColor() {
    return AppColors.warning;
  }

  static Color criticalColor() {
    return AppColors.danger;
  }

  static Color archivedColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color pausedColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Due date
  // ───────────────────────────────────────────────────────────────────────────

  static Color dueColor({
    required DateTime? due,
    required DateTime today,
    required TaskStatus status,
    bool archived = false,
    bool paused = false,
  }) {
    if (archived || paused || status.isDone || due == null) {
      return AppColors.slate;
    }

    final todayOnly = _localDay(today);
    final dueDay = _localDay(due);

    if (dueDay.isBefore(todayOnly)) {
      return overdueColor();
    }

    if (dueDay.isAtSameMomentAs(todayOnly)) {
      return dueTodayColor();
    }

    return AppColors.slate;
  }

  static Color overdueColor() {
    return AppColors.danger;
  }

  static Color dueTodayColor() {
    return AppColors.warning;
  }

  static IconData dueIcon({
    required DateTime? due,
    required DateTime today,
    required TaskStatus status,
    
    bool archived = false,
    bool paused = false,
  }) {
    if (archived) {
      return AppIcons.archive;
    }

    if (paused) {
      return AppIcons.paused;
    }

    if (status.isDone) {
      return AppIcons.todayActive;
    }

    if (due == null) {
      return AppIcons.calendar;
    }

    final todayOnly = _localDay(today);
    final dueDay = _localDay(due);

    if (dueDay.isBefore(todayOnly)) {
      return AppIcons.warning;
    }

    if (dueDay.isAtSameMomentAs(todayOnly)) {
      return AppIcons.today;
    }

    return AppIcons.calendar;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Progress
  // ───────────────────────────────────────────────────────────────────────────

  static Color progressColor(int progress) {
    final clamped = progress.clamp(0, 100);

    if (clamped >= 100) {
      return AppColors.success;
    }

    return AppColors.scoreColor(clamped);
  }

  static Color progressTrackColor(BuildContext context) {
    return Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Actions
  // ───────────────────────────────────────────────────────────────────────────

  static Color completeActionColor() {
    return AppColors.green;
  }

  static Color reopenActionColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color pauseActionColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color resumeActionColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color archiveActionColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static Color restoreActionColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color deleteActionColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  static Color actionBackgroundColor(BuildContext context, Color color) {
    return AppColors.chipBg(context, color);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Linked schedule
  // ───────────────────────────────────────────────────────────────────────────

  static Color linkedScheduleColor() {
    return AppColors.violet;
  }

  static IconData linkedScheduleIcon() {
    return AppIcons.linked;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Tags / category
  // ───────────────────────────────────────────────────────────────────────────

  static Color categoryColor() {
    return AppColors.slate;
  }

  static IconData categoryIcon() {
    return AppIcons.label;
  }

  static Color tagColor() {
    return AppColors.teal;
  }

  static IconData tagIcon() {
    return AppIcons.tags;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Card state helpers
  // ───────────────────────────────────────────────────────────────────────────

  static Color titleColor(
    BuildContext context, {
    required bool completed,
    required bool archived,
    bool paused = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    if (completed || archived || paused) {
      return scheme.onSurfaceVariant;
    }

    return scheme.onSurface;
  }

  static TextDecoration? titleDecoration({required bool completed}) {
    return completed ? TextDecoration.lineThrough : null;
  }

  static Color checkboxBorderColor(
    BuildContext context, {
    required bool archived,
    bool paused = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    if (archived || paused) {
      return scheme.outline.withValues(alpha: 0.45);
    }

    return scheme.outline;
  }

  static Color checkboxFillColor(
    BuildContext context, {
    required bool completed,
    required bool archived,
    bool paused = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    if (archived || paused) {
      return scheme.surfaceContainerHighest;
    }

    if (completed) {
      return completedColor();
    }

    return Colors.transparent;
  }

  static Color checkboxIconColor(
    BuildContext context, {
    required bool archived,
    bool paused = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    if (archived || paused) {
      return scheme.onSurfaceVariant;
    }

    return scheme.onPrimary;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Labels
  // ───────────────────────────────────────────────────────────────────────────

  static String completionActionLabel(TaskStatus status) {
    return status.isDone ? 'Reopen task' : 'Complete task';
  }

  static String detailCompletionActionLabel({
    required TaskStatus status,
    required bool recurring,
  }) {
    if (!status.isDone) {
      return 'Mark as complete';
    }

    return recurring ? 'Reopen today' : 'Mark incomplete';
  }

  static String archiveActionLabel({required bool archived}) {
    return archived ? 'Restore task' : 'Archive task';
  }

  static String pauseActionLabel({required bool paused}) {
    return paused ? 'Resume task' : 'Pause task';
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ───────────────────────────────────────────────────────────────────────────

  static DateTime _localDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
