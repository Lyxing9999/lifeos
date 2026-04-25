class UpdateTaskProgressRequestDto {
  final int progressPercent;

  const UpdateTaskProgressRequestDto({required this.progressPercent});

  Map<String, dynamic> toJson() {
    return {'progressPercent': progressPercent};
  }
}
