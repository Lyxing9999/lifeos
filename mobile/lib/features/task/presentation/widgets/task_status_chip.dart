import 'package:flutter/material.dart';

import '../../../../core/widgets/app_chip.dart';
import '../../domain/enum/task_status.dart';
import '../style/task_style.dart';

class TaskStatusChip extends StatelessWidget {
  final TaskStatus status;

  const TaskStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.34,
      ),
      child: AppChip.status(
        label: status.label,
        icon: TaskStyle.statusIcon(status),
        color: TaskStyle.statusColor(status),
      ),
    );
  }
}
