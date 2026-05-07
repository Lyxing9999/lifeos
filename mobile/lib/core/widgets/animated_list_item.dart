import 'package:flutter/material.dart';

import '../../app/theme/app_motion.dart';

/// Wraps a list item with a staggered fade + slide-up entrance animation.
///
/// Use inside SliverList/ListView:
///
/// AnimatedListItem(
///   index: index,
///   child: MyCard(...),
/// )
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration staggerDelay;
  final Offset beginOffset;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 60),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.beginOffset = const Offset(0, 0.035),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
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

    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero).animate(
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

    final cappedIndex = widget.index.clamp(0, 6);
    final delay = widget.baseDelay + widget.staggerDelay * cappedIndex;

    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.index != widget.index ||
        oldWidget.child.key != widget.child.key) {
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
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
