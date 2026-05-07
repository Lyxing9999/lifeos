import 'package:flutter/material.dart';

/// LifeOS logo widget — use this everywhere the brand mark appears.
///
/// Uses the PNG logo asset to avoid SVG compatibility issues.
class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 32,
    this.color,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? _resolveAccentColor(theme);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.36 : 0.22),
          width: 1,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.10),
                  blurRadius: size * 0.36,
                  offset: Offset(0, size * 0.12),
                ),
              ]
            : null,
      ),
      child: Image.asset(
        'assets/icons/aevum_icon_light.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Color _resolveAccentColor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.primary;
    }

    final primary = theme.colorScheme.primary;
    final luminance = primary.computeLuminance();

    if (luminance > 0.62) {
      return theme.colorScheme.onSurface;
    }

    return primary;
  }
}

/// Horizontal lockup: logo + "LifeOS" wordmark.
class AppLogoLockup extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final Color? color;
  final bool showLogoShadow;

  const AppLogoLockup({
    super.key,
    this.logoSize = 28,
    this.fontSize = 20,
    this.color,
    this.showLogoShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveColor =
        color ??
        (theme.brightness == Brightness.dark
            ? theme.colorScheme.onSurface
            : theme.colorScheme.primary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(
          size: logoSize,
          color: effectiveColor,
          showShadow: showLogoShadow,
        ),
        const SizedBox(width: 8),
        Text(
          'LifeOS',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: effectiveColor,
            letterSpacing: -0.55,
          ),
        ),
      ],
    );
  }
}
