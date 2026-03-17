import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:study/bloc/theme/app_theme.dart';
import 'package:study/index.dart';

/// Theme persistence and mode (light/dark/system).
class ThemeCubit extends Cubit<AppThemeSettings> {
  ThemeCubit(this.themeRepository) : super(defaultTheme);

  final ThemeRepository themeRepository;

  static var defaultTheme = AppThemeSettings(
    darkTheme: DarkThemePreference(
      darkThemeValue: DarkThemePreference.followSystem,
    ),
    appTheme: AppTheme.system,
  );

  Future<void> loadTheme() async {
    final savedTheme = await themeRepository.getTheme();
    emit(savedTheme);
  }

  AppThemeSettings get theme => state;

  set setTheme(AppThemeSettings theme) {
    themeRepository.saveTheme(theme.appTheme);
    emit(theme);
  }

  void updateTheme(AppThemeSettings value) => setTheme = value;

  ThemeMode get themeMode {
    switch (state.darkTheme.darkThemeValue) {
      case DarkThemePreference.on:
        return ThemeMode.dark;
      case DarkThemePreference.off:
        return ThemeMode.light;
      case DarkThemePreference.followSystem:
      default:
        return ThemeMode.system;
    }
  }
}
