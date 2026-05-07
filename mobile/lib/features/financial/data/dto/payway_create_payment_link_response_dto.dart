class PayWayCreatePaymentLinkResponseDto {
  final PayWayLinkDataDto? data;
  final PayWayLinkStatusDto? status;
  final String? tranId;

  const PayWayCreatePaymentLinkResponseDto({
    required this.data,
    required this.status,
    required this.tranId,
  });

  factory PayWayCreatePaymentLinkResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    return PayWayCreatePaymentLinkResponseDto(
      data: json['data'] == null
          ? null
          : PayWayLinkDataDto.fromJson(json['data'] as Map<String, dynamic>),
      status: json['status'] == null
          ? null
          : PayWayLinkStatusDto.fromJson(
              json['status'] as Map<String, dynamic>,
            ),
      tranId: json['tran_id'] as String?,
    );
  }
}

class PayWayLinkDataDto {
  final String? id;
  final String? title;
  final String? amount;
  final String? currency;
  final String? status;
  final String? description;
  final int? paymentLimit;
  final int? expiredDate;
  final String? returnUrl;
  final String? merchantRefNo;
  final String? paymentLink;
  final String? outletName;

  const PayWayLinkDataDto({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    required this.paymentLimit,
    required this.expiredDate,
    required this.returnUrl,
    required this.merchantRefNo,
    required this.paymentLink,
    required this.outletName,
  });

  factory PayWayLinkDataDto.fromJson(Map<String, dynamic> json) {
    return PayWayLinkDataDto(
      id: json['id'] as String?,
      title: json['title'] as String?,
      amount: json['amount'] as String?,
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      paymentLimit: (json['payment_limit'] as num?)?.toInt(),
      expiredDate: (json['expired_date'] as num?)?.toInt(),
      returnUrl: json['return_url'] as String?,
      merchantRefNo: json['merchant_ref_no'] as String?,
      paymentLink: json['payment_link'] as String?,
      outletName: json['outlet_name'] as String?,
    );
  }
}

class PayWayLinkStatusDto {
  final String? code;
  final String? message;

  const PayWayLinkStatusDto({required this.code, required this.message});

  factory PayWayLinkStatusDto.fromJson(Map<String, dynamic> json) {
    return PayWayLinkStatusDto(
      code: json['code'] as String?,
      message: json['message'] as String?,
    );
  }
}
