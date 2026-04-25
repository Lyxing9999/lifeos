import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/model/timeline_item.dart';

class TimelineItemCard extends StatelessWidget {
  final TimelineItem item;
  final DateTime now;
  final bool showConnector;

  const TimelineItemCard({
    super.key,
    required this.item,
    required this.now,
    this.showConnector = true,
  });

  Color _typeColor(BuildContext context, String type) =>
      AppColors.timelineTypeColor(context, type);

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return Icons.check_circle_outline_rounded;
      case 'schedule':
        return Icons.calendar_month_outlined;
      case 'stay':
        return Icons.location_on_outlined;
      case 'financial':
        return Icons.payments_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return 'Task';
      case 'schedule':
        return 'Schedule';
      case 'stay':
        return 'Stay session';
      case 'financial':
        return 'Spending';
      default:
        return 'Event';
    }
  }

  String _timeLabel() {
    final timeFormat = DateFormat('h:mm a');

    if (item.startTime == null && item.endTime == null) {
      return '--';
    }

    if (item.startTime != null && item.endTime != null) {
      return '${timeFormat.format(item.startTime!)} - ${timeFormat.format(item.endTime!)}';
    }

    if (item.startTime != null) {
      return timeFormat.format(item.startTime!);
    }

    return '--';
  }

  String _metaLine(String statusLabel) {
    final parts = <String>[];
    final subtitle = item.subtitle?.trim();
    final source = item.source?.trim();
    final normalizedStatus = statusLabel.trim().toLowerCase();
    final normalizedTypeLabel = _typeLabel(item.type).toLowerCase();
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

    if (subtitle != null && subtitle.isNotEmpty) {
      for (final rawToken in subtitle.split('·')) {
        final token = rawToken.trim();
        if (token.isEmpty) continue;
        final normalizedToken = token.toLowerCase();
        if (genericSources.contains(normalizedToken) ||
            normalizedToken == normalizedTypeLabel ||
            parts.any((part) => part.toLowerCase() == normalizedToken)) {
          continue;
        }
        parts.add(token);
      }
    }

    if (source != null &&
        source.isNotEmpty &&
        source.toLowerCase() != normalizedStatus &&
        !genericSources.contains(source.toLowerCase()) &&
        !parts.any((part) => part.toLowerCase() == source.toLowerCase())) {
      parts.add(source);
    }

    if (parts.isEmpty) {
      parts.add(_typeLabel(item.type));
    }

    return parts.join(' · ');
  }

  String _statusLabel() {
    return switch (item.temporalStateAt(now)) {
      TimelineTemporalState.now => 'Now',
      TimelineTemporalState.completed => 'Completed',
      TimelineTemporalState.upcoming => 'Upcoming',
      TimelineTemporalState.open => 'Open',
    };
  }

  Color _statusColor() {
    return switch (item.temporalStateAt(now)) {
      TimelineTemporalState.now => AppColors.violet,
      TimelineTemporalState.completed => AppColors.green,
      TimelineTemporalState.upcoming => AppColors.blue,
      TimelineTemporalState.open => AppColors.slate,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(context, item.type);
    final timeLabel = _timeLabel();
    final statusLabel = _statusLabel();
    final statusColor = _statusColor();
    final metaLine = _metaLine(statusLabel);
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: '${_typeLabel(item.type)}. ${item.title}. $timeLabel.',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 66,
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Text(
                    timeLabel,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.timeLabelSm(context).copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.78),
                    ),
                  ),
                  if (showConnector)
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: scheme.outlineVariant.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 34,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.16),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(_typeIcon(item.type), size: 15, color: color),
                  ),
                  if (showConnector) const Expanded(child: SizedBox()),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: color.withValues(alpha: 0.62),
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: AppSpacing.cardInsetsSm,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: AppTextStyles.cardTitle(
                                    context,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            metaLine,
                            style: AppTextStyles.metaLabel(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          AppChip.status(
                            label: statusLabel,
                            color: statusColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
