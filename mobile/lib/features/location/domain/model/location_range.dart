import 'location_log.dart';

class LocationRange {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalLogs;
  final List<LocationLog> logs;

  const LocationRange({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalLogs,
    required this.logs,
  });
}
