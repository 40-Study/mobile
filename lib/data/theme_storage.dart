import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/bloc/theme/app_theme.dart';

abstract class ThemeStorage {
  Future<void> saveTheme(AppThemeMode mode);

  Future<void> saveHighContrast(bool enabled);

  Future<AppThemeMode> getTheme();

  Future<bool> getHighContrast();
}

class SharedPreferencesThemeStorage implements ThemeStorage {
  SharedPreferencesThemeStorage(this.sharedPreferences);

  static const String _themeKey = 'app_theme';
  static const String _darkThemeKey = 'dark_theme';
  static const String _isHighContrastModeEnabledKey =
      'is_high_contrast_mode_enabled';

  final SharedPreferences sharedPreferences;

  @override
  Future<AppThemeMode> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_themeKey)) {
      return AppThemeMode.fromIndex(prefs.getInt(_themeKey));
    }
    return AppThemeMode.fromLegacyDarkThemeValue(prefs.getInt(_darkThemeKey));
  }

  @override
  Future<void> saveTheme(AppThemeMode mode) async {
    await sharedPreferences.setInt(_themeKey, mode.index);
  }

  @override
  Future<void> saveHighContrast(bool enabled) async {
    await sharedPreferences.setBool(_isHighContrastModeEnabledKey, enabled);
  }

  @override
  Future<bool> getHighContrast() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isHighContrastModeEnabledKey) ?? false;
  }
}
