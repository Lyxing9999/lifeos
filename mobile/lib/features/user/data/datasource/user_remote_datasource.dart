import '../../../../core/network/api_client.dart';
import '../dto/update_user_request_dto.dart';
import '../dto/user_response_dto.dart';

class UserRemoteDataSource {
  final ApiClient apiClient;

  const UserRemoteDataSource(this.apiClient);

  Future<UserResponseDto> getProfile() {
    return apiClient.get(
      '/users/me',
      parser: (rawData) =>
          UserResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<UserResponseDto> updateProfile(UpdateUserRequestDto request) {
    return apiClient.put(
      '/users/me',
      data: request.toJson(),
      parser: (rawData) =>
          UserResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }
}
