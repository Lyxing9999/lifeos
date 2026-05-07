import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/env.dart';
import '../../app/constants/storage_keys.dart';
import '../providers/core_providers.dart';
import 'api_client.dart';
import 'network_logger.dart';

final dioProvider = Provider<Dio>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final secureToken = await secureStorage.read(StorageKeys.authToken);
        final token = secureToken?.trim().isNotEmpty == true
            ? secureToken
            : localStorage.getString(StorageKeys.authToken);
        if (token != null &&
            token.isNotEmpty &&
            !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          await secureStorage.delete(StorageKeys.authToken);
          await localStorage.remove(StorageKeys.authToken);
        }
        handler.next(error);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(NetworkLogger());
  }

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
