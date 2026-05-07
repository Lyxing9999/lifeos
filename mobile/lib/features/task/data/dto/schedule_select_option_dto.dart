class ScheduleSelectOptionDto {
  final String? value;
  final String? scheduleBlockId;
  final String? label;
  final String? title;
  final String? type;
  final String? startTime;
  final String? endTime;
  final bool? active;

  const ScheduleSelectOptionDto({
    this.value,
    this.scheduleBlockId,
    this.label,
    this.title,
    this.type,
    this.startTime,
    this.endTime,
    this.active,
  });

  factory ScheduleSelectOptionDto.fromJson(Map<String, dynamic> json) {
    return ScheduleSelectOptionDto(
      value: json['value'] as String?,
      scheduleBlockId: json['scheduleBlockId'] as String?,
      label: json['label'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      active: json['active'] as bool?,
    );
  }
}
