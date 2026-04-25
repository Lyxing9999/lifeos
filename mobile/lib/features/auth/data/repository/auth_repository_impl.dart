import '../../../../app/constants/storage_keys.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/model/auth_session.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final LocalStorageService localStorageService;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorageService,
  });

  @override
  Future<AuthSession> bootstrapSession() async {
    final savedUserId = localStorageService.getString(
      StorageKeys.currentUserId,
    );

    if (savedUserId != null && savedUserId.isNotEmpty) {
      return AuthSession(userId: savedUserId);
    }

    final demoUser = await remoteDataSource.createDemoUser();
    final userId = demoUser.id ?? '';

    if (userId.isEmpty) {
      throw Exception('Failed to bootstrap session: empty user id');
    }

    await localStorageService.setString(StorageKeys.currentUserId, userId);

    return AuthSession(userId: userId);
  }

  @override
  Future<void> clearSession() async {
    await localStorageService.remove(StorageKeys.currentUserId);
  }
}
