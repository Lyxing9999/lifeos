enum ScheduleRecurrenceType { none, daily, weekly, customWeekly, monthly }

extension ScheduleRecurrenceTypeX on ScheduleRecurrenceType {
  static ScheduleRecurrenceType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'DAILY':
        return ScheduleRecurrenceType.daily;
      case 'WEEKLY':
        return ScheduleRecurrenceType.weekly;
      case 'CUSTOM_WEEKLY':
        return ScheduleRecurrenceType.customWeekly;
      case 'MONTHLY':
        return ScheduleRecurrenceType.monthly;
      default:
        return ScheduleRecurrenceType.none;
    }
  }

  String get apiValue {
    switch (this) {
      case ScheduleRecurrenceType.none:
        return 'NONE';
      case ScheduleRecurrenceType.daily:
        return 'DAILY';
      case ScheduleRecurrenceType.weekly:
        return 'WEEKLY';
      case ScheduleRecurrenceType.customWeekly:
        return 'CUSTOM_WEEKLY';
      case ScheduleRecurrenceType.monthly:
        return 'MONTHLY';
    }
  }

  String get label {
    switch (this) {
      case ScheduleRecurrenceType.none:
        return 'Once';
      case ScheduleRecurrenceType.daily:
        return 'Daily';
      case ScheduleRecurrenceType.weekly:
        return 'Weekly';
      case ScheduleRecurrenceType.customWeekly:
        return 'Custom weekly';
      case ScheduleRecurrenceType.monthly:
        return 'Monthly';
    }
  }
}
