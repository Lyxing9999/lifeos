import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a widget and detects a left-edge swipe (LTR) gesture.
/// Calls [onSwipeBack] if the user drags right > 50px starting from the left 40px edge zone.
class EdgeSwipeBackWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipeBack;
  const EdgeSwipeBackWrapper({
    super.key,
    required this.child,
    required this.onSwipeBack,
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
        if (details.globalPosition.dx < 40) {
          _dragDelta = 0;
          _gestureActive = true;
        }
      },
      onHorizontalDragUpdate: (details) {
        if (_gestureActive) {
          _dragDelta += details.primaryDelta ?? 0;
        }
      },
      onHorizontalDragEnd: (details) {
        if (_gestureActive && _dragDelta > 50) {
          debugPrint(
            '[EdgeSwipeBackWrapper] Swipe-back detected, triggering onSwipeBack',
          );
          HapticFeedback.mediumImpact();
          widget.onSwipeBack();
        }
        _gestureActive = false;
        _dragDelta = 0;
      },
      onHorizontalDragCancel: () {
        _gestureActive = false;
        _dragDelta = 0;
      },
      child: widget.child,
    );
  }
}
