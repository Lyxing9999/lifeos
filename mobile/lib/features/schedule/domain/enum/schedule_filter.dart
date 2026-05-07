enum ScheduleFilter { active, inactive }

extension ScheduleFilterX on ScheduleFilter {
  String get label {
    switch (this) {
      case ScheduleFilter.active:
        return 'Active';
      case ScheduleFilter.inactive:
        return 'Inactive & Expired';
    }
  }
}
