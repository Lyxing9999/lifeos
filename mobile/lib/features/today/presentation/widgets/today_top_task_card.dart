import 'package:flutter/material.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_priority.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../task/domain/model/task.dart';

class TodayTopTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TodayTopTaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = task.progressPercent.clamp(0, 100);
    final color = task.taskMode.name == 'progress'
        ? AppColors.blue
        : AppColors.green;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.cardInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Task in focus',
                    style: AppTextStyles.sectionHeader(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                task.title,
                style: AppTextStyles.cardTitle(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if ((task.category ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  task.category!,
                  style: AppTextStyles.bodySecondary(context),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (task.taskMode.name == 'progress')
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 6,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '$progress%',
                      style: AppTextStyles.statLabel(
                        context,
                      ).copyWith(color: color, fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              else
                Text(
                  task.priority.label,
                  style: AppTextStyles.metaLabel(
                    context,
                  ).copyWith(color: color),
                ),
              if (onTap != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Open task',
                  style: AppTextStyles.metaLabel(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
