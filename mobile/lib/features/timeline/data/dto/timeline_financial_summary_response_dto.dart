class TimelineFinancialSummaryResponseDto {
  final int? totalFinancialEvents;
  final double? totalOutgoingAmount;

  const TimelineFinancialSummaryResponseDto({
    required this.totalFinancialEvents,
    required this.totalOutgoingAmount,
  });

  factory TimelineFinancialSummaryResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return TimelineFinancialSummaryResponseDto(
      totalFinancialEvents: (json['totalFinancialEvents'] as num?)?.toInt(),
      totalOutgoingAmount: (json['totalOutgoingAmount'] as num?)?.toDouble(),
    );
  }
}
