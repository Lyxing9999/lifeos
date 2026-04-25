class PayWayPaymentLink {
  final String tranId;
  final String? id;
  final String title;
  final double? amount;
  final String currency;
  final String? description;
  final int? paymentLimit;
  final DateTime? expiredDate;
  final String? returnUrl;
  final String merchantRefNo;
  final String paymentLink;
  final String? outletName;
  final String? paymentStatus;
  final String? statusCode;
  final String? statusMessage;

  const PayWayPaymentLink({
    required this.tranId,
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.description,
    required this.paymentLimit,
    required this.expiredDate,
    required this.returnUrl,
    required this.merchantRefNo,
    required this.paymentLink,
    required this.outletName,
    required this.paymentStatus,
    required this.statusCode,
    required this.statusMessage,
  });
}
