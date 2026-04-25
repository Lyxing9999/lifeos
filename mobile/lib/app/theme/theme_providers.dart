import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/shared_prefs_provider.dart';

import 'theme_storage.dart';
import 'theme_type.dart';

class ThemeSettings {
  final AppThemeMode themeMode;
  final AppThemeType themeType;

  const ThemeSettings({required this.themeMode, required this.themeType});

  ThemeSettings copyWith({AppThemeMode? themeMode, AppThemeType? themeType}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      themeType: themeType ?? this.themeType,
    );
  }
}

final themeStorageProvider = Provider<ThemeStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeStorage(prefs);
});

class ThemeNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    final storage = ref.read(themeStorageProvider);

    final storedType = storage.readThemeName();
    final themeType = storedType != null
        ? AppThemeType.values.firstWhere(
            (t) => t.name == storedType,
            orElse: () => AppThemeType.dark,
          )
        : AppThemeType.dark;

    final storedMode = storage.readThemeMode();
    final themeMode = storedMode != null
        ? AppThemeMode.values.firstWhere(
            (m) => m.name == storedMode,
            orElse: () => AppThemeMode.system,
          )
        : AppThemeMode.system;

    return ThemeSettings(themeMode: themeMode, themeType: themeType);
  }

  Future<void> setThemeType(AppThemeType themeType) async {
    if (state.themeType == themeType) return;
    state = state.copyWith(themeType: themeType);
    await ref.read(themeStorageProvider).saveThemeName(themeType.name);
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    if (state.themeMode == themeMode) return;
    state = state.copyWith(themeMode: themeMode);
    await ref.read(themeStorageProvider).saveThemeMode(themeMode.name);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(
  ThemeNotifier.new,
);
