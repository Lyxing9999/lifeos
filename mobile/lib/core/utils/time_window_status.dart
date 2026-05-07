enum TimeWindowStatus { upcoming, now, ended }

TimeWindowStatus timeWindowStatus({
  required DateTime start,
  required DateTime end,
  required DateTime now,
}) {
  final startUtc = start.toUtc();
  final endUtc = end.toUtc();
  final nowUtc = now.toUtc();

  if (!endUtc.isAfter(startUtc)) {
    return nowUtc.isBefore(startUtc)
        ? TimeWindowStatus.upcoming
        : TimeWindowStatus.ended;
  }

  if (nowUtc.isBefore(startUtc)) {
    return TimeWindowStatus.upcoming;
  }

  if (nowUtc.isBefore(endUtc)) {
    return TimeWindowStatus.now;
  }

  return TimeWindowStatus.ended;
}
