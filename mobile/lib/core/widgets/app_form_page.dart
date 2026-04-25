import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppFormPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget bottomBar;
  final List<Widget>? actions;
  final bool scrollable;

  const AppFormPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    required this.bottomBar,
    this.actions,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final body = scrollable
        ? SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.lg,
              AppSpacing.pageHorizontal,
              AppSpacing.xl,
            ),
            child: child,
          )
        : Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.lg,
              AppSpacing.pageHorizontal,
              AppSpacing.xl,
            ),
            child: child,
          );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if ((subtitle ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  style: AppTextStyles.bodySecondary(context),
                ),
              ),
          ],
        ),
        actions: actions,
      ),
      body: SafeArea(top: false, child: body),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.md,
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
          ),
          child: bottomBar,
        ),
      ),
    );
  }
}
