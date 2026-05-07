import '../../../../core/network/api_client.dart';
import '../dto/create_schedule_block_request_dto.dart';
import '../dto/schedule_block_response_dto.dart';
import '../dto/schedule_select_option_response_dto.dart';
import '../dto/update_schedule_block_request_dto.dart';
import '../dto/schedule_surface_response_dto.dart';
import '../../../../core/time/api_date_formatter.dart';

class ScheduleRemoteDataSource {
  final ApiClient apiClient;
  final ApiDateFormatter dateFormatter;

  const ScheduleRemoteDataSource(this.apiClient, this.dateFormatter);

  // ==========================================
  // QUERIES & BFF SURFACES (READ)
  // ==========================================

  Future<ScheduleSurfaceResponseDto> getSurfaces(DateTime date) {
    return apiClient.get(
      '/schedules/me/surfaces',
      queryParameters: {'date': dateFormatter.formatDate(date)},
      parser: (rawData) =>
          ScheduleSurfaceResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<List<ScheduleSelectOptionResponseDto>> getSelectOptions({
    required DateTime date,
  }) {
    return apiClient.get(
      '/schedules/me/select-options',
      queryParameters: {'date': dateFormatter.formatDate(date)},
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) => ScheduleSelectOptionResponseDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Future<ScheduleBlockResponseDto> getScheduleBlockById(String id) {
    return apiClient.get(
      '/schedules/$id',
      parser: (rawData) =>
          ScheduleBlockResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  // ==========================================
  // MUTATIONS (WRITE)
  // ==========================================

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

  Future<void> activateScheduleBlock(String id) async {
    await apiClient.post<Object?>(
      '/schedules/$id/activate',
      parser: (_) => null,
    );
  }

  Future<void> deleteScheduleBlock(String id) {
    return apiClient.deleteVoid('/schedules/$id');
  }
}
