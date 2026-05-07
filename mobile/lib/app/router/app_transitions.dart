import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// LifeOS route transition system.
///
/// Two transition types:
///
/// [AppTransitions.slide] — Standard iOS-style push.
///   New page slides in from the right, old page slides out to the left.
///   Used for: feature pages pushed from Today (Schedule, Score, Location, etc.)
///   Duration: 320ms, easeOutCubic
///
/// [AppTransitions.modal] — iOS modal sheet style.
///   New page slides up from the bottom with a slight fade.
///   Used for: detail pages, create/edit forms.
///   Duration: 380ms, easeOutCubic
///
/// The shell tab switching animation is handled by StatefulShellRoute
/// internally — no custom transition needed there.
abstract final class AppTransitions {
  static const Duration _slideDuration = Duration(milliseconds: 320);
  static const Duration _modalDuration = Duration(milliseconds: 380);
  static const Curve _curve = Curves.easeOutCubic;

  /// Standard right-to-left push transition.
  /// Use for full feature pages navigated to from Today quick actions.
  static Page<T> slide<T>({
    required LocalKey pageKey,
    required Widget child,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: pageKey,
      name: name,
      child: child,
      transitionDuration: _slideDuration,
      reverseTransitionDuration: _slideDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Incoming: slide from right
        final slideIn = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: _curve));

        // Outgoing: slide slightly left (iOS parallax feel)
        final slideOut = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.25, 0.0),
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: _curve));

        return SlideTransition(
          position: slideOut,
          child: SlideTransition(
            position: slideIn,
            child: child,
          ),
        );
      },
    );
  }

  /// Bottom-to-top modal transition with fade.
  /// Use for detail pages, create forms, and edit forms.
  static Page<T> modal<T>({
    required LocalKey pageKey,
    required Widget child,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: pageKey,
      name: name,
      child: child,
      transitionDuration: _modalDuration,
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Incoming: slide up from bottom + fade in
        final slideIn = Tween<Offset>(
          begin: const Offset(0.0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: _curve));

        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            // Fade completes in the first 60% of the animation
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

        // Outgoing: very subtle scale down (iOS depth effect)
        final scaleOut = Tween<double>(begin: 1.0, end: 0.97).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: _curve),
        );

        return ScaleTransition(
          scale: scaleOut,
          child: FadeTransition(
            opacity: fadeIn,
            child: SlideTransition(
              position: slideIn,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
