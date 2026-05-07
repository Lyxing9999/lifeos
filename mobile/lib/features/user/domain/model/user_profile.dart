class UserProfile {
  final String id;
  final String name;
  final String email;
  final String timezone;
  final String locale;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.timezone,
    required this.locale,
  });

  String get initials {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
