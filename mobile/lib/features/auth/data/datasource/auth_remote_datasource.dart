import '../../../../core/network/api_client.dart';
import '../dto/auth_response_dto.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSource(this.apiClient);

  Future<AuthUserResponseDto> createDemoUser() {
    return apiClient.post(
      '/users/demo',
      parser: (rawData) =>
          AuthUserResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }
}
