import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/entities/timeline_item.dart';
import '../../domain/enum/timeline_item_type.dart';

class TimelineItemCard extends StatelessWidget {
  final TimelineItem item;
  final DateTime now;
  final bool isFirst;
  final bool isLast;

  const TimelineItemCard({
    super.key,
    required this.item,
    required this.now,
    this.isFirst = false,
    this.isLast = false,
  });

  IconData _typeIcon(TimelineItemType type) => switch (type) {
    TimelineItemType.task => AppIcons.tasks,
    TimelineItemType.schedule => AppIcons.schedule,
    TimelineItemType.stay => AppIcons.places,
    TimelineItemType.unknown => AppIcons.incomplete,
  };

  String _typeLabel(TimelineItemType type) => switch (type) {
    TimelineItemType.task => 'Task',
    TimelineItemType.schedule => 'Schedule',
    TimelineItemType.stay => 'Stay session',
    TimelineItemType.unknown => 'Event',
  };

  String _timeLabel() {
    final fmt = DateFormat('h:mm a');
    if (item.startTime != null && item.endTime != null) {
      return '${fmt.format(item.startTime!)}\n${fmt.format(item.endTime!)}';
    }
    if (item.startTime != null) return fmt.format(item.startTime!);
    return '--';
  }

  String _metaLine(String statusLabel) {
    final parts = <String>[];
    final subtitle = item.subtitle?.trim();
    final source = (item.badge?.trim().isNotEmpty == true)
        ? item.badge!.trim()
        : item.status?.trim();

    const generic = {
      'schedule', 'task', 'stay', 'stay session',
      'spending', 'financial', 'completed', 'upcoming', 'now', 'open',
    };

    if (subtitle != null && subtitle.isNotEmpty) {
      for (final raw in subtitle.split('·')) {
        final t = raw.trim();
        if (t.isEmpty) continue;
        if (generic.contains(t.toLowerCase())) continue;
        if (t.toLowerCase() == _typeLabel(item.type).toLowerCase()) continue;
        if (parts.any((p) => p.toLowerCase() == t.toLowerCase())) continue;
        parts.add(t);
      }
    }

    if (source != null &&
        source.isNotEmpty &&
        source.toLowerCase() != statusLabel.toLowerCase() &&
        !generic.contains(source.toLowerCase()) &&
        !parts.any((p) => p.toLowerCase() == source.toLowerCase())) {
      parts.add(source);
    }

    if (parts.isEmpty) parts.add(_typeLabel(item.type));
    return parts.join(' · ');
  }

  String _statusLabel() => switch (item.temporalStateAt(now)) {
    TimelineTemporalState.now => 'Now',
    TimelineTemporalState.completed => 'Completed',
    TimelineTemporalState.upcoming => 'Upcoming',
    TimelineTemporalState.open => 'Open',
  };

  Color _statusColor() => switch (item.temporalStateAt(now)) {
    TimelineTemporalState.now => AppColors.violet,
    TimelineTemporalState.completed => AppColors.green,
    TimelineTemporalState.upcoming => AppColors.blue,
    TimelineTemporalState.open => AppColors.slate,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = AppColors.timelineTypeColor(context, item.type.name);
    final statusLabel = _statusLabel();

    return Semantics(
      container: true,
      label: '${_typeLabel(item.type)}. ${item.title}. ${_timeLabel()}.',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fixed 70px time axis ─────────────────────────────────────────
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 14, right: AppSpacing.sm),
              child: Text(
                _timeLabel(),
                textAlign: TextAlign.right,
                style: AppTextStyles.timeLabelSm(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
                  height: 1.4,
                ),
              ),
            ),
          ),

          // ── Connector column ─────────────────────────────────────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Top line — transparent if first item
                Container(
                  width: 2,
                  height: 14,
                  color: isFirst
                      ? Colors.transparent
                      : scheme.outlineVariant.withValues(alpha: 0.30),
                ),
                // Node
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.22),
                      width: 0.9,
                    ),
                  ),
                  child: Icon(_typeIcon(item.type), size: 14, color: color),
                ),
                // Bottom line — omitted if last item
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      width: 2,
                      height: double.infinity,
                      constraints: const BoxConstraints(minHeight: 24),
                      color: scheme.outlineVariant.withValues(alpha: 0.30),
                    ),
                  ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.sm,
                bottom: isLast ? 0 : AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: AppTextStyles.cardTitle(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _metaLine(statusLabel),
                    style: AppTextStyles.metaLabel(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppChip.status(
                    label: statusLabel,
                    color: _statusColor(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

