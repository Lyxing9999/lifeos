import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_glass_style.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppFormPage extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget bottomBar;
  final List<Widget>? actions;
  final bool scrollable;

  const AppFormPage({
    super.key,
    this.scaffoldKey,
    required this.title,
    this.subtitle,
    required this.child,
    required this.bottomBar,
    this.actions,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    final body = scrollable
        ? SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.lg,
              AppSpacing.pageHorizontal,
              AppSpacing.xxl,
            ),
            child: child,
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.lg,
              AppSpacing.pageHorizontal,
              AppSpacing.xxl,
            ),
            child: child,
          );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: scheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        titleSpacing: AppSpacing.pageHorizontal,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if ((subtitle ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!.trim(),
                style: AppTextStyles.bodySecondary(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        actions: actions,
      ),
      body: SafeArea(top: false, child: body),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: _FormBottomBar(child: bottomBar),
      ),
    );
  }
}

class _FormBottomBar extends StatelessWidget {
  final Widget child;

  const _FormBottomBar({required this.child});

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          keyboardOpen ? AppSpacing.xs : AppSpacing.sm,
          AppSpacing.pageHorizontal,
          keyboardOpen ? AppSpacing.sm : AppSpacing.lg,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            keyboardOpen ? AppRadius.card : AppRadius.cardLg,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: keyboardOpen ? 10 : AppGlassStyle.cardBlurSigma,
              sigmaY: keyboardOpen ? 10 : AppGlassStyle.cardBlurSigma,
            ),
            child: Container(
              padding: EdgeInsets.all(
                keyboardOpen ? AppSpacing.xs : AppSpacing.sm,
              ),
              decoration: AppGlassStyle.surfaceDecoration(
                context,
                borderRadius: BorderRadius.circular(
                  keyboardOpen ? AppRadius.card : AppRadius.cardLg,
                ),
                lightSurfaceAlpha: keyboardOpen ? 0.86 : 0.92,
                darkSurfaceAlpha: keyboardOpen ? 0.64 : 0.72,
                lightBorderAlpha: 0.36,
                darkBorderAlpha: 0.26,
                lightShadowAlpha: keyboardOpen ? 0 : 0.055,
                darkShadowAlpha: keyboardOpen ? 0 : 0.16,
                shadowBlurRadius: keyboardOpen ? 0 : 16,
                shadowOffset: const Offset(0, 6),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
