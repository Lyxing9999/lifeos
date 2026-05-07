import '../../domain/model/location_log.dart';
import '../../domain/repository/location_repository.dart';
import '../datasource/location_remote_datasource.dart';
import '../dto/create_location_log_batch_request_dto.dart';
import '../mapper/location_mapper.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final LocationMapper mapper;

  const LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  @override
  Future<List<LocationLog>> getByUserAndDay({
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
  Future<LocationBatchIngestResult> createBatch({
    required String userId,
    required List<LocationLogCreateInput> logs,
  }) async {
    final dto = CreateLocationLogBatchRequestDto(
      userId: userId,
      points: logs
          .map(
            (e) => CreateLocationLogPointDto(
              latitude: e.latitude,
              longitude: e.longitude,
              accuracyMeters: e.accuracyMeters,
              speedMetersPerSecond: e.speedMetersPerSecond,
              recordedAt: e.recordedAt.toUtc().toIso8601String(),
              source: e.source,
            ),
          )
          .toList(),
    );

    final response = await remoteDataSource.createBatch(dto);
    return LocationBatchIngestResult(
      requestedPoints: response.requestedPoints ?? logs.length,
      acceptedPoints: response.acceptedPoints ?? 0,
      rejectedPoints: response.rejectedPoints ?? 0,
      message: response.message,
    );
  }
}
