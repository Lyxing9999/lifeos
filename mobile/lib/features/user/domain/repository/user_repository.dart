import '../model/user.dart';

abstract class UserRepository {
  Future<AppUser> getProfile();

  Future<AppUser> updateProfile({
    required String name,
    required String timezone,
    required String locale,
  });
}
