import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Aevum logo widget — use this everywhere the brand mark appears.
///
/// Color logic:
/// - If [color] is explicitly provided, use it (e.g. splash screen brand blue)
/// - On dark themes: use white — always readable on dark surfaces
/// - On light themes: use primary — brand color on light surfaces
/// - Exception: if primary is very light (e.g. amber theme), fall back to onSurface
class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? _resolveColor(theme);

    return SvgPicture.asset(
      'assets/icons/aevum_icon.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }

  Color _resolveColor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      // On all dark themes: onInverseSurface is always readable (≈ white)
      return theme.colorScheme.onInverseSurface;
    }
    // On light themes: use primary, but check it's not too light
    final primary = theme.colorScheme.primary;
    final luminance = primary.computeLuminance();
    // If primary is very light (e.g. amber/yellow), use onSurface instead
    if (luminance > 0.6) return theme.colorScheme.onSurface;
    return primary;
  }
}

/// Horizontal lockup: logo + "LifeOS" wordmark side by side.
class AppLogoLockup extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final Color? color;

  const AppLogoLockup({
    super.key,
    this.logoSize = 28,
    this.fontSize = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ??
        (theme.brightness == Brightness.dark
            ? theme.colorScheme.onInverseSurface
            : theme.colorScheme.primary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: logoSize, color: effectiveColor),
        const SizedBox(width: 8),
        Text(
          'LifeOS',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: effectiveColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
