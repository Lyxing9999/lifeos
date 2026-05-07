enum TaskStatus { todo, inProgress, completed, cancelled }

extension TaskStatusX on TaskStatus {
  static TaskStatus fromApi(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'COMPLETED':
        return TaskStatus.completed;
      case 'CANCELLED':
        return TaskStatus.cancelled;
      case 'TODO':
      default:
        return TaskStatus.todo;
    }
  }

  String get apiValue {
    switch (this) {
      case TaskStatus.todo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.completed:
        return 'COMPLETED';
      case TaskStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Todo';
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isDone => this == TaskStatus.completed;

  bool get isActive =>
      this != TaskStatus.completed && this != TaskStatus.cancelled;
}
