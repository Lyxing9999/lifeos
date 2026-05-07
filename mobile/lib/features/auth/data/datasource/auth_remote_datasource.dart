import '../../../../core/network/api_client.dart';
import '../dto/auth_response_dto.dart';
import '../dto/login_request_dto.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSource(this.apiClient);

  Future<AuthLoginResponseDto> loginWithGoogle({
    required String idToken,
    String? timezone,
  }) {
    final request = GoogleLoginRequestDto(
      idToken: idToken,
      timezone: timezone,
    );

    return apiClient.post(
      '/auth/google',
      data: request.toJson(),
      parser: (rawData) =>
          AuthLoginResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<AuthUserResponseDto> getCurrentUser() {
    return apiClient.get(
      '/auth/me',
      parser: (rawData) =>
          AuthUserResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }
}