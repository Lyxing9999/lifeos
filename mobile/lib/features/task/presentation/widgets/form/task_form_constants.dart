const List<String> taskCategoryOptions = <String>[
  'Work',
  'Learning',
  'Health',
  'Personal',
  'Home',
  'Finance',
  'Admin',
  'Other',
];
const List<String> taskWeekdayOptions = <String>[
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

String taskWeekdayLabel(String day) {
  switch (day) {
    case 'MONDAY':
      return 'Mon';
    case 'TUESDAY':
      return 'Tue';
    case 'WEDNESDAY':
      return 'Wed';
    case 'THURSDAY':
      return 'Thu';
    case 'FRIDAY':
      return 'Fri';
    case 'SATURDAY':
      return 'Sat';
    case 'SUNDAY':
      return 'Sun';
    default:
      return day;
  }
}
