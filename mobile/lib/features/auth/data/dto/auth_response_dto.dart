class AuthUserResponseDto {
  final String? id;
  final String? name;
  final String? email;
  final String? pictureUrl;
  final String? timezone;
  final String? locale;

  const AuthUserResponseDto({
    required this.id,
    required this.name,
    required this.email,
    required this.pictureUrl,
    required this.timezone,
    required this.locale,
  });

  factory AuthUserResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthUserResponseDto(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      pictureUrl: json['pictureUrl'] as String?,
      timezone: json['timezone'] as String?,
      locale: json['locale'] as String?,
    );
  }
}

class AuthLoginResponseDto {
  final String? accessToken;
  final String? tokenType;
  final int? expiresInSeconds;
  final AuthUserResponseDto? user;

  const AuthLoginResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.user,
  });

  factory AuthLoginResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponseDto(
      accessToken: json['accessToken'] as String?,
      tokenType: json['tokenType'] as String?,
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt(),
      user: json['user'] == null
          ? null
          : AuthUserResponseDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}