class TodayFinancialInsightResponseDto {
  final int? totalEvents;
  final double? totalOutgoingAmount;
  final String? latestMerchantName;
  final double? latestAmount;
  final String? latestCurrency;

  const TodayFinancialInsightResponseDto({
    required this.totalEvents,
    required this.totalOutgoingAmount,
    required this.latestMerchantName,
    required this.latestAmount,
    required this.latestCurrency,
  });

  factory TodayFinancialInsightResponseDto.fromJson(Map<String, dynamic> json) {
    return TodayFinancialInsightResponseDto(
      totalEvents: (json['totalEvents'] as num?)?.toInt(),
      totalOutgoingAmount: (json['totalOutgoingAmount'] as num?)?.toDouble(),
      latestMerchantName: json['latestMerchantName'] as String?,
      latestAmount: (json['latestAmount'] as num?)?.toDouble(),
      latestCurrency: json['latestCurrency'] as String?,
    );
  }
}
