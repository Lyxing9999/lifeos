import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// AppScaffold — for secondary/detail pages that do not need sliver headers.
///
/// Use this for:
/// - settings pages
/// - detail pages
/// - simple secondary pages
///
/// For primary tab pages, prefer:
/// Scaffold + CustomScrollView + AppPageHeader.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool applyPagePadding;
  final bool safeArea;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.bottomNavigationBar,
    this.applyPagePadding = true,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = applyPagePadding
        ? Padding(padding: AppSpacing.pagePadding, child: body)
        : body;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: safeArea ? SafeArea(child: content) : content,
    );
  }
}
