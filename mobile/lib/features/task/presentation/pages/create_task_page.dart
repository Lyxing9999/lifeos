import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/task_providers.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../content/task_copy.dart';
import '../../domain/command/create_task_command.dart';
import '../../domain/enum/task_recurrence_type.dart';
import 'task_form_page.dart';

class CreateTaskPage extends ConsumerWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaving = ref.watch(taskNotifierProvider).isSaving;

    return TaskFormPage(
      isSaving: isSaving,
      shouldPopOnSubmit: false,
      onSubmit: (result, feedbackContext) async {
        final isRecurring = result.recurrenceType.isRecurring;

        final command = CreateTaskCommand(
          title: result.title,
          description: result.description,
          category: result.category,
          taskMode: result.taskMode,
          priority: result.priority,
          dueDate: isRecurring ? null : result.dueDate,
          dueDateTime: isRecurring ? null : result.dueDateTime,
          progressPercent: result.progressPercent,
          recurrenceType: isRecurring
              ? result.recurrenceType
              : TaskRecurrenceType.none,
          recurrenceStartDate: isRecurring ? result.recurrenceStartDate : null,
          recurrenceEndDate: isRecurring ? result.recurrenceEndDate : null,
          recurrenceDaysOfWeek: isRecurring
              ? result.recurrenceDaysOfWeek
              : const [],
          linkedScheduleBlockId: result.clearLinkedScheduleBlock
              ? null
              : result.linkedScheduleBlockId,
          tags: result.tags,
        );

        await ref
            .read(taskMutationCoordinatorProvider)
            .createTask(command: command);

        final latest = ref.read(taskNotifierProvider);
        if (!context.mounted || !feedbackContext.mounted) return;

        if (latest.errorMessage != null) {
          AppFeedback.error(feedbackContext, message: latest.errorMessage!);
          return;
        }

        Navigator.of(feedbackContext).pop(TaskCopy.successCreated);
      },
    );
  }
}
