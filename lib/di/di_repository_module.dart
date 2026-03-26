import 'package:injectable/injectable.dart';
import 'package:study/data/onboarding_storage.dart';
import 'package:study/data/theme_storage.dart';
import 'package:study/features/auth/data/auth_api_client.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/auth/repository/auth_repository_impl.dart';
import 'package:study/features/parent/data/parent_api_client.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';
import 'package:study/features/parent/data/repository/parent_repository_impl.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/data/repository/student_repository_impl.dart';
import 'package:study/features/student/data/student_api_client.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';
import 'package:study/features/teacher/data/repository/teacher_repository_impl.dart';
import 'package:study/features/teacher/data/teacher_api_client.dart';
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
  ) => AuthRepositoryImpl(apiClient: apiClient, authStorage: authStorage);

  @factoryMethod
  TeacherRepository provideTeacherRepository(
    TeacherApiClient apiClient,
  ) => TeacherRepositoryImpl(apiClient: apiClient);

  @factoryMethod
  StudentRepository provideStudentRepository(
    StudentApiClient apiClient,
  ) => StudentRepositoryImpl(apiClient: apiClient);

  @factoryMethod
  ParentRepository provideParentRepository(
    ParentApiClient apiClient,
  ) => ParentRepositoryImpl(apiClient: apiClient);
}
