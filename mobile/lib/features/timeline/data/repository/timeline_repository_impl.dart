import '../../domain/model/timeline_day.dart';
import '../../domain/repository/timeline_repository.dart';
import '../datasource/timeline_remote_datasource.dart';
import '../mapper/timeline_mapper.dart';

class TimelineRepositoryImpl implements TimelineRepository {
  final TimelineRemoteDataSource remoteDataSource;
  final TimelineMapper mapper;

  const TimelineRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<TimelineDay> getDay({
    required String userId,
    required DateTime date,
  }) async {
    final dto = await remoteDataSource.getDay(userId: userId, date: date);

    return mapper.toDayDomain(dto);
  }
}
