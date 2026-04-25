import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// LifeOS shared button system.
/// Refactored to premium glass/stadium modern aesthetic across all buttons.
class AppButton {
  AppButton._();

  static Widget primary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) => _ModernButtonWidget(
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    icon: icon,
    variant: _ButtonVariant.primary,
  );

  static Widget secondary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) => _ModernButtonWidget(
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    icon: icon,
    variant: _ButtonVariant.secondary,
  );

  static Widget destructive({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) => _ModernButtonWidget(
    label: label,
    onPressed: onPressed,
    isLoading: isLoading,
    icon: icon,
    variant: _ButtonVariant.destructive,
  );
}

enum _ButtonVariant { primary, secondary, destructive }

class _ModernButtonWidget extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final _ButtonVariant variant;

  const _ModernButtonWidget({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.icon,
    required this.variant,
  });

  @override
  State<_ModernButtonWidget> createState() => _ModernButtonWidgetState();
}

class _ModernButtonWidgetState extends State<_ModernButtonWidget> {
  bool _isHovered = false;

  Widget _loadingIndicator(Color color) => SizedBox(
    width: 16,
    height: 16,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(color),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    Color bg;
    Color border;
    Color text;
    Color shadow;

    switch (widget.variant) {
      case _ButtonVariant.primary:
        bg = cs.primary.withValues(alpha: isDisabled ? 0.3 : 1.0);
        border = cs.primary.withValues(alpha: isDisabled ? 0 : 0.3);
        text = cs.onPrimary.withValues(alpha: isDisabled ? 0.6 : 1.0);
        shadow = cs.primary.withValues(alpha: isDisabled ? 0 : 0.12);
        break;
      case _ButtonVariant.secondary:
        bg = cs.primary.withValues(
          alpha: isDark
              ? (isDisabled ? 0.05 : 0.12)
              : (isDisabled ? 0.02 : 0.06),
        );
        border = cs.primary.withValues(alpha: isDark ? 0.25 : 0.18);
        text = cs.primary.withValues(
          alpha: isDisabled ? 0.5 : (isDark ? 0.95 : 0.9),
        );
        shadow = cs.primary.withValues(alpha: isDark ? 0.03 : 0.01);
        break;
      case _ButtonVariant.destructive:
        bg = AppColors.danger.withValues(alpha: isDark ? 0.15 : 0.1);
        border = AppColors.danger.withValues(alpha: 0.35);
        text = AppColors.danger.withValues(alpha: isDisabled ? 0.5 : 0.95);
        shadow = AppColors.danger.withValues(alpha: 0.04);
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          _loadingIndicator(text)
        else if (widget.icon != null)
          Icon(widget.icon, size: 18, color: text),
        if (widget.icon != null || widget.isLoading) const SizedBox(width: 8),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
            color: text,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: !isDisabled,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100), // Sleek stadium glass
            border: Border.all(color: border, width: 1),
            boxShadow: [
              if (!isDisabled)
                BoxShadow(
                  color: shadow,
                  blurRadius: _isHovered ? 8 : 6,
                  offset: Offset(0, _isHovered ? 3 : 2),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(100),
              highlightColor: text.withValues(alpha: 0.1),
              splashColor: text.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
