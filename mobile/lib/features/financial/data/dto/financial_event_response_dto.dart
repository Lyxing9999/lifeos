class FinancialEventResponseDto {
  final String? id;
  final String? userId;
  final double? amount;
  final String? currency;
  final String? merchantName;
  final String? normalizedMerchantName;
  final double? merchantConfidence;
  final String? financialEventType;
  final String? category;
  final String? paidAt;
  final String? eventDateLocal;
  final String? timezone;
  final String? status;
  final String? sourceProvider;
  final String? providerEventId;
  final String? sourceAccountIdMasked;
  final String? rawReference;
  final String? description;
  final String? locationText;
  final String? countryCode;
  final bool? isReadOnly;
  final String? consentId;

  const FinancialEventResponseDto({
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

  factory FinancialEventResponseDto.fromJson(Map<String, dynamic> json) {
    return FinancialEventResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      merchantName: json['merchantName'] as String?,
      normalizedMerchantName: json['normalizedMerchantName'] as String?,
      merchantConfidence: (json['merchantConfidence'] as num?)?.toDouble(),
      financialEventType: json['financialEventType'] as String?,
      category: json['category'] as String?,
      paidAt: json['paidAt'] as String?,
      eventDateLocal: json['eventDateLocal'] as String?,
      timezone: json['timezone'] as String?,
      status: json['status'] as String?,
      sourceProvider: json['sourceProvider'] as String?,
      providerEventId: json['providerEventId'] as String?,
      sourceAccountIdMasked: json['sourceAccountIdMasked'] as String?,
      rawReference: json['rawReference'] as String?,
      description: json['description'] as String?,
      locationText: json['locationText'] as String?,
      countryCode: json['countryCode'] as String?,
      isReadOnly: json['isReadOnly'] as bool?,
      consentId: json['consentId'] as String?,
    );
  }
}
