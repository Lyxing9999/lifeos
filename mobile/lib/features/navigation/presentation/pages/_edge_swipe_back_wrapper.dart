import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EdgeSwipeBackWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeBack;
  final double edgeWidth;
  final double triggerDistance;

  const EdgeSwipeBackWrapper({
    super.key,
    required this.child,
    this.onSwipeBack,
    this.edgeWidth = 24,
    this.triggerDistance = 72,
  });

  @override
  State<EdgeSwipeBackWrapper> createState() => _EdgeSwipeBackWrapperState();
}

class _EdgeSwipeBackWrapperState extends State<EdgeSwipeBackWrapper> {
  double _dragDelta = 0;
  bool _gestureActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (details) {
        final isLeftEdge = details.globalPosition.dx <= widget.edgeWidth;

        if (!isLeftEdge) return;

        _dragDelta = 0;
        _gestureActive = true;
      },
      onHorizontalDragUpdate: (details) {
        if (!_gestureActive) return;

        final delta = details.primaryDelta ?? 0;

        // Only count rightward drag.
        if (delta > 0) {
          _dragDelta += delta;
        }
      },
      onHorizontalDragEnd: (_) {
        if (_gestureActive && _dragDelta >= widget.triggerDistance) {
          HapticFeedback.selectionClick();

          if (widget.onSwipeBack != null) {
            widget.onSwipeBack!.call();
          } else if (Navigator.of(context).canPop()) {
            Navigator.of(context).maybePop();
          }
        }

        _reset();
      },
      onHorizontalDragCancel: _reset,
      child: widget.child,
    );
  }

  void _reset() {
    _gestureActive = false;
    _dragDelta = 0;
  }
}
