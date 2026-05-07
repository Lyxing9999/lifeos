class PayWayCallbackLogResponseDto {
  final String? id;
  final String? userId;
  final String? transactionId;
  final String? merchantRefNo;
  final String? rawPayloadJson;
  final bool? processed;
  final String? processingError;
  final String? createdAt;
  final String? updatedAt;

  const PayWayCallbackLogResponseDto({
    required this.id,
    required this.userId,
    required this.transactionId,
    required this.merchantRefNo,
    required this.rawPayloadJson,
    required this.processed,
    required this.processingError,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PayWayCallbackLogResponseDto.fromJson(Map<String, dynamic> json) {
    return PayWayCallbackLogResponseDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      transactionId: json['transactionId'] as String?,
      merchantRefNo: json['merchantRefNo'] as String?,
      rawPayloadJson: json['rawPayloadJson'] as String?,
      processed: json['processed'] as bool?,
      processingError: json['processingError'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
