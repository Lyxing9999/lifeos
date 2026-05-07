import '../../../../core/network/api_client.dart';
import '../dto/summary_response_dto.dart';

class SummaryRemoteDataSource {
  final ApiClient apiClient;

  const SummaryRemoteDataSource(this.apiClient);

  Future<SummaryResponseDto> getDailySummary({required DateTime date}) {
    return apiClient.get(
      '/summaries/daily/me',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          SummaryResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<SummaryResponseDto> generateDailySummary({required DateTime date}) {
    return apiClient.post(
      '/summaries/daily/me/generate',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          SummaryResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<void> deleteDailySummary({required DateTime date}) {
    return apiClient.deleteVoid(
      '/summaries/daily/me',
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
