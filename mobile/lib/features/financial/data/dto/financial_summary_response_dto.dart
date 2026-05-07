class FinancialSummaryResponseDto {
  final int? totalEvents;
  final double? totalOutgoingAmount;
  final String? latestMerchantName;
  final double? latestAmount;
  final String? latestCurrency;
  final String? summaryText;

  const FinancialSummaryResponseDto({
    required this.totalEvents,
    required this.totalOutgoingAmount,
    required this.latestMerchantName,
    required this.latestAmount,
    required this.latestCurrency,
    required this.summaryText,
  });

  factory FinancialSummaryResponseDto.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryResponseDto(
      totalEvents: (json['totalEvents'] as num?)?.toInt(),
      totalOutgoingAmount: (json['totalOutgoingAmount'] as num?)?.toDouble(),
      latestMerchantName: json['latestMerchantName'] as String?,
      latestAmount: (json['latestAmount'] as num?)?.toDouble(),
      latestCurrency: json['latestCurrency'] as String?,
      summaryText: json['summaryText'] as String?,
    );
  }
}
