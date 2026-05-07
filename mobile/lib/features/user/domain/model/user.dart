class AppUser {
  final String id;
  final String name;
  final String email;
  final String timezone;
  final String locale;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.timezone,
    required this.locale,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? timezone,
    String? locale,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
    );
  }
}
