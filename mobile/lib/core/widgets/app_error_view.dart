import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Shared error state widget used across all features.
///
/// Use when a whole page/section cannot load.
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;
  final bool centered;

  const AppErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = _ErrorContent(
      title: title,
      message: message,
      onRetry: onRetry,
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

class _ErrorContent extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _ErrorContent({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ErrorIcon(),
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
            message,
            style: AppTextStyles.bodySecondary(context).copyWith(height: 1.34),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton.secondary(
            label: 'Try again',
            icon: AppIcons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _ErrorIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        border: Border.all(
          color: scheme.error.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Icon(AppIcons.error, size: 32, color: scheme.onErrorContainer),
    );
  }
}

/// Sliver version for use inside CustomScrollView.
class SliverAppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;

  const SliverAppErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: AppErrorView(title: title, message: message, onRetry: onRetry),
    );
  }
}
