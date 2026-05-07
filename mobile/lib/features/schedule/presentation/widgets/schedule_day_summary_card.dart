import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_stat_block.dart';
import '../../content/schedule_copy.dart';
import '../../domain/entities/schedule_occurrence.dart';

class ScheduleDaySummaryCard extends StatelessWidget {
  final List<ScheduleOccurrence> items;

  const ScheduleDaySummaryCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.length;
    final totalMinutes = items.fold<int>(
      0,
      (sum, e) => sum + e.endDateTime.difference(e.startDateTime).inMinutes,
    );
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final timeLabel = hours > 0
        ? (minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h')
        : '${minutes}m';

    final sorted = List<ScheduleOccurrence>.from(items)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    final firstBlockTime = sorted.isEmpty
        ? '--'
        : DateFormat('h:mm a').format(sorted.first.startDateTime);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ProductTerms.dayOverview,
            style: AppTextStyles.cardTitle(context),
          ),
          const SizedBox(height: 2),
          Text(
            ScheduleCopy.pageSubtitle,
            style: AppTextStyles.bodySecondary(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppStatBlock(
                  label: ProductTerms.plannedBlocks,
                  value: '$total',
                  helper: ScheduleCopy.blockCountHelper(total),
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppStatBlock(
                  label: ScheduleCopy.summaryPlannedTime,
                  value: timeLabel,
                  helper: ScheduleCopy.summaryPlannedTimeHelper,
                  color: AppColors.violet,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppStatBlock(
                  label: ScheduleCopy.summaryFirstBlock,
                  value: firstBlockTime,
                  helper: ScheduleCopy.summaryFirstBlockHelper,
                  color: AppColors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
