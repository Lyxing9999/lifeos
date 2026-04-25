import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../application/task_providers.dart';
import '../../content/task_copy.dart';
import '../../data/dto/create_task_request_dto.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_recurrence_type.dart';
import 'task_form_page.dart';

class CreateTaskPage extends ConsumerWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(currentUserIdProvider);
    final isSaving = ref.watch(taskNotifierProvider).isSaving;

    return TaskFormPage(
      isSaving: isSaving,
      shouldPopOnSubmit: false,
      onSubmit: (result) async {
        final request = CreateTaskRequestDto(
          userId: userId,
          title: result.title,
          description: result.description,
          category: result.category,
          taskMode: result.taskMode.apiValue,
          priority: result.priority.apiValue,
          dueDate: _formatDate(result.dueDate),
          dueDateTime: _formatDateTime(result.dueDateTime),
          progressPercent: result.progressPercent,
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
            .createTask(userId: userId, request: request);

        final latest = ref.read(taskNotifierProvider);
        if (!context.mounted) return;

        if (latest.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(latest.errorMessage!)));
          return;
        }

        Navigator.of(context).pop(TaskCopy.successCreated);
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
