import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';

import '../../../../core/widgets/app_loading_view.dart';
import '../../application/task_providers.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../content/task_copy.dart';
import '../../domain/command/update_task_command.dart';
import 'task_form_page.dart';

class EditTaskPage extends ConsumerStatefulWidget {
  final String taskId;

  const EditTaskPage({super.key, required this.taskId});

  @override
  ConsumerState<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends ConsumerState<EditTaskPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(taskNotifierProvider.notifier).loadById(taskId: widget.taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskNotifierProvider);
    final task = state.selectedTask;

    if (task == null || task.id != widget.taskId) {
      return const Scaffold(
        body: AppLoadingView(
          title: TaskCopy.loadingTaskTitle,
          subtitle: TaskCopy.loadingTaskSubtitle,
        ),
      );
    }

    return TaskFormPage(
      existing: task,
      isSaving: state.isSaving,
      shouldPopOnSubmit: false,
      onSubmit: (result, feedbackContext) async {
        // --- Calculate explicit clear flags to prevent the Null vs Undefined trap ---
        final bool shouldClearDueDate =
            task.dueDate != null && result.dueDate == null;
        final bool shouldClearDueDateTime =
            task.dueDateTime != null && result.dueDateTime == null;
        final bool shouldClearRecurrence =
            task.recurrenceType.isRecurring &&
            !result.recurrenceType.isRecurring;

        final command = UpdateTaskCommand(
          title: result.title,
          description: result.description,
          category: result.category,
          status: task.status,
          taskMode: result.taskMode,
          priority: result.priority,

          dueDate: result.dueDate,
          dueDateTime: result.dueDateTime,
          clearDueDate: shouldClearDueDate,
          clearDueDateTime: shouldClearDueDateTime,

          progressPercent: result.progressPercent,
          archived: task.archived,

          recurrenceType: result.recurrenceType,
          recurrenceStartDate: result.recurrenceStartDate,
          recurrenceEndDate: result.recurrenceEndDate,
          recurrenceDaysOfWeek: result.recurrenceDaysOfWeek,
          clearRecurrence: shouldClearRecurrence,

          linkedScheduleBlockId: result.clearLinkedScheduleBlock
              ? null
              : result.linkedScheduleBlockId,
          clearLinkedScheduleBlock: result.clearLinkedScheduleBlock,
          tags: result.tags,
        );

        await ref
            .read(taskMutationCoordinatorProvider)
            .updateTask(taskId: task.id, command: command);

        final latest = ref.read(taskNotifierProvider);
        if (!context.mounted || !feedbackContext.mounted) return;

        if (latest.errorMessage != null) {
          AppFeedback.error(feedbackContext, message: latest.errorMessage!);
          return;
        }

        Navigator.of(feedbackContext).pop(TaskCopy.successUpdated);
      },
    );
  }
}
