import 'package:flutter/material.dart';

import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';

class TaskDetailNotesSection extends StatelessWidget {
  final String description;

  const TaskDetailNotesSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: AppTextStyles.bodyPrimary(context)),
          ],
        ),
      ),
    );
  }
}
