import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';

class AppButton {
  AppButton._();

  static Widget primary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return _AppButtonWidget(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
      variant: _AppButtonVariant.primary,
    );
  }

  static Widget secondary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return _AppButtonWidget(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
      variant: _AppButtonVariant.secondary,
    );
  }

  static Widget destructive({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return _AppButtonWidget(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
      variant: _AppButtonVariant.destructive,
    );
  }

  static Widget ghost({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
  }) {
    return _AppButtonWidget(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      fullWidth: fullWidth,
      variant: _AppButtonVariant.ghost,
    );
  }
}

enum _AppButtonVariant { primary, secondary, destructive, ghost }

class _AppButtonWidget extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;
  final _AppButtonVariant variant;

  const _AppButtonWidget({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.icon,
    required this.fullWidth,
    required this.variant,
  });

  @override
  State<_AppButtonWidget> createState() => _AppButtonWidgetState();
}

class _AppButtonWidgetState extends State<_AppButtonWidget> {
  bool _pressed = false;

  bool get _disabled {
    return widget.onPressed == null || widget.isLoading;
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(context);
    final radius = BorderRadius.circular(AppRadius.full);

    final button = Semantics(
      button: true,
      enabled: !_disabled,
      label: widget.label,
      child: AnimatedScale(
        duration: AppMotion.duration(context, AppMotion.micro),
        curve: AppMotion.standardCurve,
        scale: _pressed && !_disabled ? 0.985 : 1,
        child: AnimatedContainer(
          duration: AppMotion.duration(context, AppMotion.fast),
          curve: AppMotion.standardCurve,
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: radius,
            border: style.borderWidth <= 0
                ? null
                : Border.all(
                    color: style.borderColor,
                    width: style.borderWidth,
                  ),
            boxShadow: style.shadows,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: _disabled
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      widget.onPressed?.call();
                    },
              onHighlightChanged: (value) {
                if (_pressed == value) return;
                setState(() => _pressed = value);
              },
              splashColor: style.foregroundColor.withValues(alpha: 0.08),
              highlightColor: style.foregroundColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: _ButtonContent(
                  label: widget.isLoading ? 'Saving…' : widget.label,
                  icon: widget.icon,
                  isLoading: widget.isLoading,
                  color: style.foregroundColor,
                  fullWidth: widget.fullWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.fullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }

  _ResolvedButtonStyle _resolveStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.variant) {
      case _AppButtonVariant.primary:
        return _ResolvedButtonStyle(
          backgroundColor: scheme.primary.withValues(
            alpha: _disabled ? 0.34 : 0.92,
          ),
          borderColor: scheme.primary.withValues(alpha: _disabled ? 0 : 0.28),
          foregroundColor: scheme.onPrimary.withValues(
            alpha: _disabled ? 0.62 : 1,
          ),
          borderWidth: 0.8,
          shadows: _disabled
              ? AppShadows.none
              : [
                  BoxShadow(
                    color: scheme.primary.withValues(
                      alpha: isDark ? 0.16 : 0.12,
                    ),
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: const Offset(0, 7),
                  ),
                ],
        );

      case _AppButtonVariant.secondary:
        return _ResolvedButtonStyle(
          backgroundColor: AppColors.liquidControl(context),
          borderColor: AppColors.glassBorder(context),
          foregroundColor: scheme.onSurface.withValues(
            alpha: _disabled ? 0.42 : 0.92,
          ),
          borderWidth: 0.8,
          shadows: _disabled ? AppShadows.none : AppShadows.control(isDark),
        );

      case _AppButtonVariant.destructive:
        return _ResolvedButtonStyle(
          backgroundColor: AppColors.danger.withValues(
            alpha: isDark ? 0.16 : 0.10,
          ),
          borderColor: AppColors.danger.withValues(
            alpha: _disabled ? 0.18 : 0.36,
          ),
          foregroundColor: AppColors.danger.withValues(
            alpha: _disabled ? 0.48 : 0.98,
          ),
          borderWidth: 0.9,
          shadows: _disabled
              ? AppShadows.none
              : [
                  BoxShadow(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    blurRadius: 14,
                    spreadRadius: -5,
                    offset: const Offset(0, 6),
                  ),
                ],
        );

      case _AppButtonVariant.ghost:
        return _ResolvedButtonStyle(
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          foregroundColor: scheme.primary.withValues(
            alpha: _disabled ? 0.44 : 0.96,
          ),
          borderWidth: 0,
          shadows: AppShadows.none,
        );
    }
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color color;
  final bool fullWidth;

  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.color,
    required this.fullWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.duration(context, AppMotion.fast),
      switchInCurve: AppMotion.standardCurve,
      switchOutCurve: AppMotion.fadeCurve,
      child: Row(
        key: ValueKey<String>('$label-$isLoading'),
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else if (icon != null)
            Icon(icon, size: 18, color: color),
          if (isLoading || icon != null) const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.05,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolvedButtonStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final double borderWidth;
  final List<BoxShadow> shadows;

  const _ResolvedButtonStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.borderWidth,
    required this.shadows,
  });
}
