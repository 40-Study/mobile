import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system;

  ThemeMode toFlutterThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  static AppThemeMode fromIndex(int? value) {
    if (value == null || value < 0 || value >= AppThemeMode.values.length) {
      return AppThemeMode.light;
    }
    return AppThemeMode.values[value];
  }

  static AppThemeMode fromLegacyDarkThemeValue(int? value) {
    switch (value) {
      case 2:
        return AppThemeMode.dark;
      case 3:
        return AppThemeMode.light;
      case 1:
        return AppThemeMode.system;
      default:
        return AppThemeMode.light;
    }
  }
}

class AppThemeSettings extends Equatable {
  const AppThemeSettings({
    this.mode = AppThemeMode.light,
    this.highContrast = false,
  });

  final AppThemeMode mode;
  final bool highContrast;

  ThemeMode get themeMode => mode.toFlutterThemeMode();

  bool get isDarkMode => mode == AppThemeMode.dark;

  AppThemeSettings copyWith({AppThemeMode? mode, bool? highContrast}) {
    return AppThemeSettings(
      mode: mode ?? this.mode,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  @override
  List<Object?> get props => [mode, highContrast];
}
