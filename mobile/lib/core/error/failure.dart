import 'app_exception.dart';

class Failure {
  final String message;
  final String? code;
  final int? statusCode;

  const Failure({required this.message, this.code, this.statusCode});

  factory Failure.fromException(AppException exception) {
    return Failure(
      message: exception.message,
      code: exception.code,
      statusCode: exception.statusCode,
    );
  }
}
