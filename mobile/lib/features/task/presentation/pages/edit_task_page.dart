import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../application/task_providers.dart';
import '../../content/task_copy.dart';
import '../../data/dto/update_task_request_dto.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_recurrence_type.dart';
import '../../domain/enum/task_status.dart';
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
      final userId = ref.read(currentUserIdProvider);
      ref
          .read(taskNotifierProvider.notifier)
          .loadById(userId: userId, taskId: widget.taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskNotifierProvider);
    final task = state.selectedTask;
    final userId = ref.read(currentUserIdProvider);

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
      onSubmit: (result) async {
        final request = UpdateTaskRequestDto(
          title: result.title,
          description: result.description,
          category: result.category,
          status: task.status.apiValue,
          taskMode: result.taskMode.apiValue,
          priority: result.priority.apiValue,
          dueDate: _formatDate(result.dueDate),
          dueDateTime: _formatDateTime(result.dueDateTime),
          progressPercent: result.progressPercent,
          archived: task.archived,
          recurrenceType: result.recurrenceType.apiValue,
          recurrenceStartDate: _formatDate(result.recurrenceStartDate),
          recurrenceEndDate: _formatDate(result.recurrenceEndDate),
          recurrenceDaysOfWeek: result.recurrenceDaysOfWeek.isEmpty
              ? null
              : result.recurrenceDaysOfWeek.join(','),
          linkedScheduleBlockId: result.linkedScheduleBlockId,
          tags: result.tags.isEmpty ? null : result.tags,
        );

        await ref
            .read(taskNotifierProvider.notifier)
            .updateTask(userId: userId, taskId: task.id, request: request);

        final latest = ref.read(taskNotifierProvider);
        if (!context.mounted) return;

        if (latest.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(latest.errorMessage!)));
          return;
        }

        Navigator.of(context).pop(TaskCopy.successUpdated);
      },
    );
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String? _formatDateTime(DateTime? dateTime) {
    return dateTime?.toUtc().toIso8601String();
  }
}
