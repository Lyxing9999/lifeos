import '../../domain/model/today_overview.dart';
import '../../domain/repository/today_repository.dart';
import '../datasource/today_remote_datasource.dart';
import '../mapper/today_mapper.dart';

class TodayRepositoryImpl implements TodayRepository {
  final TodayRemoteDataSource remoteDataSource;
  final TodayMapper mapper;

  const TodayRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<TodayOverview> getToday({
    required String userId,
    required DateTime date,
  }) async {
    final dto = await remoteDataSource.getToday(userId: userId, date: date);

    return mapper.toDomain(dto);
  }
}
