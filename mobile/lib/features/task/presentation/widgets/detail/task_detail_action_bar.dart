import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/enum/task_status.dart';
import '../../../domain/helper/task_state_helper.dart';

class TaskDetailActionBar extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;
  final VoidCallback? onReopen;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onRestore;

  const TaskDetailActionBar({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onReopen,
    this.onPause,
    this.onResume,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Paused State
    if (task.paused && onResume != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: AppButton.primary(
            label: 'Resume task',
            icon: AppIcons.resume,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onResume!();
            },
            fullWidth: true,
          ),
        ),
      );
    }

    // 2. Archived State
    if (task.archived && onRestore != null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: AppButton.secondary(
            label: 'Restore to Inbox',
            icon: AppIcons.inbox,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onRestore!();
            },
            fullWidth: true,
          ),
        ),
      );
    }

    final canPause = onPause != null && TaskStateHelper.canPause(task);
    final isRecurring = task.recurrenceType.isRecurring;

    // 3. Active (TODO) State
    if (!task.status.isDone) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canPause) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: AppButton.secondary(
                  label: 'Pause task',
                  icon: AppIcons.paused,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onPause!();
                  },
                  fullWidth: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: AppButton.primary(
                label: isRecurring ? 'Complete for today' : 'Complete task',
                icon: AppIcons.complete,
                onPressed: onComplete == null
                    ? null
                    : () {
                        HapticFeedback.heavyImpact();
                        onComplete!();
                      },
                fullWidth: true,
              ),
            ),
          ],
        ),
      );
    }

    // 4. DONE State (Reopen / Undo)
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AppButton.secondary(
              label: isRecurring ? "Undo today's completion" : 'Reopen task',
              icon: AppIcons.reopen,
              onPressed: onReopen == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onReopen!();
                    },
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
