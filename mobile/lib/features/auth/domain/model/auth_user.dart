class AuthUser {
  final String id;
  final String? name;
  final String? email;
  final String? pictureUrl;
  final String? timezone;
  final String? locale;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.pictureUrl,
    required this.timezone,
    required this.locale,
  });
}