import 'package:injectable/injectable.dart';
import 'package:study/data/onboarding_storage.dart';
import 'package:study/data/theme_storage.dart';
import 'package:study/features/auth/data/auth_api_client.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/auth/repository/auth_repository_impl.dart';
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

  @factoryMethod
  AuthRepository provideAuthRepository(
    AuthApiClient apiClient,
    AuthStorage authStorage,
  ) =>
      AuthRepositoryImpl(
        apiClient: apiClient,
        authStorage: authStorage,
      );
}
