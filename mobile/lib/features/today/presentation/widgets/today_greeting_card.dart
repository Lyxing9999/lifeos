import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class TodayGreetingCard extends StatelessWidget {
  final String name;
  final DateTime date;
  final String timezone;
  final bool hasCurrentBlock;
  final int timelineCount;

  const TodayGreetingCard({
    super.key,
    required this.name,
    required this.date,
    required this.timezone,
    required this.hasCurrentBlock,
    required this.timelineCount,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = _firstName(name);
    // Use device local time for greeting — not the server date, which may be UTC.
    final greeting = _greetingFor(DateTime.now());
    final scheme = Theme.of(context).colorScheme;
    final summaryLine = hasCurrentBlock
        ? 'You are inside a planned block right now'
        : timelineCount > 0
        ? '$timelineCount ${timelineCount == 1 ? 'timeline item' : 'timeline items'} recorded for this day'
        : 'No day signals yet — start with a task or planned block';

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.iconBg(context, AppColors.blue),
                borderRadius: BorderRadius.circular(AppRadius.icon),
              ),
              child: const Icon(
                Icons.wb_sunny_outlined,
                color: AppColors.blue,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstName.isEmpty ? greeting : '$greeting, $firstName',
                    style: AppTextStyles.pageTitle(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${DateFormat('EEEE, d MMMM').format(date)} · ${_readableTimezone(timezone)}',
                    style: AppTextStyles.bodySecondary(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    summaryLine,
                    style: AppTextStyles.metaLabel(
                      context,
                    ).copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _firstName(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    return parts.first;
  }

  String _greetingFor(DateTime localNow) {
    final hour = localNow.hour;
    if (hour < 5) return 'Still up?';
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    if (hour < 22) return 'Good evening';
    return 'Winding down';
  }

  String _readableTimezone(String value) {
    if (value == 'Asia/Phnom_Penh') return 'Phnom Penh time';
    if (value == 'Asia/Bangkok') return 'Bangkok time';
    if (value == 'Asia/Singapore') return 'Singapore time';
    if (value == 'Asia/Tokyo') return 'Tokyo time';
    if (value == 'UTC') return 'UTC';
    return value.replaceAll('_', ' ');
  }
}
