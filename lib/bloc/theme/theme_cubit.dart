import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:study/bloc/theme/app_theme.dart';
import 'package:study/index.dart';

/// Theme persistence and mode (light/dark/system).
class ThemeCubit extends Cubit<AppThemeSettings> {
  ThemeCubit(this._repository) : super(const AppThemeSettings());

  final ThemeRepository _repository;

  Future<void> loadTheme() async {
    final savedTheme = await _repository.getTheme();
    emit(savedTheme);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final settings = state.copyWith(mode: mode);
    await _repository.saveTheme(settings.mode);
    emit(settings);
  }

  Future<void> setHighContrast({required bool enabled}) async {
    final settings = state.copyWith(highContrast: enabled);
    await _repository.saveHighContrast(enabled);
    emit(settings);
  }

  ThemeMode get themeMode => state.themeMode;
}
