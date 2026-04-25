class PayWayCallbackLog {
  final String id;
  final String userId;
  final String transactionId;
  final String merchantRefNo;
  final String rawPayloadJson;
  final bool processed;
  final String? processingError;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PayWayCallbackLog({
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
}
