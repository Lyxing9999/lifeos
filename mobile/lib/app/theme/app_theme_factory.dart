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

    // ── Derived surface roles ─────────────────────────────────────────────
    // Material 3 uses these extensively. Define them explicitly so Ocean,
    // Sakura, Amber etc. don't get unexpected auto-generated tints.
    final surfaceContainerHighest = isDark
        ? Color.lerp(p.surface, Colors.white, 0.08)!
        : Color.lerp(p.surface, Colors.black, 0.06)!;
    final surfaceContainerHigh = isDark
        ? Color.lerp(p.surface, Colors.white, 0.05)!
        : Color.lerp(p.surface, Colors.black, 0.04)!;
    final surfaceContainer = isDark
        ? Color.lerp(p.surface, Colors.white, 0.03)!
        : Color.lerp(p.surface, Colors.black, 0.02)!;
    final onSurfaceVariant = p.textSecondary;
    final outline = p.surfaceVariant;
    // Minimal borders — let spacing and hierarchy do the work
    final outlineVariant = isDark
        ? p.surfaceVariant.withValues(alpha: 0.18)
        : p.surfaceVariant.withValues(alpha: 0.36);

    final colorScheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: Colors.white,
      primaryContainer: p.primary.withValues(alpha: isDark ? 0.25 : 0.12),
      onPrimaryContainer: p.primary,
      secondary: p.secondary,
      onSecondary: Colors.white,
      secondaryContainer: p.secondary.withValues(alpha: isDark ? 0.22 : 0.10),
      onSecondaryContainer: p.secondary,
      error: p.error,
      onError: Colors.white,
      errorContainer: p.error.withValues(alpha: isDark ? 0.22 : 0.10),
      onErrorContainer: p.error,
      surface: p.surface,
      onSurface: p.textPrimary,
      surfaceContainerHighest: surfaceContainerHighest,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainer: surfaceContainer,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: p.textPrimary,
      onInverseSurface: p.surface,
      inversePrimary: p.primary.withValues(alpha: 0.8),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      scaffoldBackgroundColor: p.background,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      // ── Full textTheme — all 13 roles defined with palette colors ─────────
      textTheme: base.textTheme.copyWith(
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
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.25,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
          letterSpacing: -0.1,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: p.textSecondary,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: p.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: p.textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: p.textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: p.textSecondary,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: p.textSecondary,
          letterSpacing: 0.3,
        ),
      ),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: p.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.5,
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: outlineVariant, width: 0.6),
        ),
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: p.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: p.error, width: 1.5),
        ),
        labelStyle: TextStyle(color: p.textSecondary),
        hintStyle: TextStyle(color: p.textSecondary.withValues(alpha: 0.6)),
      ),

      // ── Buttons ───────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: BorderSide(color: outlineVariant, width: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        // Calmer FAB — minimal shadow, slightly smaller, supports content
        backgroundColor: p.primary.withValues(alpha: 0.88),
        foregroundColor: Colors.white,
        elevation: 1, // Minimal shadow
        highlightElevation: 2, // Minimal highlight
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), // Slightly smaller radius
        ),
        sizeConstraints: const BoxConstraints.tightFor(width: 52, height: 52),
      ),

      // ── Navigation bar ────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primary.withValues(alpha: 0.16),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected
                ? p.primary
                : p.textSecondary.withValues(alpha: 0.74),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? p.primary
                : p.textSecondary.withValues(alpha: 0.74),
            letterSpacing: 0,
          );
        }),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? p.surfaceVariant : p.textPrimary,
        contentTextStyle: TextStyle(
          color: isDark ? p.textPrimary : p.surface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        elevation: 4,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.cardLg),
          ),
        ),
        elevation: 0,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceContainerHighest,
        selectedColor: p.primary.withValues(alpha: 0.14),
        side: BorderSide(color: outlineVariant, width: 0.35),
        labelStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        padding: AppSpacing.chipInsets,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
      ),

      // ── Slider ────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: p.primary,
        inactiveTrackColor: surfaceContainerHighest,
        thumbColor: p.primary,
        overlayColor: p.primary.withValues(alpha: 0.12),
        trackHeight: 4,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
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
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
        ),
        elevation: 0,
      ),

      // ── Popup menu ────────────────────────────────────────────────────────
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
    );
  }

  // ── Palettes ───────────────────────────────────────────────────────────────

  static AppThemePalette _palette(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return const AppThemePalette(
          brightness: Brightness.light,
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF8B5CF6),
          background: Color(
            0xFFFCFCFC,
          ), // Even more neutral, cards are main layer
          surface: Colors.white,
          surfaceVariant: Color(0xFFEAEAEA), // Softer, lighter, unified border
          textPrimary: Color(0xFF0F172A),
          textSecondary: Color(0xFF64748B),
          error: Color(0xFFEF4444),
        );

      case AppThemeType.dark:
        return const AppThemePalette(
          brightness: Brightness.dark,
          primary: Color(0xFF60A5FA),
          secondary: Color(0xFFA78BFA),
          background: Color(0xFF0F172A),
          surface: Color(0xFF1E293B),
          surfaceVariant: Color(0xFF28323E), // Even softer, unified border
          textPrimary: Color(0xFFF1F5F9),
          textSecondary: Color(0xFF94A3B8),
          error: Color(0xFFF87171),
        );

      case AppThemeType.midnight:
        return const AppThemePalette(
          brightness: Brightness.dark,
          primary: Color(0xFF60A5FA),
          secondary: Color(0xFFA78BFA),
          background: Colors.black,
          surface: Color(0xFF1A1A1A),
          surfaceVariant: Color(0xFF2A2A2A),
          textPrimary: Colors.white,
          textSecondary: Color(0xFF94A3B8),
          error: Color(0xFFF87171),
        );

      case AppThemeType.ocean:
        return const AppThemePalette(
          brightness: Brightness.dark,
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF7DD3FC),
          background: Color(0xFF082F49),
          surface: Color(0xFF0C4A6E),
          surfaceVariant: Color(0xFF1A6A96),
          textPrimary: Color(0xFFF0F9FF),
          textSecondary: Color(0xFF7DD3FC),
          error: Color(0xFFF87171),
        );

      case AppThemeType.forest:
        return const AppThemePalette(
          brightness: Brightness.light,
          primary: Color(0xFF059669),
          secondary: Color(0xFF10B981),
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
