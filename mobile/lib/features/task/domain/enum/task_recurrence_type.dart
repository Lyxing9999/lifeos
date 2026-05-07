enum TaskRecurrenceType { none, daily, weekly, customWeekly, monthly }

extension TaskRecurrenceTypeX on TaskRecurrenceType {
  static TaskRecurrenceType fromApi(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'DAILY':
        return TaskRecurrenceType.daily;
      case 'WEEKLY':
        return TaskRecurrenceType.weekly;
      case 'CUSTOM_WEEKLY':
      case 'WEEKLY_CUSTOM':
        return TaskRecurrenceType.customWeekly;
      case 'MONTHLY':
        return TaskRecurrenceType.monthly;
      case 'NONE':
      default:
        return TaskRecurrenceType.none;
    }
  }

  String get apiValue {
    switch (this) {
      case TaskRecurrenceType.none:
        return 'NONE';
      case TaskRecurrenceType.daily:
        return 'DAILY';
      case TaskRecurrenceType.weekly:
        return 'WEEKLY';
      case TaskRecurrenceType.customWeekly:
        return 'CUSTOM_WEEKLY';
      case TaskRecurrenceType.monthly:
        return 'MONTHLY';
    }
  }

  String get label {
    switch (this) {
      case TaskRecurrenceType.none:
        return 'No repeat';
      case TaskRecurrenceType.daily:
        return 'Daily';
      case TaskRecurrenceType.weekly:
        return 'Weekly';
      case TaskRecurrenceType.customWeekly:
        return 'Custom weekly';
      case TaskRecurrenceType.monthly:
        return 'Monthly';
    }
  }

  bool get isRecurring => this != TaskRecurrenceType.none;
}
