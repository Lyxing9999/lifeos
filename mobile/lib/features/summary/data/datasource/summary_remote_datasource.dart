import '../../../../core/network/api_client.dart';
import '../dto/summary_response_dto.dart';

class SummaryRemoteDataSource {
  final ApiClient apiClient;

  const SummaryRemoteDataSource(this.apiClient);

  Future<SummaryResponseDto> getDailySummary({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.get(
      '/summaries/daily/$userId',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          SummaryResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<SummaryResponseDto> generateDailySummary({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.post(
      '/summaries/daily/generate/$userId',
      queryParameters: {'date': _formatDate(date)},
      parser: (rawData) =>
          SummaryResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<void> deleteDailySummary({
    required String userId,
    required DateTime date,
  }) {
    return apiClient.deleteVoid(
      '/summaries/daily/$userId',
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
