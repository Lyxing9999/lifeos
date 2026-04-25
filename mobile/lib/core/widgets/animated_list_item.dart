import 'package:flutter/material.dart';

/// Wraps a list item with a staggered fade + slide-up entrance animation.
///
/// Usage — wrap each item in a SliverList:
///   AnimatedListItem(index: index, child: MyCard(...))
///
/// The [index] drives the stagger delay — item 0 animates first,
/// item 1 slightly after, etc. Capped at index 6 so long lists
/// don't have items waiting forever.
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  /// Base delay before any item starts animating.
  final Duration baseDelay;

  /// Additional delay per index step.
  final Duration staggerDelay;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 60),
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger: cap at index 6 so long lists don't wait
    final cappedIndex = widget.index.clamp(0, 6);
    final delay = widget.baseDelay +
        widget.staggerDelay * cappedIndex;

    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
