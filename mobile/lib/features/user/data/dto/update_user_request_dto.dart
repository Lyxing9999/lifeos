class UpdateUserRequestDto {
  final String name;
  final String timezone;
  final String locale;

  const UpdateUserRequestDto({
    required this.name,
    required this.timezone,
    required this.locale,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'timezone': timezone, 'locale': locale};
  }
}
