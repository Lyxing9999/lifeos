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
  Future<List<AppUser>> getAll() async {
    final dtos = await remoteDataSource.getAll();
    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<AppUser> getById(String userId) async {
    final dto = await remoteDataSource.getById(userId);
    return mapper.toDomain(dto);
  }

  @override
  Future<AppUser> getProfile(String userId) async {
    final dto = await remoteDataSource.getProfile(userId);
    return mapper.toDomain(dto);
  }

  @override
  Future<AppUser> updateProfile({
    required String userId,
    required String name,
    required String timezone,
    required String locale,
  }) async {
    final dto = await remoteDataSource.updateProfile(
      userId: userId,
      request: UpdateUserRequestDto(
        name: name,
        timezone: timezone,
        locale: locale,
      ),
    );

    return mapper.toDomain(dto);
  }
}
