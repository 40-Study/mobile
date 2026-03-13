import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/data/onboarding_storage.dart';
import 'package:study/data/theme_storage.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/data/auth_storage.dart';

@module
abstract class DIDataModule {
  @lazySingleton
  ThemeStorage get themeStorage =>
      SharedPreferencesThemeStorage(diContainer.get<SharedPreferences>());

  @lazySingleton
  OnboardingStorage get onboardingStorage =>
      SharedPreferencesOnboardingStorage(diContainer.get<SharedPreferences>());

  @lazySingleton
  AuthStorage get authStorage =>
      SharedPreferencesAuthStorage(diContainer.get<SharedPreferences>());
}
