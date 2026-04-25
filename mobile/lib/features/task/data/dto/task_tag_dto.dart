class TaskTagDto {
  final String? name;

  const TaskTagDto({required this.name});

  factory TaskTagDto.fromJson(Map<String, dynamic> json) {
    return TaskTagDto(name: json['name'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
