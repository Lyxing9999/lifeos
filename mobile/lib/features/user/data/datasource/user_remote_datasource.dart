import '../../../../core/network/api_client.dart';
import '../dto/update_user_request_dto.dart';
import '../dto/user_response_dto.dart';

class UserRemoteDataSource {
  final ApiClient apiClient;

  const UserRemoteDataSource(this.apiClient);

  Future<List<UserResponseDto>> getAll() {
    return apiClient.get(
      '/users',
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map((item) => UserResponseDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<UserResponseDto> getById(String userId) {
    return apiClient.get(
      '/users/$userId',
      parser: (rawData) =>
          UserResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<UserResponseDto> getProfile(String userId) {
    return apiClient.get(
      '/users/profile/$userId',
      parser: (rawData) =>
          UserResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<UserResponseDto> updateProfile({
    required String userId,
    required UpdateUserRequestDto request,
  }) {
    return apiClient.put(
      '/users/profile/$userId',
      data: request.toJson(),
      parser: (rawData) =>
          UserResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }
}
