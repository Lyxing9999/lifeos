class GoogleLoginRequestDto {
  final String idToken;
  final String? timezone;

  const GoogleLoginRequestDto({
    required this.idToken,
    required this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      if (timezone != null && timezone!.trim().isNotEmpty)
        'timezone': timezone!.trim(),
    };
  }
}