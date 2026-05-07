import 'package:dio/dio.dart';

import '../error/error_mapper.dart';
import 'api_exception.dart';
import 'api_response.dart';

class ApiClient {
  final Dio _dio;

  const ApiClient(this._dio);

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic rawData) parser,
    Options? options,
  }) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      options: options,
      parser: parser,
    );
  }

  Future<T?> getNullable<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T? Function(dynamic rawData) parser,
    Options? options,
  }) {
    return _request<T?>(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      options: options,
      parser: parser,
    );
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic rawData) parser,
    Options? options,
  }) {
    return _request(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      parser: parser,
    );
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic rawData) parser,
    Options? options,
  }) {
    return _request(
      method: 'PUT',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      parser: parser,
    );
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic rawData) parser,
    Options? options,
  }) {
    return _request(
      method: 'PATCH',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      parser: parser,
    );
  }

  Future<void> deleteVoid(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _request<Object?>(
      method: 'DELETE',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      parser: (_) => null,
    );
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic rawData) parser,
    Options? options,
  }) {
    return _request(
      method: 'DELETE',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      parser: parser,
    );
  }

  Future<T> _request<T>({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(dynamic rawData) parser,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(method: method),
      );

      final body = response.data;
      if (body is! JsonMap) {
        throw ApiException.invalidResponse(
          'Invalid API response envelope',
          statusCode: response.statusCode,
        );
      }

      final envelope = ApiResponse<T>.fromJson(body, parser);
      if (!envelope.success) {
        throw ApiException.server(
          envelope.message,
          statusCode: response.statusCode,
        );
      }

      final parsedData = envelope.data;
      if (parsedData == null) {
        if (null is T) {
          return null as T;
        }

        throw ApiException.invalidResponse(
          'Missing response data for $path',
          statusCode: response.statusCode,
        );
      }

      return parsedData;
    } on DioException catch (error, stackTrace) {
      throw ErrorMapper.fromDio(error, stackTrace);
    } on ApiException {
      rethrow;
    } catch (error, stackTrace) {
      throw ErrorMapper.fromObject(error, stackTrace);
    }
  }
}
