import '../../domain/model/stay_session.dart';
import '../../domain/repository/stay_session_repository.dart';
import '../datasource/stay_session_remote_datasource.dart';
import '../mapper/stay_session_mapper.dart';

class StaySessionRepositoryImpl implements StaySessionRepository {
  final StaySessionRemoteDataSource remoteDataSource;
  final StaySessionMapper mapper;

  const StaySessionRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<List<StaySession>> getByUserAndDay({
    required String userId,
    required DateTime date,
  }) async {
    final dtos = await remoteDataSource.getByUserAndDay(
      userId: userId,
      date: date,
    );

    return dtos.map(mapper.toDomain).toList();
  }

  @override
  Future<String> rebuild({
    required String userId,
    required DateTime date,
  }) async {
    return remoteDataSource.rebuild(userId: userId, date: date);
  }

  @override
  Future<void> deleteByUserAndDay({
    required String userId,
    required DateTime date,
  }) async {
    await remoteDataSource.deleteByUserAndDay(userId: userId, date: date);
  }
}
