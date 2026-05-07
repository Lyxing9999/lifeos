class AuthSession {
  final String accessToken;
  final String tokenType;
  final int? expiresInSeconds;
  final String userId;
  final String? email;
  final String? name;
  final String? pictureUrl;
  final String? timezone;
  final String? locale;

  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.userId,
    required this.email,
    required this.name,
    required this.pictureUrl,
    required this.timezone,
    required this.locale,
  });

  bool get isValid => accessToken.isNotEmpty && userId.isNotEmpty;
}