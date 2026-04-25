import '../model/stay_session.dart';

abstract class StaySessionRepository {
  Future<List<StaySession>> getByUserAndDay({
    required String userId,
    required DateTime date,
  });

  Future<String> rebuild({required String userId, required DateTime date});

  Future<void> deleteByUserAndDay({
    required String userId,
    required DateTime date,
  });
}
