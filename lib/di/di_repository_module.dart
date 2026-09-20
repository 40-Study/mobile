import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/data/last_accessed_course_storage.dart';
import 'package:study/data/onboarding_storage.dart';
import 'package:study/data/theme_storage.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/data/auth_api_client.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/auth/repository/auth_repository_impl.dart';
import 'package:study/features/course/data/course_api_client.dart';
import 'package:study/features/parent/data/parent_api_client.dart';
import 'package:study/features/parent/repository/parent_repository.dart';
// ignore: unused_import
import 'package:study/features/parent/repository/parent_repository_impl.dart';
import 'package:study/features/parent/repository/parent_repository_mock.dart';
import 'package:study/features/student/data/student_api_client.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/features/student/repository/student_repository_impl.dart';
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
  ) => OnboardingRepositoryImpl(onboardingStorage);

  @factoryMethod
  AuthRepository provideAuthRepository(
    AuthApiClient apiClient,
    AuthStorage authStorage,
    Dio dio,
  ) => AuthRepositoryImpl(apiClient: apiClient, authStorage: authStorage, dio: dio);

  @factoryMethod
  StudentApiClient provideStudentApiClient(Dio dio) => StudentApiClient(dio);

  @lazySingleton
  StudentRepository provideStudentRepository(
    StudentApiClient studentApi,
    CourseApiClient courseApi,
    AuthRepository authRepository,
    LastAccessedCourseStorage lastAccessedStorage,
  ) => StudentRepositoryImpl(
        studentApi: studentApi,
        courseApi: courseApi,
        authRepository: authRepository,
        lastAccessedStorage: lastAccessedStorage,
      );

  @lazySingleton
  BookmarkStorage provideBookmarkStorage() =>
      SharedPreferencesBookmarkStorage(diContainer<SharedPreferences>());

  @factoryMethod
  ParentApiClient provideParentApiClient(Dio dio) => ParentApiClient(dio);

  @lazySingleton
  ParentRepository provideParentRepository(ParentApiClient apiClient) =>
      // TODO: Đổi sang ParentRepositoryImpl khi backend có GET /api/parent/children
      ParentRepositoryMock(apiClient);
}
