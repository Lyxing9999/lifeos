import 'package:flutter/material.dart';

import 'app_theme_factory.dart';
import 'theme_type.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return AppThemeFactory.build(AppThemeType.light);
  }

  static ThemeData dark() {
    return AppThemeFactory.build(AppThemeType.dark);
  }

  static ThemeData midnight() {
    return AppThemeFactory.build(AppThemeType.midnight);
  }

  static ThemeData ocean() {
    return AppThemeFactory.build(AppThemeType.ocean);
  }

  static ThemeData forest() {
    return AppThemeFactory.build(AppThemeType.forest);
  }

  static ThemeData sakura() {
    return AppThemeFactory.build(AppThemeType.sakura);
  }

  static ThemeData amber() {
    return AppThemeFactory.build(AppThemeType.amber);
  }

  static ThemeData slate() {
    return AppThemeFactory.build(AppThemeType.slate);
  }

  static ThemeData fromType(AppThemeType type) {
    return AppThemeFactory.build(type);
  }
}
