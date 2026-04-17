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
import 'package:study/features/auth/data/auth_api_client.dart' as _i384;
import 'package:study/features/auth/data/auth_storage.dart' as _i450;
import 'package:study/features/auth/data/session_expired_notifier.dart'
    as _i785;
import 'package:study/features/auth/repository/auth_repository.dart' as _i584;
import 'package:study/features/organization/data/repository/organization_repository.dart'
    as _i443;
import 'package:study/features/parent/data/parent_api_client.dart' as _i698;
import 'package:study/features/parent/data/repository/parent_repository.dart'
    as _i243;
import 'package:study/features/student/data/repository/student_repository.dart'
    as _i777;
import 'package:study/features/student/data/student_api_client.dart' as _i583;
import 'package:study/features/teacher/data/repository/teacher_repository.dart'
    as _i1041;
import 'package:study/features/teacher/data/teacher_api_client.dart' as _i437;
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
    final repositoryModule = _$RepositoryModule();
    final dIAppModule = _$DIAppModule();
    final dIDataModule = _$DIDataModule();
    final networkModule = _$NetworkModule();
    gh.factory<_i443.OrganizationRepository>(
      () => repositoryModule.provideOrganizationRepository(),
    );
    gh.lazySingleton<_i409.GlobalKey<_i409.NavigatorState>>(
      () => dIAppModule.navigatorKey,
    );
    gh.lazySingleton<_i993.Talker>(() => dIAppModule.provideLogger());
    gh.lazySingleton<_i1013.ThemeStorage>(() => dIDataModule.themeStorage);
    gh.lazySingleton<_i38.OnboardingStorage>(
      () => dIDataModule.onboardingStorage,
    );
    gh.lazySingleton<_i450.AuthStorage>(() => dIDataModule.authStorage);
    gh.lazySingleton<_i785.SessionExpiredNotifier>(
      () => dIDataModule.sessionExpiredNotifier,
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.provideDio());
    gh.factory<_i354.ThemeRepository>(
      () => repositoryModule.provideThemeRepository(gh<_i1013.ThemeStorage>()),
    );
    gh.lazySingleton<_i384.AuthApiClient>(
      () => networkModule.provideAuthApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i437.TeacherApiClient>(
      () => networkModule.provideTeacherApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i583.StudentApiClient>(
      () => networkModule.provideStudentApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i698.ParentApiClient>(
      () => networkModule.provideParentApiClient(gh<_i361.Dio>()),
    );
    gh.factory<_i243.ParentRepository>(
      () =>
          repositoryModule.provideParentRepository(gh<_i698.ParentApiClient>()),
    );
    gh.factory<_i584.AuthRepository>(
      () => repositoryModule.provideAuthRepository(
        gh<_i384.AuthApiClient>(),
        gh<_i450.AuthStorage>(),
      ),
    );
    gh.factory<_i1041.TeacherRepository>(
      () => repositoryModule.provideTeacherRepository(
        gh<_i437.TeacherApiClient>(),
      ),
    );
    gh.factory<_i812.OnboardingRepository>(
      () => repositoryModule.provideOnboardingRepository(
        gh<_i38.OnboardingStorage>(),
      ),
    );
    gh.factory<_i777.StudentRepository>(
      () => repositoryModule.provideStudentRepository(
        gh<_i583.StudentApiClient>(),
      ),
    );
    return this;
  }
}

class _$RepositoryModule extends _i169.RepositoryModule {}

class _$DIAppModule extends _i183.DIAppModule {}

class _$DIDataModule extends _i207.DIDataModule {}

class _$NetworkModule extends _i541.NetworkModule {}
