import '../../domain/model/financial_event.dart';
import '../../domain/model/financial_summary.dart';
import '../../domain/model/payway_callback_log.dart';
import '../../domain/model/payway_payment_link.dart';
import '../../domain/repository/financial_repository.dart';
import '../datasource/financial_remote_datasource.dart';
import '../dto/create_payway_payment_link_request_dto.dart';
import '../dto/payway_callback_payload_dto.dart';
import '../mapper/financial_mapper.dart';

class FinancialRepositoryImpl implements FinancialRepository {
  final FinancialRemoteDataSource remoteDataSource;
  final FinancialMapper mapper;

  const FinancialRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<List<FinancialEvent>> getEventsByDay({
    required String userId,
    required DateTime date,
    required String timezone,
  }) async {
    final dtos = await remoteDataSource.getEventsByDay(
      userId: userId,
      date: date,
      timezone: timezone,
    );
    return dtos.map(mapper.toEventDomain).toList();
  }

  @override
  Future<List<FinancialEvent>> getEventsByRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String timezone,
  }) async {
    final dtos = await remoteDataSource.getEventsByRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      timezone: timezone,
    );
    return dtos.map(mapper.toEventDomain).toList();
  }

  @override
  Future<FinancialSummary> getDaySummary({
    required String userId,
    required DateTime date,
    required String timezone,
  }) async {
    final dto = await remoteDataSource.getDaySummary(
      userId: userId,
      date: date,
      timezone: timezone,
    );
    return mapper.toSummaryDomain(dto);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await remoteDataSource.deleteEvent(id);
  }

  @override
  Future<String> importCsv({
    required String userId,
    required String timezone,
    required List<int> bytes,
    required String fileName,
  }) {
    return remoteDataSource.importCsv(
      userId: userId,
      timezone: timezone,
      bytes: bytes,
      fileName: fileName,
    );
  }

  @override
  Future<PayWayPaymentLink> createPaymentLink({
    required String userId,
    required String title,
    required String amount,
    required String currency,
    String? description,
    String? paymentLimit,
    String? expiredDate,
    String? merchantRefNo,
  }) async {
    final dto = await remoteDataSource.createPaymentLink(
      userId: userId,
      request: CreatePayWayPaymentLinkRequestDto(
        title: title,
        amount: amount,
        currency: currency,
        description: description,
        paymentLimit: paymentLimit,
        expiredDate: expiredDate,
        merchantRefNo: merchantRefNo,
      ),
    );

    return mapper.toPaymentLinkDomain(dto);
  }

  @override
  Future<void> simulateCallback({
    required String userId,
    required String tranId,
    required String merchantRefNo,
    required int status,
    String? apv,
  }) async {
    await remoteDataSource.simulateCallback(
      userId: userId,
      payload: PayWayCallbackPayloadDto(
        tranId: tranId,
        status: status,
        merchantRefNo: merchantRefNo,
        apv: apv,
      ),
    );
  }

  @override
  Future<List<PayWayCallbackLog>> getCallbackLogs(String userId) async {
    final dtos = await remoteDataSource.getCallbackLogs(userId);
    return dtos.map(mapper.toCallbackLogDomain).toList();
  }

  @override
  Future<List<FinancialEvent>> pollPayWay({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
    required String timezone,
  }) async {
    final dtos = await remoteDataSource.pollPayWay(
      userId: userId,
      fromDate: fromDate,
      toDate: toDate,
      timezone: timezone,
    );
    return dtos.map(mapper.toEventDomain).toList();
  }
}
