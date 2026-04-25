import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppStatBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? helper;
  final Color? color;
  final CrossAxisAlignment crossAxisAlignment;

  const AppStatBlock({
    super.key,
    required this.label,
    required this.value,
    this.helper,
    this.color,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.cellBg(context, accent),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.metaLabel(context),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.statValue(
              context,
            ).copyWith(color: accent, fontWeight: FontWeight.w700),
          ),
          if (helper != null && helper!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              helper!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.metaLabel(context),
            ),
          ],
        ],
      ),
    );
  }
}
