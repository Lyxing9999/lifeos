import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/enum/task_status.dart';

class TaskStatusChip extends StatelessWidget {
  final TaskStatus status;

  const TaskStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, status);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.34,
      ),
      child: AppChip.status(label: status.label, color: color),
    );
  }

  static Color _statusColor(BuildContext context, TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.slate;
      case TaskStatus.inProgress:
        return AppColors.blue;
      case TaskStatus.completed:
        return AppColors.green;
    }
  }
}
