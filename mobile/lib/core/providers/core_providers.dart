import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../storage/shared_prefs_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const SecureStorageService(FlutterSecureStorage());
});
