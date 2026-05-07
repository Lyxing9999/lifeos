import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_theme_palette.dart';
import 'theme_type.dart';

class AppThemeFactory {
  AppThemeFactory._();

  static ThemeData build(AppThemeType type) {
    final p = _palette(type);
    final isDark = p.brightness == Brightness.dark;

    final surfaceContainerHighest = isDark
        ? Color.lerp(p.surface, Colors.white, 0.08)!
        : Color.lerp(p.surface, Colors.black, 0.045)!;

    final surfaceContainerHigh = isDark
        ? Color.lerp(p.surface, Colors.white, 0.05)!
        : Color.lerp(p.surface, Colors.black, 0.028)!;

    final surfaceContainer = isDark
        ? Color.lerp(p.surface, Colors.white, 0.03)!
        : Color.lerp(p.surface, Colors.black, 0.02)!;

    final outlineVariant = isDark
        ? p.surfaceVariant.withValues(alpha: 0.20)
        : p.surfaceVariant.withValues(alpha: 0.34);

    final colorScheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: Colors.white,
      primaryContainer: p.primary.withValues(alpha: isDark ? 0.24 : 0.12),
      onPrimaryContainer: p.primary,
      secondary: p.secondary,
      onSecondary: Colors.white,
      secondaryContainer: p.secondary.withValues(alpha: isDark ? 0.20 : 0.10),
      onSecondaryContainer: p.secondary,
      tertiary: p.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: p.tertiary.withValues(alpha: isDark ? 0.20 : 0.10),
      onTertiaryContainer: p.tertiary,
      error: p.error,
      onError: Colors.white,
      errorContainer: p.error.withValues(alpha: isDark ? 0.20 : 0.10),
      onErrorContainer: p.error,
      surface: p.surface,
      onSurface: p.textPrimary,
      surfaceContainerHighest: surfaceContainerHighest,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainer: surfaceContainer,
      surfaceContainerLow: isDark
          ? Color.lerp(p.surface, Colors.black, 0.08)!
          : Color.lerp(p.surface, Colors.white, 0.28)!,
      surfaceContainerLowest: isDark
          ? Color.lerp(p.surface, Colors.black, 0.16)!
          : Colors.white,
      onSurfaceVariant: p.textSecondary,
      outline: p.surfaceVariant,
      outlineVariant: outlineVariant,
      inverseSurface: p.textPrimary,
      onInverseSurface: p.surface,
      inversePrimary: p.primary.withValues(alpha: 0.82),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      scaffoldBackgroundColor: p.background,
      colorScheme: colorScheme,
      fontFamily: null,
      visualDensity: VisualDensity.standard,
    );

    return base.copyWith(
      textTheme: _textTheme(base, p),
      appBarTheme: _appBarTheme(p),
      cardTheme: _cardTheme(p, outlineVariant),
      inputDecorationTheme: _inputDecorationTheme(
        p,
        surfaceContainerHigh,
        outlineVariant,
      ),
      filledButtonTheme: _filledButtonTheme(p),
      outlinedButtonTheme: _outlinedButtonTheme(p, outlineVariant),
      textButtonTheme: _textButtonTheme(p),
      floatingActionButtonTheme: _fabTheme(p),
      navigationBarTheme: _navigationBarTheme(p),
      snackBarTheme: _snackBarTheme(p, isDark),
      dividerTheme: DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.cardLg),
          ),
        ),
        elevation: 0,
      ),
      chipTheme: _chipTheme(base, p, surfaceContainerHighest, outlineVariant),
      sliderTheme: _sliderTheme(p, surfaceContainerHighest),
      switchTheme: _switchTheme(p, surfaceContainerHighest),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
        ),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.25,
        ),
        contentTextStyle: TextStyle(
          color: p.textSecondary,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: outlineVariant, width: 0.8),
        ),
        elevation: 4,
        textStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: IconThemeData(color: p.textPrimary, size: 22),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        subtitleTextStyle: TextStyle(
          color: p.textSecondary,
          fontSize: 13,
          height: 1.35,
        ),
      ),
    );
  }

  static TextTheme _textTheme(ThemeData base, AppThemePalette p) {
    return base.textTheme.copyWith(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: p.textPrimary,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: p.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: p.textPrimary,
        letterSpacing: -0.8,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: p.textPrimary,
        letterSpacing: -0.65,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: p.textPrimary,
        letterSpacing: -0.55,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: p.textPrimary,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
        letterSpacing: -0.25,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
        letterSpacing: -0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: p.textSecondary,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: p.textPrimary,
        height: 1.52,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: p.textSecondary,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: p.textSecondary,
        height: 1.36,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
        letterSpacing: 0,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: p.textSecondary,
        letterSpacing: 0.1,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: p.textSecondary,
        letterSpacing: 0.24,
      ),
    );
  }

  static AppBarTheme _appBarTheme(AppThemePalette p) {
    return AppBarTheme(
      backgroundColor: p.surface,
      foregroundColor: p.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: p.textPrimary),
      actionsIconTheme: IconThemeData(color: p.textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: p.textPrimary,
        letterSpacing: -0.35,
      ),
    );
  }

  static CardThemeData _cardTheme(AppThemePalette p, Color outlineVariant) {
    return CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: outlineVariant, width: 0.7),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(
    AppThemePalette p,
    Color fill,
    Color outlineVariant,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: outlineVariant, width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: outlineVariant, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: p.primary, width: 1.35),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: p.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(color: p.error, width: 1.35),
      ),
      labelStyle: TextStyle(
        color: p.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: p.textSecondary.withValues(alpha: 0.62),
        fontWeight: FontWeight.w400,
      ),
      errorStyle: TextStyle(color: p.error, fontWeight: FontWeight.w600),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(AppThemePalette p) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: p.primary.withValues(alpha: 0.34),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.62),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.04,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(
    AppThemePalette p,
    Color outlineVariant,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.primary,
        disabledForegroundColor: p.textSecondary.withValues(alpha: 0.46),
        side: BorderSide(color: outlineVariant, width: 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.04,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(AppThemePalette p) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.04,
        ),
      ),
    );
  }

  static FloatingActionButtonThemeData _fabTheme(AppThemePalette p) {
    return FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      focusElevation: 2,
      hoverElevation: 3,
      highlightElevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      sizeConstraints: const BoxConstraints.tightFor(width: 52, height: 52),
      extendedSizeConstraints: const BoxConstraints(minHeight: 52),
      extendedPadding: const EdgeInsets.symmetric(horizontal: 18),
      extendedTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.04,
      ),
    );
  }

  static NavigationBarThemeData _navigationBarTheme(AppThemePalette p) {
    return NavigationBarThemeData(
      backgroundColor: p.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.primary.withValues(alpha: 0.14),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);

        return IconThemeData(
          size: 22,
          color: selected ? p.primary : p.textSecondary.withValues(alpha: 0.74),
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);

        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? p.primary : p.textSecondary.withValues(alpha: 0.74),
          letterSpacing: -0.02,
        );
      }),
    );
  }

  static SnackBarThemeData _snackBarTheme(AppThemePalette p, bool isDark) {
    return SnackBarThemeData(
      backgroundColor: isDark ? p.surfaceVariant : p.textPrimary,
      contentTextStyle: TextStyle(
        color: isDark ? p.textPrimary : p.surface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      elevation: 4,
    );
  }

  static ChipThemeData _chipTheme(
    ThemeData base,
    AppThemePalette p,
    Color surfaceContainerHighest,
    Color outlineVariant,
  ) {
    return base.chipTheme.copyWith(
      backgroundColor: surfaceContainerHighest,
      selectedColor: p.primary.withValues(alpha: 0.14),
      disabledColor: surfaceContainerHighest.withValues(alpha: 0.48),
      side: BorderSide(color: outlineVariant, width: 0.5),
      labelStyle: TextStyle(
        color: p.textPrimary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: TextStyle(
        color: p.primary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      padding: AppSpacing.chipInsets,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
    );
  }

  static SliderThemeData _sliderTheme(
    AppThemePalette p,
    Color surfaceContainerHighest,
  ) {
    return SliderThemeData(
      activeTrackColor: p.primary,
      inactiveTrackColor: surfaceContainerHighest,
      thumbColor: p.primary,
      overlayColor: p.primary.withValues(alpha: 0.12),
      trackHeight: 4,
    );
  }

  static SwitchThemeData _switchTheme(
    AppThemePalette p,
    Color surfaceContainerHighest,
  ) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : p.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? p.primary
            : surfaceContainerHighest,
      ),
    );
  }

  static AppThemePalette _palette(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return const AppThemePalette(
          brightness: Brightness.light,
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF0EA5E9),
          tertiary: Color(0xFF14B8A6),
          background: Color(0xFFF8FAFC),
          surface: Colors.white,
          surfaceVariant: Color(0xFFE2E8F0),
          textPrimary: Color(0xFF0F172A),
          textSecondary: Color(0xFF64748B),
          error: Color(0xFFEF4444),
        );

      case AppThemeType.dark:
        return const AppThemePalette(
          brightness: Brightness.dark,
          primary: Color(0xFF60A5FA),
          secondary: Color(0xFFA78BFA),
          tertiary: Color(0xFF2DD4BF),
          background: Color(0xFF0F172A),
          surface: Color(0xFF1E293B),
          surfaceVariant: Color(0xFF334155),
          textPrimary: Color(0xFFF1F5F9),
          textSecondary: Color(0xFF94A3B8),
          error: Color(0xFFF87171),
        );

      case AppThemeType.midnight:
        return const AppThemePalette(
          brightness: Brightness.dark,
          primary: Color(0xFF60A5FA),
          secondary: Color(0xFFA78BFA),
          tertiary: Color(0xFF2DD4BF),
          background: Colors.black,
          surface: Color(0xFF111827),
          surfaceVariant: Color(0xFF1F2937),
          textPrimary: Colors.white,
          textSecondary: Color(0xFF94A3B8),
          error: Color(0xFFF87171),
        );

      case AppThemeType.ocean:
        return const AppThemePalette(
          brightness: Brightness.dark,
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF7DD3FC),
          tertiary: Color(0xFF2DD4BF),
          background: Color(0xFF082F49),
          surface: Color(0xFF0C4A6E),
          surfaceVariant: Color(0xFF1A6A96),
          textPrimary: Color(0xFFF0F9FF),
          textSecondary: Color(0xFFBAE6FD),
          error: Color(0xFFF87171),
        );

      case AppThemeType.forest:
        return const AppThemePalette(
          brightness: Brightness.light,
          primary: Color(0xFF059669),
          secondary: Color(0xFF10B981),
          tertiary: Color(0xFF2563EB),
          background: Color(0xFFF0FDF4),
          surface: Colors.white,
          surfaceVariant: Color(0xFFD1FAE5),
          textPrimary: Color(0xFF052E26),
          textSecondary: Color(0xFF3F7A68),
          error: Color(0xFFEF4444),
        );

      case AppThemeType.sakura:
        return const AppThemePalette(
          brightness: Brightness.light,
          primary: Color(0xFFDB2777),
          secondary: Color(0xFFEC4899),
          tertiary: Color(0xFF8B5CF6),
          background: Color(0xFFFDF2F8),
          surface: Colors.white,
          surfaceVariant: Color(0xFFFCE7F3),
          textPrimary: Color(0xFF1F1235),
          textSecondary: Color(0xFF6B7280),
          error: Color(0xFFEF4444),
        );

      case AppThemeType.amber:
        return const AppThemePalette(
          brightness: Brightness.light,
          primary: Color(0xFFB45309),
          secondary: Color(0xFFD97706),
          tertiary: Color(0xFF14B8A6),
          background: Color(0xFFFFFBEB),
          surface: Colors.white,
          surfaceVariant: Color(0xFFFEF3C7),
          textPrimary: Color(0xFF1C1007),
          textSecondary: Color(0xFF78350F),
          error: Color(0xFFEF4444),
        );

      case AppThemeType.slate:
        return const AppThemePalette(
          brightness: Brightness.dark,
          primary: Color(0xFF94A3B8),
          secondary: Color(0xFFCBD5E1),
          tertiary: Color(0xFF38BDF8),
          background: Color(0xFF020617),
          surface: Color(0xFF0F172A),
          surfaceVariant: Color(0xFF1E293B),
          textPrimary: Color(0xFFF1F5F9),
          textSecondary: Color(0xFF94A3B8),
          error: Color(0xFFF87171),
        );
    }
  }
}

/// Internal lightweight shape to keep `_cardTheme` readable.
///
/// This avoids tying that method to a concrete palette name in case you later
/// split palette types.
abstract interface class ColorPaletteLike {
  Color get surface;
}
