import '../../domain/model/auth_session.dart';
import '../../domain/model/auth_user.dart';
import '../dto/auth_response_dto.dart';

class AuthMapper {
  const AuthMapper();

  AuthUser toUser(AuthUserResponseDto dto) {
    final id = dto.id;

    if (id == null || id.isEmpty) {
      throw Exception('Invalid auth user response: missing id');
    }

    return AuthUser(
      id: id,
      name: dto.name,
      email: dto.email,
      pictureUrl: dto.pictureUrl,
      timezone: dto.timezone,
      locale: dto.locale,
    );
  }

  AuthSession toSession(AuthLoginResponseDto dto) {
    final accessToken = dto.accessToken;
    final user = dto.user;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Invalid auth response: missing access token');
    }

    if (user == null || user.id == null || user.id!.isEmpty) {
      throw Exception('Invalid auth response: missing user');
    }

    return AuthSession(
      accessToken: accessToken,
      tokenType: dto.tokenType ?? 'Bearer',
      expiresInSeconds: dto.expiresInSeconds,
      userId: user.id!,
      email: user.email,
      name: user.name,
      pictureUrl: user.pictureUrl,
      timezone: user.timezone,
      locale: user.locale,
    );
  }
}