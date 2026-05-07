import '../../domain/model/user.dart';
import '../../domain/repository/user_repository.dart';
import '../datasource/user_remote_datasource.dart';
import '../dto/update_user_request_dto.dart';
import '../mapper/user_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserMapper mapper;

  const UserRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<AppUser> getProfile() async {
    final dto = await remoteDataSource.getProfile();
    return mapper.toDomain(dto);
  }

  @override
  Future<AppUser> updateProfile({
    required String name,
    required String timezone,
    required String locale,
  }) async {
    final dto = await remoteDataSource.updateProfile(
      UpdateUserRequestDto(name: name, timezone: timezone, locale: locale),
    );

    return mapper.toDomain(dto);
  }
}
