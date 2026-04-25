import '../model/financial_event.dart';
import '../model/financial_summary.dart';
import '../model/payway_callback_log.dart';
import '../model/payway_payment_link.dart';

abstract class FinancialRepository {
  Future<List<FinancialEvent>> getEventsByDay({
    required String userId,
    required DateTime date,
    required String timezone,
  });

  Future<List<FinancialEvent>> getEventsByRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String timezone,
  });

  Future<FinancialSummary> getDaySummary({
    required String userId,
    required DateTime date,
    required String timezone,
  });

  Future<void> deleteEvent(String id);

  Future<String> importCsv({
    required String userId,
    required String timezone,
    required List<int> bytes,
    required String fileName,
  });

  Future<PayWayPaymentLink> createPaymentLink({
    required String userId,
    required String title,
    required String amount,
    required String currency,
    String? description,
    String? paymentLimit,
    String? expiredDate,
    String? merchantRefNo,
  });

  Future<void> simulateCallback({
    required String userId,
    required String tranId,
    required String merchantRefNo,
    required int status,
    String? apv,
  });

  Future<List<PayWayCallbackLog>> getCallbackLogs(String userId);

  Future<List<FinancialEvent>> pollPayWay({
    required String userId,
    required DateTime fromDate,
    required DateTime toDate,
    required String timezone,
  });
}
