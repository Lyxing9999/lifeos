import '../../../../core/network/api_client.dart';
import '../dto/create_place_request_dto.dart';
import '../dto/place_response_dto.dart';
import '../dto/update_place_request_dto.dart';

class PlaceRemoteDataSource {
  final ApiClient apiClient;

  const PlaceRemoteDataSource(this.apiClient);

  Future<List<PlaceResponseDto>> getPlacesByUser(String userId) {
    return apiClient.get(
      '/places/user/$userId',
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) => PlaceResponseDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<PlaceResponseDto> getPlaceById(String id) {
    return apiClient.get(
      '/places/$id',
      parser: (rawData) =>
          PlaceResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<PlaceResponseDto> createPlace(CreatePlaceRequestDto request) {
    return apiClient.post(
      '/places',
      data: request.toJson(),
      parser: (rawData) =>
          PlaceResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<PlaceResponseDto> updatePlace({
    required String id,
    required UpdatePlaceRequestDto request,
  }) {
    return apiClient.patch(
      '/places/$id',
      data: request.toJson(),
      parser: (rawData) =>
          PlaceResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<void> deletePlace(String id) {
    return apiClient.deleteVoid('/places/$id');
  }
}
