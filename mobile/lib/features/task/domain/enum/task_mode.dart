enum TaskMode { standard, daily, urgent, progress }

extension TaskModeX on TaskMode {
  static TaskMode fromApi(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'DAILY':
        return TaskMode.daily;
      case 'URGENT':
        return TaskMode.urgent;
      case 'PROGRESS':
        return TaskMode.progress;
      case 'STANDARD':
      default:
        return TaskMode.standard;
    }
  }

  String get apiValue {
    switch (this) {
      case TaskMode.standard:
        return 'STANDARD';
      case TaskMode.daily:
        return 'DAILY';
      case TaskMode.urgent:
        return 'URGENT';
      case TaskMode.progress:
        return 'PROGRESS';
    }
  }

  String get label {
    switch (this) {
      case TaskMode.standard:
        return 'Standard';
      case TaskMode.daily:
        return 'Daily';
      case TaskMode.urgent:
        return 'Urgent';
      case TaskMode.progress:
        return 'Progress';
    }
  }
}
