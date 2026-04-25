import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/content/product_terms.dart';
import '../../domain/model/today_place_insight.dart';

class TodayPlaceInsightCard extends StatelessWidget {
  final TodayPlaceInsight insight;
  final VoidCallback? onTap;

  const TodayPlaceInsightCard({super.key, required this.insight, this.onTap});

  String _durationText(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) return '${hours}h';
    return '${hours}h ${remaining}m';
  }

  @override
  Widget build(BuildContext context) {
    final isUnknown =
        insight.placeName.trim().isEmpty ||
        insight.placeName.toLowerCase().contains('unknown');

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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.iconBg(context, AppColors.indigo),
                      borderRadius: BorderRadius.circular(AppRadius.icon),
                    ),
                    child: const Icon(
                      Icons.place_outlined,
                      color: AppColors.indigo,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      ProductTerms.topPlace,
                      style: AppTextStyles.sectionHeader(context),
                    ),
                  ),
              ],
            ),
              const SizedBox(height: AppSpacing.sm),
              if (isUnknown) ...[
                Text(
                  'No dominant place',
                  style: AppTextStyles.cardTitle(context),
                ),
                Text(
                  'Time was spread across several places.',
                  style: AppTextStyles.bodySecondary(context),
                ),
              ] else ...[
                Text(
                  insight.placeName,
                  style: AppTextStyles.cardTitle(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${insight.placeType} · ${_durationText(insight.durationMinutes)}',
                  style: AppTextStyles.bodySecondary(context),
                ),
              ],
              if (onTap != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Open places',
                  style: AppTextStyles.metaLabel(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
