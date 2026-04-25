import 'package:flutter/material.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Shared loading state widget used across all features.
class AppLoadingView extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool centered;

  const AppLoadingView({
    super.key,
    this.title = 'Loading',
    this.subtitle = 'Preparing content for the selected view.',
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.cardTitle(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.bodySecondary(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (centered) {
      return Center(child: content);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
        child: content,
      ),
    );
  }
}

/// Sliver version for use inside CustomScrollView.
class SliverAppLoadingView extends StatelessWidget {
  final String title;
  final String subtitle;

  const SliverAppLoadingView({
    super.key,
    this.title = 'Loading',
    this.subtitle = 'Preparing content for the selected view.',
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: AppLoadingView(title: title, subtitle: subtitle),
    );
  }
}

/// Shared list skeleton used by list-heavy pages (timeline, tasks, places).
class SliverAppLoadingList extends StatelessWidget {
  final int itemCount;
  final double topPadding;
  final double bottomPadding;

  const SliverAppLoadingList({
    super.key,
    this.itemCount = 4,
    this.topPadding = AppSpacing.sm,
    this.bottomPadding = AppSpacing.xl,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        top: topPadding,
        bottom: bottomPadding,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.listItemGap),
            child: _LoadingCardSkeleton(),
          );
        }, childCount: itemCount),
      ),
    );
  }
}

class _LoadingCardSkeleton extends StatelessWidget {
  const _LoadingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final block = scheme.surfaceContainerHighest.withValues(alpha: 0.82);

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.iconContainerSize,
                  height: AppSpacing.iconContainerSize,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: BorderRadius.circular(AppRadius.icon),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBar(widthFactor: 0.62, color: block),
                      const SizedBox(height: AppSpacing.xs),
                      _SkeletonBar(widthFactor: 0.38, color: block),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SkeletonBar(widthFactor: 1.0, color: block, height: 12),
            const SizedBox(height: AppSpacing.xs),
            _SkeletonBar(widthFactor: 0.84, color: block, height: 12),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double widthFactor;
  final Color color;
  final double height;

  const _SkeletonBar({
    required this.widthFactor,
    required this.color,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}
