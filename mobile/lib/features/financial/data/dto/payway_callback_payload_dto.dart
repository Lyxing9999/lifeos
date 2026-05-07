class PayWayCallbackPayloadDto {
  final String tranId;
  final int status;
  final String merchantRefNo;
  final String? apv;

  const PayWayCallbackPayloadDto({
    required this.tranId,
    required this.status,
    required this.merchantRefNo,
    required this.apv,
  });

  Map<String, dynamic> toJson() {
    return {
      'tran_id': tranId,
      'status': status,
      'merchant_ref_no': merchantRefNo,
      'apv': apv,
    };
  }
}
