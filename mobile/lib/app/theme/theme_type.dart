import 'package:flutter/material.dart';

enum AppThemeType {
  light('Light', false, Color(0xFF2563EB)),
  dark('Dark', true, Color(0xFF60A5FA)),
  midnight('Midnight AMOLED', true, Color(0xFF60A5FA)),
  ocean('Ocean', true, Color(0xFF38BDF8)),
  forest('Forest', false, Color(0xFF059669)),
  sakura('Sakura', false, Color(0xFFDB2777)),
  amber('Amber', false, Color(0xFFB45309)),
  slate('Slate', true, Color(0xFF94A3B8));

  final String label;
  final bool isDark;
  final Color previewColor;

  const AppThemeType(this.label, this.isDark, this.previewColor);
}

enum AppThemeMode {
  system('System'),
  light('Light'),
  dark('Dark');

  final String label;
  const AppThemeMode(this.label);
}
