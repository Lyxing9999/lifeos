import 'package:flutter/material.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_chip.dart';
import '../../../domain/entities/task.dart';

class TaskDetailTagsSection extends StatelessWidget {
  final Task task;

  const TaskDetailTagsSection({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tags', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: task.tags.map((tag) {
                return AppChip.metadata(label: tag.name, icon: AppIcons.tags);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
