import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';
import 'app_button.dart';
import 'app_dialog.dart';
import 'app_liquid_surface.dart';

/// Senior-Grade Feedback Utility
/// Orchestrates Haptics, Liquid Toasts, and Glass Confirmations.
abstract final class AppFeedback {
  AppFeedback._();

  /// Primary success toast for non-blocking confirmation.
  /// Matches the "Task Done" toast in your screenshot.
  static void success(
    BuildContext context, {
    required String message,
    String? title,
    VoidCallback? onUndo,
  }) {
    if (!context.mounted) return;
    _playSuccessHaptic();
    _showToast(
      context,
      title: title ?? 'Done',
      message: message,
      icon: AppIcons.success,
      color: AppColors.success,
      isSuccess: true,
      onUndo: onUndo,
    );
  }

  /// Critical error toast with heavy haptic warning.
  static void error(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    if (!context.mounted) return;
    HapticFeedback.heavyImpact();
    _showToast(
      context,
      title: title ?? 'Could not finish',
      message: message,
      icon: AppIcons.error,
      color: AppColors.danger,
      duration: const Duration(milliseconds: 3500),
      isSuccess: false,
    );
  }

  /// Information toast for non-critical status updates.
  static void info(
    BuildContext context, {
    required String message,
    String? title,
  }) {
    if (!context.mounted) return;
    HapticFeedback.selectionClick();
    _showToast(
      context,
      title: title ?? 'Heads up',
      message: message,
      icon: AppIcons.info,
      color: Theme.of(context).colorScheme.primary,
      isSuccess: false,
    );
  }

  /// Celebratory full-screen modal feedback.
  /// Used for major milestones (e.g., Daily Goal Completed).
  static Future<void> successSheet(
    BuildContext context, {
    required String title,
    required String message,
    String actionLabel = 'Continue',
  }) {
    _playSuccessHaptic();

    return AppBottomSheet.show<void>(
      context: context,
      title: title,
      subtitle: message,
      showCloseButton: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SuccessOrb(),
          const SizedBox(height: AppSpacing.xl),
          AppButton.primary(
            label: actionLabel,
            fullWidth: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  /// Modern confirmation gatekeeper.
  /// Routes to the specialized AppDialog implementation.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    if (isDestructive) {
      return AppDialog.destructive(
        context: context,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      );
    }

    return AppDialog.confirm(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    );
  }

  /// Tactical "heartbeat" haptic sequence.
  static void _playSuccessHaptic() {
    HapticFeedback.lightImpact();
    Timer(const Duration(milliseconds: 82), () {
      HapticFeedback.selectionClick();
    });
  }

  /// Internal Toast Logic using ScaffoldMessenger
  static void _showToast(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required bool isSuccess,
    Duration duration = const Duration(milliseconds: 2400),
    VoidCallback? onUndo,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        duration: duration,
        content: _FeedbackToast(
          title: title,
          message: message,
          icon: icon,
          color: color,
          isSuccess: isSuccess,
          onUndo: onUndo,
        ),
      ),
    );
  }
}

class _FeedbackToast extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool isSuccess;
  final VoidCallback? onUndo;

  const _FeedbackToast({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.isSuccess,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppMotion.emphasized,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: AppLiquidSurface(
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        variant: AppLiquidSurfaceVariant.floating,
        accentColor: color,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            _ToastIcon(icon: icon, color: color, isSuccess: isSuccess),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle(
                      context,
                    ).copyWith(letterSpacing: -0.15),
                  ),
                  Text(
                    message,
                    style: AppTextStyles.bodySecondary(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onUndo != null) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  onUndo!();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                child: Text(
                  'UNDO',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToastIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool isSuccess;

  const _ToastIcon({
    required this.icon,
    required this.color,
    this.isSuccess = false,
  });

  @override
  State<_ToastIcon> createState() => _ToastIconState();
}

class _ToastIconState extends State<_ToastIcon> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppMotion.fast,
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: AppMotion.slow,
      vsync: this,
    );

    if (widget.isSuccess) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _pulseController.forward();
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isSuccess)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final value = Curves.easeOutCubic.transform(
                  _pulseController.value,
                );
                return Opacity(
                  opacity: (0.35 * (1 - value)).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.8 + (0.4 * value),
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(
                parent: _scaleController,
                curve: Curves.easeOutBack,
              ),
            ),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.chipBg(context, widget.color),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.borderFor(context, widget.color),
                ),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessOrb extends StatelessWidget {
  const _SuccessOrb();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (0.25 * (1 - scale)).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.8 + (0.5 * scale),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              Transform.scale(scale: 0.9 + (0.1 * scale), child: child),
            ],
          ),
        );
      },
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.successSubtle(context),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowFor(context, AppColors.success),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(AppIcons.success, color: AppColors.success, size: 44),
      ),
    );
  }
}
