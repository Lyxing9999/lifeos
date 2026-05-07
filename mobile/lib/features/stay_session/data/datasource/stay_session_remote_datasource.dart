import '../../../../core/network/api_client.dart';
import '../dto/stay_session_response_dto.dart';

class StaySessionRemoteDataSource {
  final ApiClient apiClient;

  const StaySessionRemoteDataSource(this.apiClient);

  Future<List<StaySessionResponseDto>> getByUserAndDay({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.get(
      '/stay-sessions/user/$userId/day',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) =>
                StaySessionResponseDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Future<String> rebuild({required String userId, required DateTime date}) {
    return apiClient.post(
      '/stay-sessions/rebuild/$userId',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) => rawData?.toString() ?? 'Stay session rebuild queued',
    );
  }

  Future<void> deleteByUserAndDay({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.deleteVoid(
      '/stay-sessions/user/$userId/day',
      queryParameters: {'date': _formatDate(date)},
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
