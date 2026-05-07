import '../../../../core/network/api_client.dart';
import '../dto/score_response_dto.dart';

class ScoreRemoteDataSource {
  final ApiClient apiClient;

  const ScoreRemoteDataSource(this.apiClient);

  Future<ScoreResponseDto> getDailyScore({required DateTime date}) {
    return apiClient.get(
      '/score/me/day',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          ScoreResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<ScoreResponseDto> generateDailyScore({required DateTime date}) {
    return apiClient.post(
      '/score/me/generate',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          ScoreResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<void> deleteDailyScore({required DateTime date}) {
    return apiClient.deleteVoid(
      '/score/me/day',
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
