class TaskTagResponseDto {
  final String? name;

  const TaskTagResponseDto({this.name});

  factory TaskTagResponseDto.fromJson(Map<String, dynamic> json) {
    return TaskTagResponseDto(name: json['name'] as String?);
  }
}
