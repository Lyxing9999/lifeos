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
    final content = _LoadingContent(title: title, subtitle: subtitle);

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

class _LoadingContent extends StatelessWidget {
  final String title;
  final String subtitle;

  const _LoadingContent({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LoadingIcon(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTextStyles.cardTitle(
              context,
            ).copyWith(color: scheme.onSurface, letterSpacing: -0.15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.bodySecondary(context).copyWith(height: 1.34),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: scheme.primary.withValues(alpha: 0.82),
        ),
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
      hasScrollBody: false,
      child: AppLoadingView(title: title, subtitle: subtitle),
    );
  }
}

/// Shared list skeleton used by list-heavy pages:
/// timeline, tasks, places, schedule, summaries.
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
      sliver: SliverList.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.listItemGap),
            child: _LoadingCardSkeleton(),
          );
        },
      ),
    );
  }
}

class _LoadingCardSkeleton extends StatelessWidget {
  const _LoadingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final block = scheme.surfaceContainerHighest.withValues(
      alpha: isDark ? 0.42 : 0.78,
    );

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(
                  width: AppSpacing.iconContainerSize,
                  height: AppSpacing.iconContainerSize,
                  radius: AppRadius.icon,
                  color: block,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBar(widthFactor: 0.64, color: block),
                        const SizedBox(height: AppSpacing.xs),
                        _SkeletonBar(widthFactor: 0.42, color: block),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SkeletonBar(widthFactor: 1.0, color: block, height: 12),
            const SizedBox(height: AppSpacing.xs),
            _SkeletonBar(widthFactor: 0.82, color: block, height: 12),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
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
    return RepaintBoundary(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        alignment: Alignment.centerLeft,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
      ),
    );
  }
}
