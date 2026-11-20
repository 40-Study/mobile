import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_workplace_controller.dart';

class _Storage extends Mock implements AuthStorage {}

class _Repository extends Mock implements AuthRepository {}

TeacherApi _api(Future<dynamic> Function(RequestOptions) respond) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: await respond(options),
              statusCode: 200,
            ),
          );
        } catch (error) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: error,
              type: DioExceptionType.connectionError,
            ),
          );
        }
      },
    ),
  );
  return TeacherApi(dio: dio);
}

void main() {
  setUpAll(() => registerFallbackValue(const AuthResponse()));

  test(
    'late scope response after account leaves does not restore old session',
    () async {
      final storage = _Storage();
      final repository = _Repository();
      final response = Completer<dynamic>();
      when(() => storage.getActiveOrg()).thenAnswer((_) async => null);
      final controller = TeacherWorkplaceController(
        api: _api((request) async {
          if (request.method == 'GET')
            return {
              'data': {
                'organizations': [
                  {
                    'id': 'organization',
                    'name': 'Organization',
                    'status': 'active',
                  },
                ],
                'total': 1,
              },
            };
          return response.future;
        }),
        storage: storage,
        authRepository: repository,
      );
      await controller.initialize();
      final switching = controller.select(controller.organizations.single);
      controller.dispose();
      response.complete({
        'data': {
          'access_token': 'access',
          'refresh_token': 'refresh',
          'active_org': {'id': 'organization', 'name': 'Organization'},
        },
      });
      await switching;
      verifyNever(() => repository.saveSession(any()));
      expect(controller.revision, 0);
    },
  );

  test(
    'loads every membership page with pageSize and excludes inactive membership',
    () async {
      final storage = _Storage();
      when(() => storage.getActiveOrg()).thenAnswer(
        (_) async => const OrganizationModel(id: 'third', name: 'Third'),
      );
      final pages = <int>[];
      final api = _api((request) async {
        expect(request.path, '/api/me/organizations');
        expect(request.queryParameters['pageSize'], 100);
        expect(request.queryParameters.containsKey('page_size'), false);
        final page = request.queryParameters['page'] as int;
        pages.add(page);
        return {
          'data': {
            'organizations': page == 1
                ? [
                    {'id': 'first', 'name': 'First', 'status': 'active'},
                    {
                      'id': 'suspended',
                      'name': 'Suspended',
                      'status': 'inactive',
                    },
                  ]
                : [
                    {'id': 'third', 'name': 'Third', 'status': 'active'},
                  ],
            'total': 3,
          },
        };
      });
      final controller = TeacherWorkplaceController(
        api: api,
        storage: storage,
        authRepository: _Repository(),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(pages, [1, 2]);
      expect(controller.organizations.map((org) => org.id), ['first', 'third']);
      expect(controller.activeOrg?.id, 'third');
      expect(controller.error, isNull);
    },
  );

  test(
    'missing saved membership fails closed and preserves previous scope',
    () async {
      final storage = _Storage();
      when(() => storage.getActiveOrg()).thenAnswer(
        (_) async => const OrganizationModel(
          id: 'removed',
          name: 'Previous organization',
        ),
      );
      final controller = TeacherWorkplaceController(
        api: _api(
          (_) async => {
            'data': {'organizations': <Map<String, dynamic>>[], 'total': 0},
          },
        ),
        storage: storage,
        authRepository: _Repository(),
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      expect(controller.initialized, true);
      expect(controller.error, contains('không còn là thành viên'));
      expect(controller.activeOrg?.id, 'removed');
      expect(controller.revision, 0);
    },
  );

  test(
    'failed token rotation does not save session or switch displayed scope',
    () async {
      final storage = _Storage();
      final repository = _Repository();
      when(() => storage.getActiveOrg()).thenAnswer(
        (_) async => const OrganizationModel(id: 'first', name: 'First'),
      );
      final controller = TeacherWorkplaceController(
        api: _api((request) async {
          if (request.method == 'GET')
            return {
              'data': {
                'organizations': [
                  {'id': 'first', 'name': 'First', 'status': 'active'},
                  {'id': 'second', 'name': 'Second', 'status': 'active'},
                ],
                'total': 2,
              },
            };
          return {
            'data': {
              'active_org': {'id': 'second', 'name': 'Second'},
              'access_token': 'incomplete-session',
            },
          };
        }),
        storage: storage,
        authRepository: repository,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await expectLater(
        controller.select(controller.organizations.last),
        throwsFormatException,
      );
      expect(controller.activeOrg?.id, 'first');
      expect(controller.revision, 0);
      expect(controller.busy, false);
      expect(controller.error, isNotNull);
      verifyNever(() => repository.saveSession(any()));
    },
  );

  test(
    'successful token rotation saves real scope before invalidating views',
    () async {
      final storage = _Storage();
      final repository = _Repository();
      when(() => storage.getActiveOrg()).thenAnswer((_) async => null);
      when(() => storage.getActiveProfile()).thenAnswer(
        (_) async =>
            const ProfileModel(id: 'teacher-profile', roleName: 'TEACHER'),
      );
      when(() => repository.saveSession(any())).thenAnswer((_) async {});
      final controller = TeacherWorkplaceController(
        api: _api((request) async {
          if (request.method == 'GET')
            return {
              'data': {
                'organizations': [
                  {
                    'id': 'organization',
                    'name': 'Organization',
                    'status': 'active',
                  },
                ],
                'total': 1,
              },
            };
          expect((request.data as Map)['organization_id'], 'organization');
          return {
            'data': {
              'active_org': {'id': 'organization', 'name': 'Organization'},
              'access_token': 'access',
              'refresh_token': 'refresh',
            },
          };
        }),
        storage: storage,
        authRepository: repository,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.select(controller.organizations.single);
      final response =
          verify(() => repository.saveSession(captureAny())).captured.single
              as AuthResponse;
      expect(response.activeProfile?.roleName, 'TEACHER');
      expect(response.activeOrg?.id, 'organization');
      expect(controller.activeOrg?.id, 'organization');
      expect(controller.revision, 1);
      expect(controller.busy, false);
      expect(controller.error, isNull);
    },
  );
}
