import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_form_section.dart';
import '../../../content/task_copy.dart';

class TaskProgressSection extends StatelessWidget {
  final int progressPercent;
  final ValueChanged<int> onChanged;

  const TaskProgressSection({
    super.key,
    required this.progressPercent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: TaskCopy.formSectionProgress,
      subtitle: TaskCopy.formProgressSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  TaskCopy.formProgressCurrent,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text(
                '$progressPercent%',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Slider(
            value: progressPercent.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: '$progressPercent%',
            onChanged: (value) => onChanged(value.round()),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            TaskCopy.progressHint(progressPercent),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
