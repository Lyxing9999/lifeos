class CreatePayWayPaymentLinkRequestDto {
  final String title;
  final String amount;
  final String currency;
  final String? description;
  final String? paymentLimit;
  final String? expiredDate;
  final String? merchantRefNo;

  const CreatePayWayPaymentLinkRequestDto({
    required this.title,
    required this.amount,
    required this.currency,
    required this.description,
    required this.paymentLimit,
    required this.expiredDate,
    required this.merchantRefNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'currency': currency,
      'description': description,
      'paymentLimit': paymentLimit,
      'expiredDate': expiredDate,
      'merchantRefNo': merchantRefNo,
    };
  }
}
