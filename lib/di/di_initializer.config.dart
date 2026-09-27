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
import 'package:study/data/bookmark_storage.dart' as _i830;
import 'package:study/data/last_accessed_course_storage.dart' as _i340;
import 'package:study/data/onboarding_storage.dart' as _i38;
import 'package:study/data/theme_storage.dart' as _i1013;
import 'package:study/di/di_app_module.dart' as _i183;
import 'package:study/di/di_bloc_module.dart' as _i125;
import 'package:study/di/di_data_module.dart' as _i207;
import 'package:study/di/di_network_module.dart' as _i541;
import 'package:study/di/di_repository_module.dart' as _i169;
import 'package:study/features/auth/data/auth_api_client.dart' as _i384;
import 'package:study/features/auth/data/auth_storage.dart' as _i450;
import 'package:study/features/auth/data/session_expired_notifier.dart'
    as _i785;
import 'package:study/features/auth/repository/auth_repository.dart' as _i584;
import 'package:study/features/course/data/course_api_client.dart' as _i511;
import 'package:study/features/course/repository/course_repository.dart'
    as _i1065;
import 'package:study/features/course/repository/course_repository_impl.dart'
    as _i38;
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart'
    as _i885;
import 'package:study/features/student/bloc/bookmark/bookmark_bloc.dart'
    as _i600;
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart'
    as _i105;
import 'package:study/features/student/bloc/home/home_bloc.dart' as _i144;
import 'package:study/features/student/bloc/learning/learning_bloc.dart'
    as _i264;
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart' as _i729;
import 'package:study/features/student/bloc/notification/notification_bloc.dart'
    as _i185;
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart' as _i938;
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart'
    as _i961;
import 'package:study/features/student/bloc/search/search_bloc.dart' as _i336;
import 'package:study/features/student/data/student_api_client.dart' as _i583;
import 'package:study/features/student/repository/student_repository.dart'
    as _i962;
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
    final dIAppModule = _$DIAppModule();
    final dIDataModule = _$DIDataModule();
    final networkModule = _$NetworkModule();
    final repositoryModule = _$RepositoryModule();
    final blocModule = _$BlocModule();
    gh.lazySingleton<_i409.GlobalKey<_i409.NavigatorState>>(
      () => dIAppModule.navigatorKey,
    );
    gh.lazySingleton<_i993.Talker>(() => dIAppModule.provideLogger());
    gh.lazySingleton<_i1013.ThemeStorage>(() => dIDataModule.themeStorage);
    gh.lazySingleton<_i38.OnboardingStorage>(
      () => dIDataModule.onboardingStorage,
    );
    gh.lazySingleton<_i450.AuthStorage>(() => dIDataModule.authStorage);
    gh.lazySingleton<_i340.LastAccessedCourseStorage>(
      () => dIDataModule.lastAccessedCourseStorage,
    );
    gh.lazySingleton<_i785.SessionExpiredNotifier>(
      () => dIDataModule.sessionExpiredNotifier,
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.provideDio());
    gh.lazySingleton<_i830.BookmarkStorage>(
      () => repositoryModule.provideBookmarkStorage(),
    );
    gh.factory<_i354.ThemeRepository>(
      () => repositoryModule.provideThemeRepository(gh<_i1013.ThemeStorage>()),
    );
    gh.lazySingleton<_i384.AuthApiClient>(
      () => networkModule.provideAuthApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i511.CourseApiClient>(
      () => networkModule.provideCourseApiClient(gh<_i361.Dio>()),
    );
    gh.factory<_i583.StudentApiClient>(
      () => repositoryModule.provideStudentApiClient(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1065.CourseRepository>(
      () => _i38.CourseRepositoryImpl(gh<_i511.CourseApiClient>()),
    );
    gh.factory<_i584.AuthRepository>(
      () => repositoryModule.provideAuthRepository(
        gh<_i384.AuthApiClient>(),
        gh<_i450.AuthStorage>(),
        gh<_i361.Dio>(),
      ),
    );
    gh.lazySingleton<_i962.StudentRepository>(
      () => repositoryModule.provideStudentRepository(
        gh<_i583.StudentApiClient>(),
        gh<_i511.CourseApiClient>(),
        gh<_i584.AuthRepository>(),
        gh<_i340.LastAccessedCourseStorage>(),
      ),
    );
    gh.factory<_i885.AchievementBloc>(
      () => blocModule.achievementBloc(
        gh<_i962.StudentRepository>(),
        gh<_i584.AuthRepository>(),
      ),
    );
    gh.factory<_i812.OnboardingRepository>(
      () => repositoryModule.provideOnboardingRepository(
        gh<_i38.OnboardingStorage>(),
      ),
    );
    gh.factory<_i600.BookmarkBloc>(
      () => blocModule.bookmarkBloc(gh<_i830.BookmarkStorage>()),
    );
    gh.factory<_i144.HomeBloc>(
      () => blocModule.homeBloc(gh<_i962.StudentRepository>()),
    );
    gh.factory<_i264.LearningBloc>(
      () => blocModule.learningBloc(gh<_i962.StudentRepository>()),
    );
    gh.factory<_i961.ScheduleBloc>(
      () => blocModule.scheduleBloc(gh<_i962.StudentRepository>()),
    );
    gh.factory<_i729.LessonBloc>(
      () => blocModule.lessonBloc(gh<_i962.StudentRepository>()),
    );
    gh.factory<_i336.SearchBloc>(
      () => blocModule.searchBloc(gh<_i962.StudentRepository>()),
    );
    gh.factory<_i938.QuizBloc>(
      () => blocModule.quizBloc(gh<_i962.StudentRepository>()),
    );
    gh.factory<_i185.NotificationBloc>(
      () => blocModule.notificationBloc(gh<_i962.StudentRepository>()),
    );
    gh.factory<_i105.CourseDetailBloc>(
      () => blocModule.courseDetailBloc(
        gh<_i962.StudentRepository>(),
        gh<_i1065.CourseRepository>(),
        gh<_i830.BookmarkStorage>(),
      ),
    );
    return this;
  }
}

class _$DIAppModule extends _i183.DIAppModule {}

class _$DIDataModule extends _i207.DIDataModule {}

class _$NetworkModule extends _i541.NetworkModule {}

class _$RepositoryModule extends _i169.RepositoryModule {}

class _$BlocModule extends _i125.BlocModule {}
