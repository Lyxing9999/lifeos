import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../dto/create_payway_payment_link_request_dto.dart';
import '../dto/financial_event_response_dto.dart';
import '../dto/financial_summary_response_dto.dart';
import '../dto/payway_callback_log_response_dto.dart';
import '../dto/payway_callback_payload_dto.dart';
import '../dto/payway_create_payment_link_response_dto.dart';

class FinancialRemoteDataSource {
  final ApiClient apiClient;

  const FinancialRemoteDataSource(this.apiClient);

  Future<List<FinancialEventResponseDto>> getEventsByDay({
    required String userId,
    required DateTime date,
    required String timezone,
  }) {
    return apiClient.get(
      '/financial-events/user/$userId/day',
      queryParameters: {'date': _formatDate(date), 'timezone': timezone},
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) => FinancialEventResponseDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Future<List<FinancialEventResponseDto>> getEventsByRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String timezone,
  }) {
    return apiClient.get(
      '/financial-events/user/$userId/range',
      queryParameters: {
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
        'timezone': timezone,
      },
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) => FinancialEventResponseDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Future<FinancialSummaryResponseDto> getDaySummary({
    required String userId,
    required DateTime date,
    required String timezone,
  }) {
    return apiClient.get(
      '/financial-events/user/$userId/day-summary',
      queryParameters: {'date': _formatDate(date), 'timezone': timezone},
      parser: (rawData) =>
          FinancialSummaryResponseDto.fromJson(rawData as Map<String, dynamic>),
    );
  }

  Future<void> deleteEvent(String id) {
    return apiClient.deleteVoid('/financial-events/$id');
  }

  Future<String> importCsv({
    required String userId,
    required String timezone,
    required List<int> bytes,
    required String fileName,
  }) {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    return apiClient.post(
      '/financial-import/csv/$userId',
      queryParameters: {'timezone': timezone},
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
      parser: (rawData) => rawData as String? ?? 'Imported',
    );
  }

  Future<PayWayCreatePaymentLinkResponseDto> createPaymentLink({
    required String userId,
    required CreatePayWayPaymentLinkRequestDto request,
  }) {
    return apiClient.post(
      '/financial-provider/payway/payment-link/create/$userId',
      data: request.toJson(),
      parser: (rawData) => PayWayCreatePaymentLinkResponseDto.fromJson(
        rawData as Map<String, dynamic>,
      ),
    );
  }

  Future<void> simulateCallback({
    required String userId,
    required PayWayCallbackPayloadDto payload,
  }) {
    return apiClient.post<void>(
      '/financial-provider/payway/callback/$userId',
      data: payload.toJson(),
      parser: (_) {},
    );
  }

  Future<List<PayWayCallbackLogResponseDto>> getCallbackLogs(String userId) {
    return apiClient.get(
      '/financial-provider/payway/callback-logs/user/$userId',
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) => PayWayCallbackLogResponseDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Future<List<FinancialEventResponseDto>> pollPayWay({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
    required String timezone,
  }) {
    return apiClient.post(
      '/financial-provider/payway/polling/poll/$userId',
      queryParameters: {
        'fromDate': _formatDate(fromDate),
        'toDate': _formatDate(toDate),
        'timezone': timezone,
      },
      parser: (rawData) => (rawData as List<dynamic>? ?? [])
          .map(
            (item) => FinancialEventResponseDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
