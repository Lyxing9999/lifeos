class TimelineFinancialEventResponseDto {
  final String? id;
  final double? amount;
  final String? currency;
  final String? merchantName;
  final String? financialEventType;
  final String? category;
  final String? paidAt;

  const TimelineFinancialEventResponseDto({
    required this.id,
    required this.amount,
    required this.currency,
    required this.merchantName,
    required this.financialEventType,
    required this.category,
    required this.paidAt,
  });

  factory TimelineFinancialEventResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return TimelineFinancialEventResponseDto(
      id: json['id'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      merchantName: json['merchantName'] as String?,
      financialEventType: json['financialEventType'] as String?,
      category: json['category'] as String?,
      paidAt: json['paidAt'] as String?,
    );
  }
}
