enum ScheduleBlockType {
  work,
  study,
  meeting,
  exercise,
  rest,
  commute,
  personal,
  other,
}

extension ScheduleBlockTypeX on ScheduleBlockType {
  static ScheduleBlockType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'WORK':
        return ScheduleBlockType.work;
      case 'STUDY':
        return ScheduleBlockType.study;
      case 'MEETING':
        return ScheduleBlockType.meeting;
      case 'EXERCISE':
        return ScheduleBlockType.exercise;
      case 'REST':
        return ScheduleBlockType.rest;
      case 'COMMUTE':
        return ScheduleBlockType.commute;
      case 'PERSONAL':
        return ScheduleBlockType.personal;
      default:
        return ScheduleBlockType.other;
    }
  }

  String get apiValue {
    switch (this) {
      case ScheduleBlockType.work:
        return 'WORK';
      case ScheduleBlockType.study:
        return 'STUDY';
      case ScheduleBlockType.meeting:
        return 'MEETING';
      case ScheduleBlockType.exercise:
        return 'EXERCISE';
      case ScheduleBlockType.rest:
        return 'REST';
      case ScheduleBlockType.commute:
        return 'COMMUTE';
      case ScheduleBlockType.personal:
        return 'PERSONAL';
      case ScheduleBlockType.other:
        return 'OTHER';
    }
  }

  String get label {
    switch (this) {
      case ScheduleBlockType.work:
        return 'Work';
      case ScheduleBlockType.study:
        return 'Study';
      case ScheduleBlockType.meeting:
        return 'Meeting';
      case ScheduleBlockType.exercise:
        return 'Exercise';
      case ScheduleBlockType.rest:
        return 'Rest';
      case ScheduleBlockType.commute:
        return 'Commute';
      case ScheduleBlockType.personal:
        return 'Personal';
      case ScheduleBlockType.other:
        return 'Other';
    }
  }
}
