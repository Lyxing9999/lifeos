import '../../../../core/network/api_client.dart';
import '../dto/today_response_dto.dart';

class TodayRemoteDataSource {
  final ApiClient apiClient;

  const TodayRemoteDataSource(this.apiClient);

  Future<TodayResponseDto> getToday({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.get(
      '/today/$userId',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          TodayResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
