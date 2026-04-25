import '../../domain/model/daily_score.dart';
import '../../domain/repository/score_repository.dart';
import '../datasource/score_remote_datasource.dart';
import '../mapper/score_mapper.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final ScoreRemoteDataSource remoteDataSource;
  final ScoreMapper mapper;

  const ScoreRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<DailyScore> getDailyScore({
    required String userId,
    required DateTime date,
  }) async {
    final dto = await remoteDataSource.getDailyScore(
      userId: userId,
      date: date,
    );
    return mapper.toDomain(dto);
  }

  @override
  Future<DailyScore> generateDailyScore({
    required String userId,
    required DateTime date,
  }) async {
    final dto = await remoteDataSource.generateDailyScore(
      userId: userId,
      date: date,
    );
    return mapper.toDomain(dto);
  }

  @override
  Future<void> deleteDailyScore({
    required String userId,
    required DateTime date,
  }) async {
    await remoteDataSource.deleteDailyScore(userId: userId, date: date);
  }
}
