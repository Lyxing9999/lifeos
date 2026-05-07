import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  static const _themeTypeKey = 'selected_app_theme';
  static const _themeModeKey = 'selected_theme_mode';

  final SharedPreferences prefs;

  const ThemeStorage(this.prefs);

  String? readThemeName() {
    return prefs.getString(_themeTypeKey);
  }

  Future<void> saveThemeName(String value) {
    return prefs.setString(_themeTypeKey, value);
  }

  String? readThemeMode() {
    return prefs.getString(_themeModeKey);
  }

  Future<void> saveThemeMode(String value) {
    return prefs.setString(_themeModeKey, value);
  }

  Future<void> clear() async {
    await prefs.remove(_themeTypeKey);
    await prefs.remove(_themeModeKey);
  }
}
