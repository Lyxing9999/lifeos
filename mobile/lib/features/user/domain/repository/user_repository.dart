import '../model/user.dart';

abstract class UserRepository {
  Future<List<AppUser>> getAll();

  Future<AppUser> getById(String userId);

  Future<AppUser> getProfile(String userId);

  Future<AppUser> updateProfile({
    required String userId,
    required String name,
    required String timezone,
    required String locale,
  });
}
