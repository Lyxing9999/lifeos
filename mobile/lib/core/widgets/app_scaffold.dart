import 'package:flutter/material.dart';
import '../../app/theme/app_spacing.dart';

/// AppScaffold — for secondary/detail pages that do NOT need scroll-collapsing headers.
/// For all primary tab pages, use raw Scaffold + CustomScrollView + SliverAppBar.large directly.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: body,
        ),
      ),
    );
  }
}
