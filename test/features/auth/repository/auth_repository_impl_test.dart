import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/data/daily_goals_storage.dart';
import 'package:study/data/last_accessed_course_storage.dart';
import 'package:study/features/auth/data/auth_api_client.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/repository/auth_repository_impl.dart';

class _Api extends Mock implements AuthApiClient {}

class _AuthStorage extends Mock implements AuthStorage {}

class _Bookmarks extends Mock implements BookmarkStorage {}

class _LastAccessed extends Mock implements LastAccessedCourseStorage {}

class _Goals extends Mock implements DailyGoalsStorage {}

void main() {
  group('AuthRepositoryImpl', () {
    late _Api api;
    late _AuthStorage authStorage;
    late _Bookmarks bookmarks;
    late _LastAccessed lastAccessed;
    late _Goals goals;
    late AuthRepositoryImpl repo;

    setUp(() {
      api = _Api();
      authStorage = _AuthStorage();
      bookmarks = _Bookmarks();
      lastAccessed = _LastAccessed();
      goals = _Goals();
      when(() => authStorage.clearAll()).thenAnswer((_) async {});
      when(() => bookmarks.clear()).thenAnswer((_) async {});
      when(() => lastAccessed.clear()).thenAnswer((_) async {});
      when(() => goals.clear()).thenAnswer((_) async {});
      repo = AuthRepositoryImpl(
        apiClient: api,
        authStorage: authStorage,
        dio: Dio(),
        bookmarkStorage: bookmarks,
        lastAccessedStorage: lastAccessed,
        dailyGoalsStorage: goals,
      );
    });

    test('logout should clear bookmarks, goals and last accessed course even when API fails', () async {
      when(() => api.logout()).thenThrow(DioException(requestOptions: RequestOptions()));

      await expectLater(repo.logout(), throwsA(isA<DioException>()));

      verify(() => authStorage.clearAll()).called(1);
      verify(() => bookmarks.clear()).called(1);
      verify(() => lastAccessed.clear()).called(1);
      verify(() => goals.clear()).called(1);
    });

    test('logoutAll should still clear goals when bookmark clear throws', () async {
      when(() => api.logoutAll()).thenAnswer((_) async => throw Exception('net'));
      when(() => bookmarks.clear()).thenThrow(Exception('io'));

      await expectLater(repo.logoutAll(), throwsException);

      verify(() => goals.clear()).called(1);
      verify(() => lastAccessed.clear()).called(1);
    });

    test('clearSession should keep local user data', () async {
      await repo.clearSession();

      verify(() => authStorage.clearAll()).called(1);
      verifyNever(() => bookmarks.clear());
      verifyNever(() => goals.clear());
    });
  });
}
