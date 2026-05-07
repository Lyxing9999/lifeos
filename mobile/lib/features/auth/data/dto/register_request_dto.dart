class RegisterRequestDto {
  final String name;
  final String email;
  final String timezone;

  const RegisterRequestDto({
    required this.name,
    required this.email,
    required this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'timezone': timezone,
    };
  }
}