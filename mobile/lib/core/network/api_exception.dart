import '../error/app_exception.dart';

class ApiException extends AppException {
  const ApiException(
    super.message, {
    super.code,
    super.statusCode,
    super.cause,
    super.stackTrace,
  });

  const ApiException.invalidResponse(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  }) : super(code: 'invalid_response');

  const ApiException.network(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  }) : super(code: 'network_error');

  const ApiException.timeout(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  }) : super(code: 'timeout');

  const ApiException.unauthorized(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  }) : super(code: 'unauthorized');

  const ApiException.server(
    super.message, {
    super.statusCode,
    super.cause,
    super.stackTrace,
  }) : super(code: 'server_error');
}
