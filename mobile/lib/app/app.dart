import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme_factory.dart';
import 'theme/theme_providers.dart';
import 'theme/theme_type.dart';

class LifeOsApp extends ConsumerWidget {
  const LifeOsApp({super.key});

  ThemeMode _mapThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeSettings = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: AppThemeFactory.build(themeSettings.themeType),
      darkTheme: AppThemeFactory.build(
        themeSettings.themeType.isDark
            ? themeSettings.themeType
            : AppThemeType.dark,
      ),
      themeMode: _mapThemeMode(themeSettings.themeMode),
      routerConfig: router,
    );
  }
}
