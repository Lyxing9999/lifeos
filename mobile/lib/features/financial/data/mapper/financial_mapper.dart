import '../../domain/model/financial_event.dart';
import '../../domain/model/financial_summary.dart';
import '../../domain/model/payway_callback_log.dart';
import '../../domain/model/payway_payment_link.dart';
import '../dto/financial_event_response_dto.dart';
import '../dto/financial_summary_response_dto.dart';
import '../dto/payway_callback_log_response_dto.dart';
import '../dto/payway_create_payment_link_response_dto.dart';

class FinancialMapper {
  const FinancialMapper();

  FinancialEvent toEventDomain(FinancialEventResponseDto dto) {
    return FinancialEvent(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      amount: dto.amount ?? 0,
      currency: dto.currency ?? '',
      merchantName: dto.merchantName ?? '',
      normalizedMerchantName: dto.normalizedMerchantName,
      merchantConfidence: dto.merchantConfidence,
      financialEventType: dto.financialEventType ?? '',
      category: dto.category ?? '',
      paidAt: _parseDateTime(dto.paidAt),
      eventDateLocal: _parseDateTime(dto.eventDateLocal),
      timezone: dto.timezone ?? '',
      status: dto.status ?? '',
      sourceProvider: dto.sourceProvider ?? '',
      providerEventId: dto.providerEventId,
      sourceAccountIdMasked: dto.sourceAccountIdMasked,
      rawReference: dto.rawReference,
      description: dto.description,
      locationText: dto.locationText,
      countryCode: dto.countryCode,
      isReadOnly: dto.isReadOnly ?? true,
      consentId: dto.consentId,
    );
  }

  FinancialSummary toSummaryDomain(FinancialSummaryResponseDto dto) {
    return FinancialSummary(
      totalEvents: dto.totalEvents ?? 0,
      totalOutgoingAmount: dto.totalOutgoingAmount ?? 0,
      latestMerchantName: dto.latestMerchantName ?? '',
      latestAmount: dto.latestAmount,
      latestCurrency: dto.latestCurrency ?? '',
      summaryText: dto.summaryText ?? '',
    );
  }

  PayWayCallbackLog toCallbackLogDomain(PayWayCallbackLogResponseDto dto) {
    return PayWayCallbackLog(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      transactionId: dto.transactionId ?? '',
      merchantRefNo: dto.merchantRefNo ?? '',
      rawPayloadJson: dto.rawPayloadJson ?? '',
      processed: dto.processed ?? false,
      processingError: dto.processingError,
      createdAt: _parseDateTime(dto.createdAt),
      updatedAt: _parseDateTime(dto.updatedAt),
    );
  }

  PayWayPaymentLink toPaymentLinkDomain(
    PayWayCreatePaymentLinkResponseDto dto,
  ) {
    final data = dto.data;
    final status = dto.status;

    return PayWayPaymentLink(
      tranId: dto.tranId ?? '',
      id: data?.id,
      title: data?.title ?? '',
      amount: double.tryParse(data?.amount ?? ''),
      currency: data?.currency ?? '',
      description: data?.description,
      paymentLimit: data?.paymentLimit,
      expiredDate: _parseEpochDateTime(data?.expiredDate),
      returnUrl: data?.returnUrl,
      merchantRefNo: data?.merchantRefNo ?? '',
      paymentLink: data?.paymentLink ?? '',
      outletName: data?.outletName,
      paymentStatus: data?.status,
      statusCode: status?.code,
      statusMessage: status?.message,
    );
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  DateTime? _parseEpochDateTime(int? value) {
    if (value == null || value <= 0) return null;
    final milliseconds = value > 9999999999 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}
