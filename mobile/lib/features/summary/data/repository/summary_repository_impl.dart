import '../../domain/model/daily_summary.dart';
import '../../domain/repository/summary_repository.dart';
import '../datasource/summary_remote_datasource.dart';
import '../mapper/summary_mapper.dart';

class SummaryRepositoryImpl implements SummaryRepository {
  final SummaryRemoteDataSource remoteDataSource;
  final SummaryMapper mapper;

  const SummaryRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<DailySummary> getDailySummary({
    required String userId,
    required DateTime date,
  }) async {
    final dto = await remoteDataSource.getDailySummary(
      userId: userId,
      date: date,
    );
    return mapper.toDomain(dto);
  }

  @override
  Future<DailySummary> generateDailySummary({
    required String userId,
    required DateTime date,
  }) async {
    final dto = await remoteDataSource.generateDailySummary(
      userId: userId,
      date: date,
    );
    return mapper.toDomain(dto);
  }

  @override
  Future<void> deleteDailySummary({
    required String userId,
    required DateTime date,
  }) async {
    await remoteDataSource.deleteDailySummary(userId: userId, date: date);
  }
}
