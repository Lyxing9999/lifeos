import 'package:flutter/material.dart';

/// Shared motion vocabulary.
///
/// Motion in LifeOS should explain state changes, not decorate them.
/// Keep it short, subtle, and disabled automatically when the OS requests
/// reduced motion.
abstract final class AppMotion {
  static const Duration instant = Duration.zero;

  static const Duration micro = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration emphasized = Duration(milliseconds: 340);
  static const Duration slow = Duration(milliseconds: 460);

  static const Duration listBaseDelay = Duration(milliseconds: 30);
  static const Duration listStaggerDelay = Duration(milliseconds: 34);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeInOutCubic;
  static const Curve fadeCurve = Curves.easeOut;
  static const Curve entranceCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;

  static bool enabled(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return !(media?.disableAnimations ?? false);
  }

  static Duration duration(BuildContext context, Duration value) {
    return enabled(context) ? value : instant;
  }

  static Curve curve(BuildContext context, Curve value) {
    return enabled(context) ? value : Curves.linear;
  }

  static Duration staggerDelay({
    required BuildContext context,
    required int index,
    int maxIndex = 6,
    Duration baseDelay = listBaseDelay,
    Duration stepDelay = listStaggerDelay,
  }) {
    if (!enabled(context)) return instant;

    final safeIndex = index.clamp(0, maxIndex);
    return baseDelay + stepDelay * safeIndex;
  }

  static Animation<double> fadeAnimation(AnimationController controller) {
    return CurvedAnimation(parent: controller, curve: fadeCurve);
  }

  static Animation<Offset> slideUpAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0, 0.035),
  }) {
    return Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: standardCurve));
  }
}
