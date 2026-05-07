import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_sparse_state_card.dart';
import '../../../timeline/domain/entities/timeline_item.dart';
import '../../../timeline/domain/enum/timeline_item_type.dart';

class TodayTimelineTruthCard extends StatelessWidget {
  final List<TimelineItem> items;
  final DateTime now;
  final bool isSelectedToday;
  final VoidCallback onTap;

  const TodayTimelineTruthCard({
    super.key,
    required this.items,
    required this.now,
    required this.isSelectedToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = items.take(5).toList();
    final timeFormat = DateFormat('h:mm a');

    return AppCard(
      glass: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(isSelectedToday: isSelectedToday),
            const SizedBox(height: AppSpacing.md),
            ...preview.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final color = AppColors.timelineTypeColor(
                context,
                item.type.name,
              );
              final status = item.temporalStateAt(now);
              final isCurrent =
                  isSelectedToday && status == TimelineTemporalState.now;
              final isLast = index == preview.length - 1;

              final timeLabel = item.startTime == null
                  ? 'Open'
                  : isCurrent
                  ? 'Now'
                  : timeFormat.format(item.startTime!);

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        timeLabel,
                        style: isCurrent
                            ? AppTextStyles.metaLabel(context).copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              )
                            : AppTextStyles.timeLabelSm(context),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.iconBg(context, color),
                        borderRadius: BorderRadius.circular(AppRadius.icon),
                      ),
                      child: Icon(
                        _typeIcon(item.type.name),
                        size: 15,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.bodyPrimary(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _secondaryLine(item, timeFormat),
                            style: AppTextStyles.bodySecondary(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return AppIcons.tasks;
      case 'schedule':
      case 'block':
        return AppIcons.schedule;
      case 'stay':
      case 'location':
        return AppIcons.places;
      case 'financial':
      case 'purchase':
        return AppIcons.finance;
      default:
        return AppIcons.incomplete;
    }
  }

  static String _secondaryLine(TimelineItem item, DateFormat timeFormat) {
    final parts = <String>[];
    final subtitle = item.subtitle?.trim();

    if (subtitle != null && subtitle.isNotEmpty) {
      parts.addAll(
        subtitle
            .split('·')
            .map((value) => _cleanMetaToken(value))
            .where((value) => value.isNotEmpty),
      );
    }

    final start = item.startTime;
    final end = item.endTime;

    if (start != null && end != null) {
      parts.add('${timeFormat.format(start)}-${timeFormat.format(end)}');
    } else if (start != null) {
      parts.add(timeFormat.format(start));
    }

    if (parts.isEmpty) {
      return _typeLabel(item.type);
    }

    return parts.join(' · ');
  }

  static String _cleanMetaToken(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '';
    }

    final genericSources = <String>{
      'schedule',
      'task',
      'stay',
      'stay session',
      'spending',
      'financial',
      'completed',
      'upcoming',
      'now',
      'open',
      'block',
    };

    if (genericSources.contains(trimmed.toLowerCase())) {
      return '';
    }

    if (trimmed == trimmed.toUpperCase() && trimmed.length > 1) {
      return trimmed[0] + trimmed.substring(1).toLowerCase();
    }

    return trimmed;
  }

  static String _typeLabel(TimelineItemType type) {
    return switch (type) {
      TimelineItemType.task => 'Task',
      TimelineItemType.schedule => 'Schedule',
      TimelineItemType.stay => 'Stay session',
      TimelineItemType.unknown => 'Event',
    };
  }
}

class _Header extends StatelessWidget {
  final bool isSelectedToday;

  const _Header({required this.isSelectedToday});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Timeline truth', style: AppTextStyles.cardTitle(context)),
              const SizedBox(height: 2),
              Text(
                isSelectedToday
                    ? 'What is happening across your day'
                    : 'Chronological truth for this date',
                style: AppTextStyles.bodySecondary(context),
              ),
            ],
          ),
        ),
        Text('View all', style: AppTextStyles.metaLabel(context)),
        const SizedBox(width: 2),
        Icon(
          AppIcons.chevronRight,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class TodayEmptyTimelineCard extends StatelessWidget {
  final VoidCallback onOpenTimeline;
  final VoidCallback onAddTask;

  const TodayEmptyTimelineCard({
    super.key,
    required this.onOpenTimeline,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return AppSparseStateCard(
      icon: AppIcons.timeline,
      title: 'No timeline truth yet',
      message:
          'Tasks and planned blocks will appear here once they belong to this day.',
      actionLabel: 'Add task',
      onAction: onAddTask,
    );
  }
}
