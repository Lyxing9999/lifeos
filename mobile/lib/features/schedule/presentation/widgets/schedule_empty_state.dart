import 'package:flutter/material.dart';

import '../../content/schedule_copy.dart';
import '../../../../core/widgets/app_empty_view.dart';

class ScheduleEmptyState extends StatelessWidget {
  final VoidCallback? onCreateSchedule;

  const ScheduleEmptyState({super.key, this.onCreateSchedule});

  @override
  Widget build(BuildContext context) {
    return AppEmptyView(
      icon: Icons.calendar_month_outlined,
      title: ScheduleCopy.emptyTitle,
      subtitle: ScheduleCopy.emptySubtitle,
      actionLabel: onCreateSchedule == null ? null : ScheduleCopy.createBlock,
      actionIcon: Icons.add,
      onAction: onCreateSchedule,
    );
  }
}
