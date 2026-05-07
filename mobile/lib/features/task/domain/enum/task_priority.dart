enum TaskPriority { low, medium, high, critical }

extension TaskPriorityX on TaskPriority {
  static TaskPriority fromApi(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'LOW':
        return TaskPriority.low;
      case 'HIGH':
        return TaskPriority.high;
      case 'CRITICAL':
        return TaskPriority.critical;
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
      case TaskPriority.critical:
        return 'CRITICAL';
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
      case TaskPriority.critical:
        return 'Critical';
    }
  }
}
