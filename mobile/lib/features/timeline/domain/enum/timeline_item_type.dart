enum TimelineItemType {
  task,
  schedule,
  stay,
  // financial, // TODO: Uncomment when finance is ready
  unknown;

  static TimelineItemType fromApi(String? value) {
    if (value == null) return TimelineItemType.unknown;
    return TimelineItemType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => TimelineItemType.unknown,
    );
  }
}
