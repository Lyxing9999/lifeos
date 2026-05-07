import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_glass_style.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool pinned;
  final bool floating;
  final double expandedHeight;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.pinned = true,
    this.floating = false,
    this.expandedHeight = 82,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: expandedHeight,
      leadingWidth: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppGlassStyle.headerBlurSigma,
            sigmaY: AppGlassStyle.headerBlurSigma,
          ),
          child: DecoratedBox(
            decoration: AppGlassStyle.headerDecoration(context),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: _HeaderText(title: title, subtitle: subtitle),
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              _HeaderActions(actions: actions!),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _HeaderText({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasSubtitle = (subtitle ?? '').trim().isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.pageTitle(
            context,
          ).copyWith(color: scheme.onSurface, letterSpacing: -0.45),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (hasSubtitle) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!.trim(),
            style: AppTextStyles.bodySecondary(
              context,
            ).copyWith(color: scheme.onSurfaceVariant, height: 1.18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final List<Widget> actions;

  const _HeaderActions({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions
          .map(
            (action) => Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: action,
            ),
          )
          .toList(),
    );
  }
}
