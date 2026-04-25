import '../../../../core/network/api_client.dart';
import '../dto/create_schedule_block_request_dto.dart';
import '../dto/schedule_block_response_dto.dart';
import '../dto/schedule_occurrence_response_dto.dart';
import '../dto/update_schedule_block_request_dto.dart';

class ScheduleRemoteDataSource {
  final ApiClient apiClient;

  const ScheduleRemoteDataSource(this.apiClient);

  Future<List<ScheduleBlockResponseDto>> getScheduleBlocksByUser(
    String userId,
  ) {
    return apiClient.get(
      '/schedules/user/$userId',
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) =>
                ScheduleBlockResponseDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<List<ScheduleOccurrenceResponseDto>>
  getScheduleOccurrencesByUserAndDay({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.get(
      '/schedules/user/$userId/day',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) => ScheduleOccurrenceResponseDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Future<ScheduleBlockResponseDto> createScheduleBlock(
    CreateScheduleBlockRequestDto request,
  ) {
    return apiClient.post(
      '/schedules',
      data: request.toJson(),
      parser: (rawData) =>
          ScheduleBlockResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<ScheduleBlockResponseDto> updateScheduleBlock({
    required String id,
    required UpdateScheduleBlockRequestDto request,
  }) {
    return apiClient.patch(
      '/schedules/$id',
      data: request.toJson(),
      parser: (rawData) =>
          ScheduleBlockResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<void> deactivateScheduleBlock(String id) async {
    await apiClient.post<Object?>(
      '/schedules/$id/deactivate',
      parser: (_) => null,
    );
  }

  Future<void> deleteScheduleBlock(String id) {
    return apiClient.deleteVoid('/schedules/$id');
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
