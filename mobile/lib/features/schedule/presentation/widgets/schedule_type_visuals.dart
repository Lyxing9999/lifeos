import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../domain/enum/schedule_block_type.dart';

class ScheduleTypeVisuals {
  ScheduleTypeVisuals._();

  static Color colorOf(ScheduleBlockType type) {
    switch (type) {
      case ScheduleBlockType.work:
        return AppColors.blue;
      case ScheduleBlockType.study:
        return AppColors.violet;
      case ScheduleBlockType.meeting:
        return AppColors.indigo;
      case ScheduleBlockType.exercise:
        return AppColors.green;
      case ScheduleBlockType.rest:
        return AppColors.teal;
      case ScheduleBlockType.commute:
        return AppColors.amber;
      case ScheduleBlockType.personal:
        return AppColors.sky;
      case ScheduleBlockType.other:
        return AppColors.slate;
    }
  }

  static IconData iconOf(ScheduleBlockType type) {
    switch (type) {
      case ScheduleBlockType.work:
        return AppIcons.work;
      case ScheduleBlockType.study:
        return AppIcons.study;
      case ScheduleBlockType.meeting:
        return AppIcons.meeting;
      case ScheduleBlockType.exercise:
        return AppIcons.exercise;
      case ScheduleBlockType.rest:
        return AppIcons.rest;
      case ScheduleBlockType.commute:
        return AppIcons.commute;
      case ScheduleBlockType.personal:
        return AppIcons.personal;
      case ScheduleBlockType.other:
        return AppIcons.schedule;
    }
  }
}
