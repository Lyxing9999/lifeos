import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_priority.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_status.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_chip.dart';
import '../../../application/task_providers.dart';
import '../../../domain/entities/schedule_select_option.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/enum/task_mode.dart';
import '../../style/task_style.dart';
import '../task_progress_bar.dart';
import 'task_detail_meta_row.dart';

class TaskDetailMetaSection extends ConsumerWidget {
  final Task task;

  const TaskDetailMetaSection({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleOptions = ref.watch(taskScheduleSelectOptionsProvider);
    final linkedSchedule = _resolveLinkedSchedule(scheduleOptions, task);

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: AppSpacing.md),

            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppChip.metadata(
                  label: _modeDetailLabel(task.taskMode),
                  icon: TaskStyle.modeIcon(task.taskMode),
                  color: TaskStyle.modeColor(task.taskMode),
                ),
                AppChip.metadata(
                  label: task.priority.label,
                  icon: TaskStyle.priorityIcon(task.priority),
                  color: TaskStyle.priorityColor(task.priority),
                ),
              ],
            ),

            if (!task.status.isDone && task.taskMode == TaskMode.progress) ...[
              const SizedBox(height: AppSpacing.sm),
              TaskProgressBar(progress: task.progressPercent),
            ],

            const SizedBox(height: AppSpacing.md),

            TaskDetailMetaRow(
              icon: AppIcons.date,
              label: 'Due',
              value: _dueLabel(task.dueDate, task.dueDateTime),
            ),

            if (task.paused) ...[
              const SizedBox(height: AppSpacing.sm),
              TaskDetailMetaRow(
                icon: AppIcons.paused,
                label: 'Paused',
                value: task.pauseUntil == null
                    ? 'Until resumed'
                    : 'Until ${_dateLabel(task.pauseUntil)}',
              ),
            ],

            if (task.recurrenceType.isRecurring) ...[
              const SizedBox(height: AppSpacing.sm),
              TaskDetailMetaRow(
                icon: AppIcons.recurrence,
                label: 'Repeats',
                value: task.recurrenceType.label,
              ),
              const SizedBox(height: AppSpacing.sm),
              TaskDetailMetaRow(
                icon: AppIcons.start,
                label: 'Starts',
                value: _dateLabel(task.recurrenceStartDate),
              ),
              const SizedBox(height: AppSpacing.sm),
              TaskDetailMetaRow(
                icon: AppIcons.stop,
                label: 'Ends',
                value: task.recurrenceEndDate == null
                    ? 'Never'
                    : _dateLabel(task.recurrenceEndDate),
              ),
              if (task.recurrenceDaysOfWeek.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                TaskDetailMetaRow(
                  icon: AppIcons.calendar,
                  label: 'Days',
                  value: _weekdayLabel(task.recurrenceDaysOfWeek),
                ),
              ],
            ] else if (task.taskMode == TaskMode.daily) ...[
              const SizedBox(height: AppSpacing.sm),
              const TaskDetailMetaRow(
                icon: AppIcons.dailyTask,
                label: "Today's Focus",
                value: 'Pinned to today (Does not repeat)',
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            _LinkedScheduleRow(
              linkedSchedule: linkedSchedule,
              rawLinkedScheduleBlockId: task.linkedScheduleBlockId,
              isLoading: scheduleOptions.isLoading,
              hasError: scheduleOptions.hasError,
            ),
          ],
        ),
      ),
    );
  }

  ScheduleSelectOption? _resolveLinkedSchedule(
    AsyncValue<List<ScheduleSelectOption>> options,
    Task task,
  ) {
    final linkedId = (task.linkedScheduleBlockId ?? '').trim();
    if (linkedId.isEmpty) return null;

    final values = options.valueOrNull ?? const <ScheduleSelectOption>[];

    for (final option in values) {
      if (option.scheduleBlockId == linkedId || option.value == linkedId) {
        return option;
      }
    }

    return null;
  }

  String _modeDetailLabel(TaskMode mode) {
    switch (mode) {
      case TaskMode.standard:
        return 'Standard';
      case TaskMode.urgent:
        return 'Urgent';
      case TaskMode.daily:
        return "Today's Focus";
      case TaskMode.progress:
        return 'Progress';
    }
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Not set';
    return DateFormat.yMMMd().format(date);
  }

  String _dueLabel(DateTime? date, DateTime? dateTime) {
    if (dateTime != null) {
      return DateFormat.yMMMd().add_jm().format(dateTime);
    }

    if (date != null) {
      return DateFormat.yMMMd().format(date);
    }

    return 'Not set';
  }

  String _weekdayLabel(List<String> days) {
    return days.map(_shortWeekday).join(', ');
  }

  String _shortWeekday(String day) {
    switch (day.toUpperCase()) {
      case 'MONDAY':
        return 'Mon';
      case 'TUESDAY':
        return 'Tue';
      case 'WEDNESDAY':
        return 'Wed';
      case 'THURSDAY':
        return 'Thu';
      case 'FRIDAY':
        return 'Fri';
      case 'SATURDAY':
        return 'Sat';
      case 'SUNDAY':
        return 'Sun';
      default:
        return day;
    }
  }
}

class _LinkedScheduleRow extends StatelessWidget {
  final ScheduleSelectOption? linkedSchedule;
  final String? rawLinkedScheduleBlockId;
  final bool isLoading;
  final bool hasError;

  const _LinkedScheduleRow({
    required this.linkedSchedule,
    required this.rawLinkedScheduleBlockId,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final linkedId = (rawLinkedScheduleBlockId ?? '').trim();

    if (linkedId.isEmpty) {
      return const TaskDetailMetaRow(
        icon: AppIcons.linked,
        label: 'Schedule block',
        value: 'Not linked',
      );
    }

    if (linkedSchedule != null) {
      return TaskDetailMetaRichRow(
        icon: AppIcons.linked,
        label: 'Schedule block',
        title: linkedSchedule!.title,
        subtitle: linkedSchedule!.label,
      );
    }

    if (isLoading) {
      return const TaskDetailMetaRow(
        icon: AppIcons.linked,
        label: 'Schedule block',
        value: 'Loading...',
      );
    }

    if (hasError) {
      return const TaskDetailMetaRow(
        icon: AppIcons.linked,
        label: 'Schedule block',
        value: 'Could not load',
      );
    }

    return TaskDetailMetaRichRow(
      icon: AppIcons.linked,
      label: 'Schedule block',
      title: 'Linked block',
      subtitle: linkedId,
    );
  }
}
