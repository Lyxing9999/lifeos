class FinancialSummary {
  final int totalEvents;
  final double totalOutgoingAmount;
  final String latestMerchantName;
  final double? latestAmount;
  final String latestCurrency;
  final String summaryText;

  const FinancialSummary({
    required this.totalEvents,
    required this.totalOutgoingAmount,
    required this.latestMerchantName,
    required this.latestAmount,
    required this.latestCurrency,
    required this.summaryText,
  });
}
