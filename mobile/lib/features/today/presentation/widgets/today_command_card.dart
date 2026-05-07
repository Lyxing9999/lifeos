import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../schedule/domain/enum/schedule_block_type.dart';
import '../../../task/domain/enum/task_mode.dart';
import '../../../task/domain/enum/task_priority.dart';
import '../../../task/domain/entities/task.dart';
import '../../../timeline/domain/entities/timeline_item.dart';
import '../../domain/model/today_current_schedule.dart';

class TodayCommandCard extends StatelessWidget {
  final bool isSelectedToday;
  final TodayCurrentSchedule? currentBlock;
  final Task? topActiveTask;
  final TimelineItem? nextItem;
  final DateTime now;

  final VoidCallback? onCurrentBlockTap;
  final VoidCallback? onTopTaskTap;
  final VoidCallback? onTimelineTap;
  final VoidCallback? onAddTaskTap;
  final VoidCallback? onAddScheduleTap;

  const TodayCommandCard({
    super.key,
    required this.isSelectedToday,
    required this.currentBlock,
    required this.topActiveTask,
    required this.nextItem,
    required this.now,
    this.onCurrentBlockTap,
    this.onTopTaskTap,
    this.onTimelineTap,
    this.onAddTaskTap,
    this.onAddScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFocus =
        currentBlock != null || topActiveTask != null || nextItem != null;

    return AppCard(
      glass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            title: isSelectedToday ? 'Command center' : 'Day focus',
            subtitle: isSelectedToday
                ? 'What matters right now'
                : 'Top signals for this date',
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasFocus) ...[
            if (currentBlock != null)
              _FocusRow(
                icon: _scheduleIcon(currentBlock!.type),
                color: AppColors.violet,
                label: currentBlock!.activeNow ? 'Now' : 'Block',
                title: currentBlock!.title,
                meta:
                    '${currentBlock!.type.label} · ${_timeRange(currentBlock!.startDateTime, currentBlock!.endDateTime)}',
                onTap: onCurrentBlockTap,
              ),
            if (currentBlock != null && topActiveTask != null)
              const SizedBox(height: AppSpacing.sm),
            if (topActiveTask != null)
              _FocusRow(
                icon: _taskIcon(topActiveTask!.taskMode),
                color: _taskColor(topActiveTask!),
                label: topActiveTask!.taskMode.label,
                title: topActiveTask!.title,
                meta: _taskMeta(topActiveTask!),
                onTap: onTopTaskTap,
              ),
            if ((currentBlock != null || topActiveTask != null) &&
                nextItem != null)
              const SizedBox(height: AppSpacing.sm),
            if (nextItem != null)
              _FocusRow(
                icon: _timelineIcon(nextItem!.type.name),
                color: AppColors.timelineTypeColor(
                  context,
                  nextItem!.type.name,
                ),
                label: 'Next',
                title: nextItem!.title,
                meta: _timelineMeta(nextItem!),
                onTap: onTimelineTap,
              ),
          ] else
            _EmptyCommandState(
              isSelectedToday: isSelectedToday,
              onAddTaskTap: onAddTaskTap,
              onAddScheduleTap: onAddScheduleTap,
            ),
        ],
      ),
    );
  }

  static String _timeRange(DateTime start, DateTime end) {
    final format = DateFormat('h:mm a');
    return '${format.format(start)}-${format.format(end)}';
  }

  static String _taskMeta(Task task) {
    final parts = <String>[];

    final category = (task.category ?? '').trim();
    if (category.isNotEmpty) {
      parts.add(category);
    }

    parts.add(task.priority.label);

    if (task.dueDateTime != null) {
      parts.add('Due ${DateFormat('h:mm a').format(task.dueDateTime!)}');
    }

    return parts.join(' · ');
  }

  static String _timelineMeta(TimelineItem item) {
    final parts = <String>[_timelineLabel(item.type.name)];
    final start = item.startTime;
    final end = item.endTime;

    if (start != null && end != null) {
      parts.add(_timeRange(start, end));
    } else if (start != null) {
      parts.add(DateFormat('h:mm a').format(start));
    }

    return parts.join(' · ');
  }

  static String _timelineLabel(String type) {
    switch (type.toLowerCase()) {
      case 'schedule':
      case 'block':
        return 'Planned time';
      case 'task':
        return 'Task';
      case 'stay':
      case 'location':
        return 'Stay session';
      case 'financial':
      case 'purchase':
        return 'Spending';
      default:
        return 'Timeline';
    }
  }

  static IconData _scheduleIcon(ScheduleBlockType type) {
    switch (type) {
      case ScheduleBlockType.work:
        return AppIcons.work;
      case ScheduleBlockType.study:
        return AppIcons.study;
      case ScheduleBlockType.meeting:
        return AppIcons.meeting;
      case ScheduleBlockType.exercise:
        return AppIcons.exercise;
      case ScheduleBlockType.rest:
        return AppIcons.rest;
      case ScheduleBlockType.commute:
        return AppIcons.commute;
      case ScheduleBlockType.personal:
        return AppIcons.personal;
      case ScheduleBlockType.other:
        return AppIcons.schedule;
    }
  }

  static IconData _taskIcon(TaskMode mode) {
    switch (mode) {
      case TaskMode.urgent:
        return AppIcons.urgentTask;
      case TaskMode.progress:
        return AppIcons.progressTask;
      case TaskMode.daily:
        return AppIcons.dailyTask;
      case TaskMode.standard:
        return AppIcons.standardTask;
    }
  }

  static IconData _timelineIcon(String type) {
    switch (type.toLowerCase()) {
      case 'schedule':
      case 'block':
        return AppIcons.schedule;
      case 'task':
        return AppIcons.tasks;
      case 'stay':
      case 'location':
        return AppIcons.places;
      case 'financial':
      case 'purchase':
        return AppIcons.finance;
      default:
        return AppIcons.timeline;
    }
  }

  static Color _taskColor(Task task) {
    switch (task.taskMode) {
      case TaskMode.urgent:
        return AppColors.warning;
      case TaskMode.progress:
        return AppColors.blue;
      case TaskMode.daily:
        return AppColors.green;
      case TaskMode.standard:
        return task.priority == TaskPriority.high
            ? AppColors.warning
            : AppColors.green;
    }
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(icon: AppIcons.focus, color: AppColors.blue),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.cardTitle(context)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySecondary(context)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FocusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String title;
  final String meta;
  final VoidCallback? onTap;

  const _FocusRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.title,
    required this.meta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBox(icon: icon, color: color),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                meta,
                style: AppTextStyles.bodySecondary(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppChip.status(label: label, color: color),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: content,
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.iconContainerSize,
      height: AppSpacing.iconContainerSize,
      decoration: BoxDecoration(
        color: AppColors.iconBg(context, color),
        borderRadius: BorderRadius.circular(AppRadius.icon),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _EmptyCommandState extends StatelessWidget {
  final bool isSelectedToday;
  final VoidCallback? onAddTaskTap;
  final VoidCallback? onAddScheduleTap;

  const _EmptyCommandState({
    required this.isSelectedToday,
    this.onAddTaskTap,
    this.onAddScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    final message = isSelectedToday
        ? 'Add one task or planned block to give Today a useful anchor.'
        : 'No task or planned block belongs to this date yet.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSelectedToday ? 'No active focus yet.' : 'No focus for this date.',
          style: AppTextStyles.bodyPrimary(
            context,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(message, style: AppTextStyles.bodySecondary(context)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppChip.filter(
              label: 'Add task',
              icon: AppIcons.addTask,
              selected: true,
              onTap: onAddTaskTap,
            ),
            AppChip.filter(
              label: 'Add planned block',
              icon: AppIcons.schedule,
              onTap: onAddScheduleTap,
            ),
          ],
        ),
      ],
    );
  }
}
