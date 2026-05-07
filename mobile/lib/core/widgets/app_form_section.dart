import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const AppFormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasSubtitle = (subtitle ?? '').trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.statLabel(context).copyWith(
              fontSize: 11,
              letterSpacing: 0.85,
              color: scheme.primary.withValues(alpha: 0.86),
              fontWeight: FontWeight.w800,
            ),
          ),
          if (hasSubtitle) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!.trim(),
              style: AppTextStyles.bodySecondary(
                context,
              ).copyWith(height: 1.28),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
