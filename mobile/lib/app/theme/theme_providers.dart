import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/shared_prefs_provider.dart';
import 'theme_storage.dart';
import 'theme_type.dart';

class ThemeSettings {
  final AppThemeMode themeMode;
  final AppThemeType themeType;

  const ThemeSettings({required this.themeMode, required this.themeType});

  factory ThemeSettings.initial() {
    return const ThemeSettings(
      themeMode: AppThemeMode.system,
      themeType: AppThemeType.dark,
    );
  }

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

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    final storage = ref.read(themeStorageProvider);

    return ThemeSettings(
      themeMode: _readThemeMode(storage),
      themeType: _readThemeType(storage),
    );
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

  Future<void> resetTheme() async {
    state = ThemeSettings.initial();
    await ref.read(themeStorageProvider).clear();
  }

  AppThemeType _readThemeType(ThemeStorage storage) {
    final stored = storage.readThemeName();

    if (stored == null || stored.trim().isEmpty) {
      return ThemeSettings.initial().themeType;
    }

    return AppThemeType.values.firstWhere(
      (type) => type.name == stored,
      orElse: () => ThemeSettings.initial().themeType,
    );
  }

  AppThemeMode _readThemeMode(ThemeStorage storage) {
    final stored = storage.readThemeMode();

    if (stored == null || stored.trim().isEmpty) {
      return ThemeSettings.initial().themeMode;
    }

    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeSettings.initial().themeMode,
    );
  }
}
