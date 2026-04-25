import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  static const _themeTypeKey = 'selected_app_theme';
  static const _themeModeKey = 'selected_theme_mode';

  final SharedPreferences prefs;

  ThemeStorage(this.prefs);

  String? readThemeName() => prefs.getString(_themeTypeKey);

  Future<void> saveThemeName(String value) =>
      prefs.setString(_themeTypeKey, value);

  String? readThemeMode() => prefs.getString(_themeModeKey);

  Future<void> saveThemeMode(String value) =>
      prefs.setString(_themeModeKey, value);
}
