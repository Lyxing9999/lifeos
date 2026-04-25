enum TaskStatus { todo, inProgress, completed }

extension TaskStatusX on TaskStatus {
  static TaskStatus fromApi(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'IN_PROGRESS':
      case 'INPROGRESS':
        return TaskStatus.inProgress;
      case 'COMPLETED':
      case 'DONE':
        return TaskStatus.completed;
      case 'TODO':
      case 'TO_DO':
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
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  bool get isDone => this == TaskStatus.completed;
}
