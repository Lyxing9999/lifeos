import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Shared empty state widget.
///
/// Use for:
/// - empty lists
/// - empty dashboards
/// - no search results
/// - no content for current filter
class AppEmptyView extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final bool centered;

  const AppEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.actionIcon = AppIcons.add,
    this.onAction,
    this.centered = true,
  });

  @override
  State<AppEmptyView> createState() => _AppEmptyViewState();
}

class _AppEmptyViewState extends State<AppEmptyView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _started = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.emphasized,
    );

    _fade = CurvedAnimation(parent: _controller, curve: AppMotion.fadeCurve);

    _slide = Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controller, curve: AppMotion.standardCurve),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;

    _controller.duration = AppMotion.duration(context, AppMotion.emphasized);

    if (!AppMotion.enabled(context)) {
      _controller.value = 1;
      return;
    }

    Future.delayed(AppMotion.listBaseDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant AppEmptyView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.title != widget.title ||
        oldWidget.subtitle != widget.subtitle ||
        oldWidget.icon != widget.icon) {
      if (!AppMotion.enabled(context)) {
        _controller.value = 1;
        return;
      }

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _EmptyContent(
          icon: widget.icon,
          title: widget.title,
          subtitle: widget.subtitle,
          actionLabel: widget.actionLabel,
          actionIcon: widget.actionIcon,
          onAction: widget.onAction,
        ),
      ),
    );

    if (widget.centered) {
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

class _EmptyContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;

  const _EmptyContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StateIcon(
            icon: icon,
            color: scheme.primary,
            backgroundColor: scheme.primary.withValues(alpha: 0.09),
            borderColor: scheme.primary.withValues(alpha: 0.12),
          ),
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
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              label: actionLabel!,
              icon: actionIcon,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;

  const _StateIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Icon(icon, size: 32, color: color.withValues(alpha: 0.82)),
    );
  }
}
