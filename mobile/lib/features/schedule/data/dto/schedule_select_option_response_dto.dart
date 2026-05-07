class ScheduleSelectOptionResponseDto {
  final String? value;
  final String? scheduleBlockId;
  final String? label;
  final String? title;
  final String? type;
  final String? startTime;
  final String? endTime;
  final bool? active;

  const ScheduleSelectOptionResponseDto({
    required this.value,
    required this.scheduleBlockId,
    required this.label,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.active,
  });

  factory ScheduleSelectOptionResponseDto.fromJson(Map<String, dynamic> json) {
    return ScheduleSelectOptionResponseDto(
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
