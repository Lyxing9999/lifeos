import '../../../../core/network/api_client.dart';
import '../dto/create_location_log_batch_request_dto.dart';
import '../dto/location_batch_ingest_response_dto.dart';
import '../dto/location_log_response_dto.dart';

class LocationRemoteDataSource {
  final ApiClient apiClient;

  const LocationRemoteDataSource(this.apiClient);

  Future<List<LocationLogResponseDto>> getByUserAndDay({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.get(
      '/location/user/$userId/day',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) =>
                LocationLogResponseDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<LocationBatchIngestResponseDto> createBatch(
    CreateLocationLogBatchRequestDto request,
  ) {
    return apiClient.post(
      '/location/batch',
      data: request.toJson(),
      parser: (rawData) => LocationBatchIngestResponseDto.fromJson(
        rawData as Map<String, dynamic>,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
