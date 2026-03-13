// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:study/data/onboarding_storage.dart' as _i38;
import 'package:study/data/theme_storage.dart' as _i1013;
import 'package:study/di/di_app_module.dart' as _i183;
import 'package:study/di/di_data_module.dart' as _i207;
import 'package:study/di/di_network_module.dart' as _i541;
import 'package:study/di/di_repository_module.dart' as _i169;
import 'package:study/features/auth/data/auth_storage.dart' as _i450;
import 'package:study/repository/onboarding_repository.dart' as _i812;
import 'package:study/repository/theme_repository.dart' as _i354;
import 'package:talker/talker.dart' as _i993;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final networkModule = _$NetworkModule();
    final dIAppModule = _$DIAppModule();
    final dIDataModule = _$DIDataModule();
    final repositoryModule = _$RepositoryModule();
    gh.factory<_i361.Dio>(() => networkModule.provideDio());
    gh.lazySingleton<_i409.GlobalKey<_i409.NavigatorState>>(
      () => dIAppModule.navigatorKey,
    );
    gh.lazySingleton<_i993.Talker>(() => dIAppModule.provideLogger());
    gh.lazySingleton<_i1013.ThemeStorage>(() => dIDataModule.themeStorage);
    gh.lazySingleton<_i38.OnboardingStorage>(
      () => dIDataModule.onboardingStorage,
    );
    gh.lazySingleton<_i450.AuthStorage>(() => dIDataModule.authStorage);
    gh.factory<_i354.ThemeRepository>(
      () => repositoryModule.provideThemeRepository(gh<_i1013.ThemeStorage>()),
    );
    gh.factory<_i812.OnboardingRepository>(
      () => repositoryModule.provideOnboardingRepository(
        gh<_i38.OnboardingStorage>(),
      ),
    );
    return this;
  }
}

class _$NetworkModule extends _i541.NetworkModule {}

class _$DIAppModule extends _i183.DIAppModule {}

class _$DIDataModule extends _i207.DIDataModule {}

class _$RepositoryModule extends _i169.RepositoryModule {}
