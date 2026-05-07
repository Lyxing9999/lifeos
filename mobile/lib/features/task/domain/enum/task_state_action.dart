/// Senior-level enum for consistent task state actions (pause/resume).
/// Ensures symmetric, predictable behavior across the entire task system.
enum TaskStateAction {
  pause,
  resume;

  /// Get the human-readable action name for UI display.
  String get displayName {
    switch (this) {
      case TaskStateAction.pause:
        return 'Pause';
      case TaskStateAction.resume:
        return 'Resume';
    }
  }

  /// Check if action is pause operation.
  bool get isPause => this == TaskStateAction.pause;

  /// Check if action is resume operation.
  bool get isResume => this == TaskStateAction.resume;

  /// Get the opposite action (pause ↔ resume).
  TaskStateAction get toggle {
    switch (this) {
      case TaskStateAction.pause:
        return TaskStateAction.resume;
      case TaskStateAction.resume:
        return TaskStateAction.pause;
    }
  }
}
