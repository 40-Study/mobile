import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/features/auth/data/auth_interceptor.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/session_expired_notifier.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/video_upload_controller.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_messages_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions, Stream<Uint8List>?)
  respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) => respond(options, stream);
  @override
  void close({bool force = false}) {}
}

class _UploadApi extends TeacherApi {
  _UploadApi() : super(dio: Dio());
  final calls = <String>[];
  final chunks = <int>[];
  bool mismatch = false;
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    calls.add(path);
    return {
      'data': {
        'upload_id': 'upload',
        'file_name': mismatch ? 'different.mp4' : 'lesson.mp4',
        'file_size': 6,
        'can_resume': true,
        'chunk_size': 3,
        'total_chunks': 2,
        'completed_chunks': [1],
      },
    };
  }

  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    calls.add(path);
    if (path.endsWith('/init'))
      return {
        'data': {'upload_id': 'upload', 'chunk_size': 3, 'total_chunks': 2},
      };
    if (path.endsWith('/presigned-urls'))
      return {
        'data': {
          'urls': [
            {
              'chunk_number': data['chunk_numbers'][0],
              'url':
                  'https://storage.example.test/chunk/${data['chunk_numbers'][0]}',
            },
          ],
        },
      };
    if (path.endsWith('/chunk-complete')) {
      chunks.add(data['chunk_number'] as int);
      return {
        'data': {'success': true},
      };
    }
    return {
      'data': {'upload_id': 'upload', 'status': 'processing', 'success': true},
    };
  }
}

class _ContactsApi extends TeacherApi {
  _ContactsApi() : super(dio: Dio());
  final paths = <String>[];
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    paths.add(path);
    if (path == '/classes/me')
      return {
        'data': {
          'classes': [
            {
              'id': 'org-class',
              'name': 'Lớp tổ chức',
              'organization_id': 'org',
            },
          ],
        },
      };
    if (path == '/classes/org-class/students')
      return {
        'data': {
          'students': [
            {
              'student_id': 'org-student',
              'full_name': 'Học viên trong tổ chức',
            },
          ],
          'total': 1,
        },
      };
    return {
      'data': {'students': <dynamic>[], 'total': 0},
    };
  }
}

void main() {
  testWidgets(
    'organization class students can be selected without owning a course',
    (tester) async {
      final api = _ContactsApi();
      await tester.pumpWidget(
        MaterialApp(home: TeacherContactPickerScreen(api: api)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lớp tổ chức').last);
      await tester.pumpAndSettle();
      expect(find.text('Học viên trong tổ chức'), findsOneWidget);
      expect(api.paths, contains('/classes/org-class/students'));
      expect(api.paths, isNot(contains('/teachers/me/students')));
      expect(tester.takeException(), isNull);
    },
  );
  test('select-org carries bearer while public login does not', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = SharedPreferencesAuthStorage(
      await SharedPreferences.getInstance(),
    );
    await storage.saveTokens(
      accessToken: 'teacher-token',
      refreshToken: 'refresh',
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    final requests = <RequestOptions>[];
    dio.httpClientAdapter = _Adapter((options, stream) async {
      requests.add(options);
      return ResponseBody.fromString(
        '{}',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });
    dio.interceptors.add(
      AuthInterceptor(
        authStorage: storage,
        dio: dio,
        sessionNotifier: SessionExpiredNotifier(),
      ),
    );
    final api = TeacherApi(dio: dio);
    await api.post('/auth/select-org', data: {'organization_id': 'org'});
    await api.post('/auth/login');
    expect(requests.first.path, '/api/auth/select-org');
    expect(requests.first.headers['Authorization'], 'Bearer teacher-token');
    expect(requests.last.headers.containsKey('Authorization'), isFalse);
    dio.close();
  });
  testWidgets(
    'async retry works and parent rebuild does not reload the request',
    (tester) async {
      var calls = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return TeacherAsyncView<String>(
                  load: () async {
                    calls++;
                    if (calls == 1) throw const FormatException('Offline');
                    return 'Đã tải';
                  },
                  builder: (context, value) => Text(value),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('Đã tải'), findsOneWidget);
      expect(calls, 2);
      update(() {});
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(tester.takeException(), isNull);
    },
  );
  for (final resume in [false, true]) {
    test(
      'multipart ${resume ? 'resume skips confirmed chunk' : 'uploads streamed chunks without bearer'}',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'teacher-upload-',
        );
        final file = await File(
          '${directory.path}/lesson.mp4',
        ).writeAsBytes([1, 2, 3, 4, 5, 6]);
        final api = _UploadApi(), storage = Dio();
        final bodies = <List<int>>[];
        storage.httpClientAdapter = _Adapter((options, stream) async {
          expect(
            options.headers.keys.map((e) => e.toLowerCase()),
            isNot(contains('authorization')),
          );
          bodies.add(await stream!.expand((bytes) => bytes).toList());
          return ResponseBody.fromString(
            '',
            200,
            headers: {
              'etag': ['"chunk-etag"'],
            },
          );
        });
        final upload = TeacherVideoUploadController(
          api: api,
          storageClient: storage,
        );
        await upload.upload(
          file: file,
          fileName: 'lesson.mp4',
          resourceId: 'course',
          resumeId: resume ? 'upload' : null,
        );
        expect(upload.error, isNull);
        expect(upload.result?['status'], 'processing');
        expect(upload.progress, 1);
        expect(api.chunks, resume ? [2] : [1, 2]);
        expect(
          bodies,
          resume
              ? [
                  [4, 5, 6],
                ]
              : [
                  [1, 2, 3],
                  [4, 5, 6],
                ],
        );
        upload.dispose();
        await directory.delete(recursive: true);
      },
    );
  }
  test(
    'wrong resume file is rejected before bytes or completion are sent',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'teacher-upload-',
      );
      final file = await File(
        '${directory.path}/lesson.mp4',
      ).writeAsBytes([1, 2, 3, 4, 5, 6]);
      final api = _UploadApi()..mismatch = true;
      final upload = TeacherVideoUploadController(api: api);
      await upload.upload(
        file: file,
        fileName: 'lesson.mp4',
        resourceId: 'course',
        resumeId: 'upload',
      );
      expect(upload.error, isA<FormatException>());
      expect(api.chunks, isEmpty);
      expect(api.calls.any((e) => e.endsWith('/complete')), isFalse);
      upload.dispose();
      await directory.delete(recursive: true);
    },
  );
}
