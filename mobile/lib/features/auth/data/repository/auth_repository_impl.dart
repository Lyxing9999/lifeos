import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../app/constants/env.dart';
import '../../../../app/constants/storage_keys.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/model/auth_session.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageService localStorageService;
  final SecureStorageService secureStorageService;
  final GoogleSignIn googleSignIn;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorageService,
    required this.secureStorageService,
    GoogleSignIn? googleSignIn,
  }) : googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             scopes: const ['email', 'profile'],
             clientId: kIsWeb ? _normalizedGoogleClientId : null,
             serverClientId: kIsWeb ? null : _normalizedGoogleClientId,
           );

  @override
  Future<AuthSession?> bootstrapSession() async {
    final token = await _readStoredToken();

    if (token == null || token.isEmpty) {
      await localStorageService.remove(StorageKeys.currentUserId);
      return null;
    }

    if (!await _hasSecureToken()) {
      await secureStorageService.write(StorageKeys.authToken, token);
    }

    try {
      final me = await remoteDataSource.getCurrentUser();
      final userId = (me.id ?? '').trim();

      if (userId.isEmpty) {
        await clearSession();
        return null;
      }

      await localStorageService.setString(StorageKeys.currentUserId, userId);

      return AuthSession(
        accessToken: token,
        tokenType: 'Bearer',
        expiresInSeconds: null,
        userId: userId,
        email: me.email,
        name: me.name,
        pictureUrl: me.pictureUrl,
        timezone: me.timezone,
        locale: me.locale,
      );
    } on AppException catch (error) {
      if (error.code == 'unauthorized' || error.statusCode == 401) {
        await clearSession();
        return null;
      }

      rethrow;
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  @override
  Future<AuthSession> signInWithGoogle() async {
    if (_normalizedGoogleClientId == null) {
      throw Exception(
        'Missing GOOGLE_SERVER_CLIENT_ID in .env. Add your Google Web OAuth client ID.',
      );
    }

    final account = await googleSignIn.signIn();

    if (account == null) {
      throw Exception('Google sign-in was cancelled.');
    }

    final googleAuth = await account.authentication;

    final idToken = (googleAuth.idToken ?? '').trim();
    final googleAccessToken = (googleAuth.accessToken ?? '').trim();

    if (idToken.isEmpty) {
      if (kIsWeb) {
        throw Exception(
          'Google Web sign-in returned an access token but no ID token. '
          'This is a Flutter Web google_sign_in limitation in this flow. '
          'Test Google login on Android/iOS first, or implement Google Identity Services credential login for Web. '
          'accessToken exists: ${googleAccessToken.isNotEmpty}',
        );
      }

      throw Exception(
        'Google sign-in did not return an ID token. '
        'Check GOOGLE_SERVER_CLIENT_ID, Android OAuth SHA-1, and iOS bundle ID.',
      );
    }

    final auth = await remoteDataSource.loginWithGoogle(
      idToken: idToken,
      timezone: _timezoneForLogin(),
    );

    final accessToken = (auth.accessToken ?? '').trim();
    final user = auth.user;
    final userId = (user?.id ?? '').trim();

    if (accessToken.isEmpty || userId.isEmpty) {
      throw Exception('Invalid auth response from backend.');
    }

    await secureStorageService.write(StorageKeys.authToken, accessToken);
    await localStorageService.setString(StorageKeys.authToken, accessToken);
    await localStorageService.setString(StorageKeys.currentUserId, userId);

    return AuthSession(
      accessToken: accessToken,
      tokenType: auth.tokenType ?? 'Bearer',
      expiresInSeconds: auth.expiresInSeconds,
      userId: userId,
      email: user?.email,
      name: user?.name,
      pictureUrl: user?.pictureUrl,
      timezone: user?.timezone,
      locale: user?.locale,
    );
  }

  @override
  Future<void> clearSession() async {
    try {
      await googleSignIn.signOut();
    } catch (_) {
      // Ignore: there may be no native Google session to terminate.
    }

    await localStorageService.remove(StorageKeys.currentUserId);
    await secureStorageService.delete(StorageKeys.authToken);
    await localStorageService.remove(StorageKeys.authToken);
  }

  Future<String?> _readStoredToken() async {
    final secureToken = await secureStorageService.read(StorageKeys.authToken);
    final localToken = localStorageService.getString(StorageKeys.authToken);

    final token = (secureToken?.trim().isNotEmpty == true)
        ? secureToken!.trim()
        : (localToken ?? '').trim();

    return token.isEmpty ? null : token;
  }

  Future<bool> _hasSecureToken() async {
    final secureToken = await secureStorageService.read(StorageKeys.authToken);
    return secureToken?.trim().isNotEmpty == true;
  }

  String _timezoneForLogin() {
    final configuredTimezone = Env.appTimezone.trim();

    if (configuredTimezone.isNotEmpty) {
      return configuredTimezone;
    }

    final zone = DateTime.now().timeZoneName.trim();

    if (zone.isNotEmpty) {
      return zone;
    }

    return 'Asia/Phnom_Penh';
  }

  static String? get _normalizedGoogleClientId {
    final value = Env.googleServerClientId.trim();
    return value.isEmpty ? null : value;
  }
}