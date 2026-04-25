import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../timeline/domain/model/timeline_item.dart';

class TodayTimelinePreviewCard extends StatelessWidget {
  final List<TimelineItem> items;
  final DateTime now;
  final VoidCallback onTap;

  const TodayTimelinePreviewCard({
    super.key,
    required this.items,
    required this.now,
    required this.onTap,
  });

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return Icons.check_circle_outline;
      case 'schedule':
      case 'block':
        return Icons.calendar_month_outlined;
      case 'stay':
      case 'location':
        return Icons.location_on_outlined;
      case 'financial':
      case 'purchase':
        return Icons.payments_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  String _secondaryLine(TimelineItem item) {
    final subtitle = item.subtitle?.trim();
    final source = item.source?.trim();
    final parts = <String>[];
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
    };

    if ((subtitle == null || subtitle.isEmpty) &&
        (source == null || source.isEmpty)) {
      return item.isNowAt(now) ? 'Happening now' : 'Scheduled today';
    }

    if (subtitle != null && subtitle.isNotEmpty) {
      parts.add(subtitle);
    }

    if (source != null &&
        source.isNotEmpty &&
        !genericSources.contains(source.toLowerCase()) &&
        !parts.any((part) => part.toLowerCase() == source.toLowerCase())) {
      parts.add(source);
    }

    if (parts.isEmpty) {
      return item.isNowAt(now) ? 'Happening now' : 'Scheduled today';
    }

    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final preview = items.take(4).toList();
    final timeFormat = DateFormat('h:mm a');

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coming up',
                          style: AppTextStyles.cardTitle(context),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Current and next items',
                          style: AppTextStyles.bodySecondary(context),
                        ),
                      ],
                    ),
                  ),
                  Text('View all', style: AppTextStyles.metaLabel(context)),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...preview.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final color = AppColors.timelineTypeColor(context, item.type);
                final status = item.temporalStateAt(now);
                final isCurrent = status == TimelineTemporalState.now;
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
                          _typeIcon(item.type),
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
                              _secondaryLine(item),
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
      ),
    );
  }
}
