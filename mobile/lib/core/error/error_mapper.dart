import 'package:dio/dio.dart';

import '../network/api_exception.dart';
import 'app_exception.dart';

abstract final class ErrorMapper {
  static String message(Object error, [StackTrace? stackTrace]) {
    return fromObject(error, stackTrace).message;
  }

  static AppException fromObject(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    if (error is DioException) {
      return fromDio(error, stackTrace);
    }

    return AppException(
      error.toString(),
      code: 'unknown_error',
      cause: error,
      stackTrace: stackTrace,
    );
  }

  static ApiException fromDio(DioException error, [StackTrace? stackTrace]) {
    final message = error.message ?? 'Network request failed';
    final statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeout(
          'Request timed out',
          statusCode: statusCode,
          cause: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.badResponse:
        if (statusCode == 401 || statusCode == 403) {
          return ApiException.unauthorized(
            _messageFromResponse(error) ?? 'Unauthorized request',
            statusCode: statusCode,
            cause: error,
            stackTrace: stackTrace,
          );
        }

        return ApiException.server(
          _messageFromResponse(error) ?? message,
          statusCode: statusCode,
          cause: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.cancel:
        return ApiException.network(
          'Request was cancelled',
          statusCode: statusCode,
          cause: error,
          stackTrace: stackTrace,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException.network(
          _messageFromResponse(error) ?? message,
          statusCode: statusCode,
          cause: error,
          stackTrace: stackTrace,
        );
    }
  }

  static String? _messageFromResponse(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}
