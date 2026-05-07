import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_liquid_surface.dart';

class AppDialog {
  AppDialog._();

  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    IconData icon = AppIcons.info,
    Color? color,
    bool barrierDismissible = true,
  }) async {
    if (!context.mounted) return false;

    HapticFeedback.selectionClick();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) {
        final accent = color ?? Theme.of(context).colorScheme.primary;

        return _AppDialogShell(
          icon: icon,
          color: accent,
          title: title,
          message: message,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          confirmIsDestructive: false,
        );
      },
    );

    return result == true;
  }

  static Future<bool> destructive({
    required BuildContext context,
    required String title,
    required String message,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Delete',
    IconData icon = AppIcons.delete,
    bool barrierDismissible = true,
  }) async {
    if (!context.mounted) return false;

    HapticFeedback.mediumImpact();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.34),
      builder: (context) {
        return _AppDialogShell(
          icon: icon,
          color: AppColors.danger,
          title: title,
          message: message,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          confirmIsDestructive: true,
        );
      },
    );

    return result == true;
  }
}

class _AppDialogShell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final bool confirmIsDestructive;

  const _AppDialogShell({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmIsDestructive,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.sheet);

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: AppMotion.duration(context, AppMotion.slow),
        curve: AppMotion.curve(context, Curves.easeOutBack),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: ((scale - 0.92) / 0.08).clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: AppLiquidSurface(
          borderRadius: radius,
          variant: AppLiquidSurfaceVariant.modal,
          accentColor: color,
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogIcon(icon: icon, color: color),
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                style: AppTextStyles.cardTitle(context).copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.35,
                  height: 1.16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.bodySecondary(
                  context,
                ).copyWith(fontSize: 15, height: 1.46),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              _DialogActions(
                cancelLabel: cancelLabel,
                confirmLabel: confirmLabel,
                confirmIsDestructive: confirmIsDestructive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogActions extends StatefulWidget {
  final String cancelLabel;
  final String confirmLabel;
  final bool confirmIsDestructive;

  const _DialogActions({
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmIsDestructive,
  });

  @override
  State<_DialogActions> createState() => _DialogActionsState();
}

class _DialogActionsState extends State<_DialogActions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: widget.confirmIsDestructive
              ? AppButton.destructive(
                  label: widget.confirmLabel,
                  icon: AppIcons.delete,
                  onPressed: () => Navigator.of(context).pop(true),
                )
              : AppButton.primary(
                  label: widget.confirmLabel,
                  icon: AppIcons.check,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: AppButton.secondary(
            label: widget.cancelLabel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
      ],
    );
  }
}

class _DialogIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _DialogIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1),
      duration: AppMotion.duration(context, AppMotion.slow),
      curve: AppMotion.curve(context, Curves.easeOutBack),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: isDark ? 0.14 : 0.09),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.22 : 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.08 : 0.06),
              blurRadius: 28,
              spreadRadius: -8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Icon(icon, size: 32, color: color),
      ),
    );
  }
}
