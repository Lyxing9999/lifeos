import '../model/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> bootstrapSession();

  Future<AuthSession> signInWithGoogle();

  Future<void> clearSession();
}