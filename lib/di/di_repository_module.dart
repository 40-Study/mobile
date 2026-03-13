import 'package:injectable/injectable.dart';
import 'package:study/data/onboarding_storage.dart';
import 'package:study/data/theme_storage.dart';
import 'package:study/repository/onboarding_repository.dart';
import 'package:study/repository/theme_repository.dart';

@module
abstract class RepositoryModule {
  @factoryMethod
  ThemeRepository provideThemeRepository(ThemeStorage themeStorage) =>
      ThemeRepositoryImpl(themeStorage);

  @factoryMethod
  OnboardingRepository provideOnboardingRepository(
    OnboardingStorage onboardingStorage,
  ) =>
      OnboardingRepositoryImpl(onboardingStorage);
}
