import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';

import '../entities/task.dart';
import '../enum/task_state_action.dart';

/// Senior-level helper for consistent task state management.
/// Centralizes all pause/resume logic and UI consistency patterns.
class TaskStateHelper {
  TaskStateHelper._();

  /// Check if task can be paused (safety check).
  static bool canPause(Task task) {
    return !task.archived && !task.paused && !task.status.isDone;
  }

  /// Check if task can be resumed (safety check).
  static bool canResume(Task task) {
    return !task.archived && task.paused;
  }

  /// Get the applicable state action for a task (if any).
  static TaskStateAction? getApplicableStateAction(Task task) {
    if (canResume(task)) return TaskStateAction.resume;
    if (canPause(task)) return TaskStateAction.pause;
    return null;
  }

  /// Validate if action is safe to perform on task.
  static bool isActionSafeFor({
    required Task task,
    required TaskStateAction action,
  }) {
    switch (action) {
      case TaskStateAction.pause:
        return canPause(task);
      case TaskStateAction.resume:
        return canResume(task);
    }
  }

  /// Get all available state actions for a task (for consistency).
  static List<TaskStateAction> getAvailableStateActions(Task task) {
    final actions = <TaskStateAction>[];
    if (canPause(task)) actions.add(TaskStateAction.pause);
    if (canResume(task)) actions.add(TaskStateAction.resume);
    return actions;
  }
}
