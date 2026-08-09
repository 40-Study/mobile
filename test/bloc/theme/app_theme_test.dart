import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/bloc/theme/app_theme.dart';

void main() {
  group('AppThemeSettings', () {
    test('uses light mode by default', () {
      expect(const AppThemeSettings().themeMode, ThemeMode.light);
    });

    test('falls back to light for an invalid persisted value', () {
      expect(AppThemeMode.fromIndex(null), AppThemeMode.light);
      expect(AppThemeMode.fromIndex(-1), AppThemeMode.light);
    });

    test('uses light when no legacy preference exists', () {
      expect(AppThemeMode.fromLegacyDarkThemeValue(null), AppThemeMode.light);
    });
  });
}
