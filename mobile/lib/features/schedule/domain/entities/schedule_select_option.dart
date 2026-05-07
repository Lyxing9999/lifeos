import 'package:flutter/material.dart';

import '../enum/schedule_block_type.dart';

class ScheduleSelectOption {
  final String value;
  final String scheduleBlockId;
  final String label;
  final String title;
  final ScheduleBlockType type;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool active;

  const ScheduleSelectOption({
    required this.value,
    required this.scheduleBlockId,
    required this.label,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.active,
  });
}
