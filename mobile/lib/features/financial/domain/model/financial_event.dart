class FinancialEvent {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String merchantName;
  final String? normalizedMerchantName;
  final double? merchantConfidence;
  final String financialEventType;
  final String category;
  final DateTime? paidAt;
  final DateTime? eventDateLocal;
  final String timezone;
  final String status;
  final String sourceProvider;
  final String? providerEventId;
  final String? sourceAccountIdMasked;
  final String? rawReference;
  final String? description;
  final String? locationText;
  final String? countryCode;
  final bool isReadOnly;
  final String? consentId;

  const FinancialEvent({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.merchantName,
    required this.normalizedMerchantName,
    required this.merchantConfidence,
    required this.financialEventType,
    required this.category,
    required this.paidAt,
    required this.eventDateLocal,
    required this.timezone,
    required this.status,
    required this.sourceProvider,
    required this.providerEventId,
    required this.sourceAccountIdMasked,
    required this.rawReference,
    required this.description,
    required this.locationText,
    required this.countryCode,
    required this.isReadOnly,
    required this.consentId,
  });

  String get displayMerchantName {
    final value = merchantName.trim();
    if (value.isNotEmpty) return value;

    final fallback = normalizedMerchantName?.trim() ?? '';
    return fallback.isNotEmpty ? fallback : 'Unknown merchant';
  }

  bool get isOutgoingType {
    switch (financialEventType.toUpperCase()) {
      case 'PURCHASE':
      case 'CASH_OUT':
      case 'FEE':
        return true;
      default:
        return false;
    }
  }
}
