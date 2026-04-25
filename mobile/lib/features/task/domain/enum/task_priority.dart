enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  static TaskPriority fromApi(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'LOW':
        return TaskPriority.low;
      case 'HIGH':
        return TaskPriority.high;
      case 'MEDIUM':
      default:
        return TaskPriority.medium;
    }
  }

  String get apiValue {
    switch (this) {
      case TaskPriority.low:
        return 'LOW';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.high:
        return 'HIGH';
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}
