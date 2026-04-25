import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      titleSpacing: AppSpacing.pageHorizontal,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.pageTitle(context)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.bodySecondary(context)),
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          height: 0.5,
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
