class ScheduleSelectOption {
  final String value;
  final String scheduleBlockId;
  final String label;
  final String title;
  final String type;
  final String startTime;
  final String endTime;
  final bool active;

  const ScheduleSelectOption({
    required this.value,
    required this.scheduleBlockId,
    required this.label,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.active,
  });
}
