import 'package:flutter/material.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_stat_block.dart';
import '../../../domain/entities/task_overview.dart';
import '../../style/task_style.dart';

class TaskOverviewCard extends StatelessWidget {
  final TaskOverview overview;
  final VoidCallback onTapInbox;

  const TaskOverviewCard({
    super.key,
    required this.overview,
    required this.onTapInbox,
  });

  @override
  Widget build(BuildContext context) {
    final todayCounts = overview.todayCounts;
    final currentTask = overview.currentTask;

    // Backend still calls this anytimeCounts in the current frontend entity.
    // Product label is Inbox.
    final inboxCounts = overview.anytimeCounts;

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today at a glance', style: AppTextStyles.cardTitle(context)),
            if (currentTask != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Current focus: ${currentTask.title}',
                style: AppTextStyles.bodySecondary(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppStatBlock(
                    label: 'Active today',
                    value: '${todayCounts.active}',
                    color: TaskStyle.activeColor(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatBlock(
                    label: 'Done today',
                    value: '${todayCounts.completed}',
                    color: TaskStyle.completedColor(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppStatBlock(
                    label: 'Urgent',
                    value: '${todayCounts.urgent}',
                    color: TaskStyle.urgentColor(),
                  ),
                ),
              ],
            ),
            if (inboxCounts.total > 0) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                onTap: onTapInbox,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.inbox,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${inboxCounts.total} inbox task${inboxCounts.total == 1 ? '' : 's'} waiting to be planned',
                          style: AppTextStyles.bodySecondary(context),
                        ),
                      ),
                      Icon(
                        AppIcons.chevronRight,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
