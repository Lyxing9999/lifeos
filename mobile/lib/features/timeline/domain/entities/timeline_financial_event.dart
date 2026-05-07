class TimelineFinancialEvent {
  final String id;
  final double amount;
  final String currency;
  final String merchantName;
  final String financialEventType;
  final String category;
  final DateTime? paidAt;

  const TimelineFinancialEvent({
    required this.id,
    required this.amount,
    required this.currency,
    required this.merchantName,
    required this.financialEventType,
    required this.category,
    required this.paidAt,
  });
}
