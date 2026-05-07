import '../../../../core/network/api_client.dart';
import '../dto/timeline_day_response_dto.dart';

class TimelineRemoteDataSource {
  final ApiClient apiClient;

  const TimelineRemoteDataSource(this.apiClient);

  Future<TimelineDayResponseDto> getDay({required DateTime date}) {
    return apiClient.get(
      '/timeline/me/day',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          TimelineDayResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
