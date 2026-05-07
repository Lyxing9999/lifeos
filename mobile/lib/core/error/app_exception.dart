class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.statusCode,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final parts = <String>['AppException: $message'];
    if (code != null && code!.isNotEmpty) {
      parts.add('code=$code');
    }
    if (statusCode != null) {
      parts.add('statusCode=$statusCode');
    }
    return parts.join(' ');
  }
}
