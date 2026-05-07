import 'package:flutter/material.dart';

import '../theme/app_theme_factory.dart';
import '../theme/theme_mode_x.dart';
import '../theme/theme_providers.dart';
import '../theme/theme_type.dart';

class BootstrapMaterialShell extends StatelessWidget {
  final ThemeSettings themeSettings;
  final Widget child;

  const BootstrapMaterialShell({
    super.key,
    required this.themeSettings,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: AppThemeFactory.build(themeSettings.themeType),
      darkTheme: AppThemeFactory.build(
        themeSettings.themeType.isDark
            ? themeSettings.themeType
            : AppThemeType.dark,
      ),
      themeMode: themeSettings.themeMode.materialThemeMode,
      home: child,
    );
  }
}
