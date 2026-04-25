import '../../../../core/network/api_client.dart';
import '../dto/score_response_dto.dart';

class ScoreRemoteDataSource {
  final ApiClient apiClient;

  const ScoreRemoteDataSource(this.apiClient);

  Future<ScoreResponseDto> getDailyScore({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.get(
      '/scores/daily/$userId',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          ScoreResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<ScoreResponseDto> generateDailyScore({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.post(
      '/scores/daily/generate/$userId',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          ScoreResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<void> deleteDailyScore({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.deleteVoid(
      '/scores/daily/$userId',
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
