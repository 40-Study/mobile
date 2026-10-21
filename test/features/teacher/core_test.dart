import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_attendance_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';

TeacherApi apiWith(Future<dynamic> Function(RequestOptions) respond) {
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
  testWidgets('projected timetable creates a real session before attendance', (
    tester,
  ) async {
    final requests = <String>[];
    final api = apiWith((request) async {
      requests.add('${request.method} ${request.path}');
      if (request.path == '/api/classes/class') {
        return {
          'data': {'id': 'class', 'name': 'Toán', 'can_manage': true},
        };
      }
      return {
        'data': {
          'id': 'created-session',
          'date': '2026-10-14',
          'start_time': '08:00',
          'end_time': '09:00',
          'status': 'scheduled',
        },
      };
    });
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherSessionScreen(
          api: api,
          classId: 'class',
          sessionId: null,
          workplaceLabel: 'Cá nhân',
          occurrence: TeacherOccurrence(
            json: {'start_time': '08:00', 'end_time': '09:00'},
            date: DateTime(2026, 10, 14),
            classData: TeacherClassData({'id': 'class'}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Điểm danh'), findsNothing);
    await tester.tap(find.text('Tạo buổi học để điểm danh'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu lịch'));
    await tester.pumpAndSettle();
    expect(requests, contains('POST /api/classes/class/sessions'));
    expect(
      requests,
      contains('GET /api/classes/class/sessions/created-session'),
    );
    expect(find.text('Điểm danh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('weekly timetable excludes generated and cancelled occurrences', () {
    final rows = teacherOccurrences(
      timetable: {
        'entries': [
          {
            'schedule_id': 'weekly',
            'class_id': 'class',
            'day_of_week': 1,
            'start_time': '08:00',
            'end_time': '09:00',
            'status': 'scheduled',
            'effective_from': '2026-10-01',
            'effective_until': '2026-10-31',
          },
          {
            'session_id': 'session',
            'schedule_id': 'weekly',
            'class_id': 'class',
            'date': '2026-10-05',
            'start_time': '08:00',
            'end_time': '09:00',
            'status': 'scheduled',
          },
        ],
        'cancelled_occurrences': [
          {'schedule_id': 'weekly', 'date': '2026-10-12'},
        ],
      },
      classes: [
        TeacherClassData({'id': 'class', 'name': 'Toán'}),
      ],
      from: DateTime(2026, 10, 1),
      to: DateTime(2026, 10, 31),
    );
    expect(rows.map((row) => teacherDate(row.date)), [
      '2026-10-05',
      '2026-10-19',
      '2026-10-26',
    ]);
    expect(rows.first.sessionId, 'session');
    expect(rows.last.projected, true);
  });

  test(
    'scope filters by organization identity and fails on unknown class',
    () async {
      final api = apiWith(
        (request) async => request.path.endsWith('/classes/me')
            ? {
                'data': {
                  'classes': [
                    {'id': 'personal', 'name': 'Same name'},
                    {
                      'id': 'org',
                      'name': 'Same name',
                      'organization_id': 'unit',
                    },
                  ],
                },
              }
            : {
                'data': {
                  'entries': [
                    {
                      'session_id': 's',
                      'class_id': 'org',
                      'date': '2026-10-14',
                      'start_time': '08:00',
                      'end_time': '09:00',
                    },
                  ],
                },
              },
      );
      final personal = await teacherLoadTimetable(
        api,
        null,
        DateTime(2026, 10, 14),
        DateTime(2026, 10, 14),
      );
      final organization = await teacherLoadTimetable(
        api,
        'unit',
        DateTime(2026, 10, 14),
        DateTime(2026, 10, 14),
      );
      expect(personal, isEmpty);
      expect(organization.single.classId, 'org');
      final unknown = apiWith(
        (request) async => request.path.endsWith('/classes/me')
            ? {
                'data': {'classes': <Map<String, dynamic>>[]},
              }
            : {
                'data': {
                  'entries': [
                    {'class_id': 'unknown'},
                  ],
                },
              },
      );
      await expectLater(
        teacherLoadTimetable(
          unknown,
          null,
          DateTime(2026, 10, 14),
          DateTime(2026, 10, 14),
        ),
        throwsStateError,
      );
    },
  );

  test(
    'roster loader fetches all pages and archived capability is read-only',
    () async {
      final pages = <int>[];
      final api = apiWith((request) async {
        final page = request.queryParameters['page'] as int;
        pages.add(page);
        return {
          'data': {
            'students': page == 1
                ? [
                    {'student_id': 'one'},
                    {'student_id': 'two'},
                  ]
                : [
                    {'student_id': 'three'},
                  ],
            'total': 3,
          },
        };
      });
      final students = await teacherAllPages(
        api,
        '/classes/class/students',
        'students',
      );
      expect(students.length, 3);
      expect(pages, [1, 2]);
      expect(
        TeacherClassData({'can_manage': true, 'status': 'archived'}).canManage,
        false,
      );
      expect(TeacherClassData({'status': 'active'}).canManage, false);
    },
  );

  testWidgets(
    'attendance leaves unmarked students untouched and saves real draft',
    (tester) async {
      final writes = <Map<String, dynamic>>[];
      var saved = false;
      final api = apiWith((request) async {
        if (request.path == '/api/classes/class')
          return {
            'data': {'id': 'class', 'can_manage': true},
          };
        if (request.path.endsWith('/students'))
          return {
            'data': {
              'students': [
                {'student_id': 'one', 'full_name': 'An'},
                {'student_id': 'two', 'full_name': 'Bình'},
              ],
              'total': 2,
            },
          };
        if (request.method == 'POST') {
          writes.add(Map<String, dynamic>.from(request.data as Map));
          saved = true;
        }
        return {
          'data': saved
              ? [
                  {'student_id': 'one', 'status': 'present', 'note': ''},
                ]
              : <Map<String, dynamic>>[],
        };
      });
      await tester.pumpWidget(
        MaterialApp(
          home: TeacherAttendanceScreen(
            api: api,
            classId: 'class',
            sessionId: 'session',
            title: 'Toán · 14/10',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Chưa điểm danh'), findsNWidgets(2));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Có mặt').first);
      await tester.pump();
      await tester.tap(find.text('Lưu điểm danh'));
      await tester.pumpAndSettle();
      expect(writes.single['attendances'], [
        {'student_id': 'one', 'status': 'present', 'note': ''},
      ]);
      expect(find.text('Chưa điểm danh'), findsOneWidget);
      expect(find.text('Đã lưu điểm danh.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed attendance write retains selection at large text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = apiWith((request) async {
      if (request.path == '/api/classes/class')
        return {
          'data': {'can_manage': true},
        };
      if (request.path.endsWith('/students'))
        return {
          'data': {
            'students': [
              {'student_id': 'one', 'full_name': 'Nguyễn Văn An tên dài'},
            ],
            'total': 1,
          },
        };
      if (request.method == 'POST') throw StateError('offline');
      return {'data': <Map<String, dynamic>>[]};
    });
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: TeacherAttendanceScreen(
          api: api,
          classId: 'class',
          sessionId: 'session',
          title: 'Lớp học tên dài',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Vắng'));
    await tester.pump();
    await tester.tap(find.text('Lưu điểm danh'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Vắng'))
          .selected,
      true,
    );
    expect(find.textContaining('Chưa xác nhận lưu được'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
