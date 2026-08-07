import 'package:study/bloc/theme/app_theme.dart';
import 'package:study/data/theme_storage.dart';

abstract class ThemeRepository {
  Future<void> saveTheme(AppThemeMode mode);

  Future<void> saveHighContrast(bool enabled);

  Future<AppThemeSettings> getTheme();

  Future<bool> getHighContrast();
}

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this.themeStorage);

  final ThemeStorage themeStorage;

  @override
  Future<void> saveTheme(AppThemeMode mode) async {
    await themeStorage.saveTheme(mode);
  }

  @override
  Future<AppThemeSettings> getTheme() async {
    final mode = await themeStorage.getTheme();
    final highContrast = await themeStorage.getHighContrast();
    return AppThemeSettings(mode: mode, highContrast: highContrast);
  }

  @override
  Future<bool> getHighContrast() {
    return themeStorage.getHighContrast();
  }

  @override
  Future<void> saveHighContrast(bool enabled) async {
    await themeStorage.saveHighContrast(enabled);
  }
}
