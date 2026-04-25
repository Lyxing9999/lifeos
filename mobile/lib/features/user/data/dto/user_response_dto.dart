class UserResponseDto {
  final String? id;
  final String? name;
  final String? email;
  final String? timezone;
  final String? locale;

  const UserResponseDto({
    required this.id,
    required this.name,
    required this.email,
    required this.timezone,
    required this.locale,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      timezone: json['timezone'] as String?,
      locale: json['locale'] as String?,
    );
  }
}
