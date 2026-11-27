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
    await tester.tap(find.text('Tạo buổi học'));
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
    'scope filters by organization and ignores unassigned classes',
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
                    {'class_id': 'unknown'},
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
      final unassigned = await teacherLoadTimetable(
        unknown,
        null,
        DateTime(2026, 10, 14),
        DateTime(2026, 10, 14),
      );
      expect(unassigned, isEmpty);
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
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
                {
                  'student_id': 'one',
                  'full_name': 'Nguyễn Minh Anh',
                  'user_name': 'anh.nguyen1',
                },
                {'student_id': 'two', 'full_name': 'Nguyễn Minh Anh'},
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
                  {'student_id': 'one', 'status': 'excused', 'note': ''},
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
            title: 'Python cơ bản · Demo 1',
            sessionDate: '2026-11-27',
            startTime: '17:00:00',
            endTime: '18:00:00',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Python cơ bản • Demo 1'), findsOneWidget);
      expect(find.text('Thứ 6, 27/11/2026 • 17:00–18:00'), findsOneWidget);
      expect(find.text('Chưa điểm danh'), findsNWidgets(2));
      expect(find.text('Tìm học viên'), findsNothing);
      expect(find.text('Nguyễn Minh Anh'), findsNWidgets(2));
      expect(find.text('anh.nguyen1'), findsOneWidget);
      expect(find.text('Mã học viên two'), findsOneWidget);
      final card = find.byType(Card).first;
      final statusButtons = find.descendant(
        of: card,
        matching: find.byType(FilledButton),
      );
      expect(statusButtons, findsNWidgets(4));
      final firstButton = tester.getRect(statusButtons.first);
      expect(firstButton.height, 32);
      for (var i = 1; i < 4; i++) {
        final button = tester.getRect(statusButtons.at(i));
        expect(button.width, closeTo(firstButton.width, 0.01));
        expect(button.top, firstButton.top);
        expect(button.height, firstButton.height);
      }
      final emptySave = find.widgetWithText(
        FilledButton,
        'Lưu điểm danh (0/2)',
      );
      expect(tester.widget<FilledButton>(emptySave).onPressed, isNull);
      expect(tester.getSize(emptySave).height, 46);
      final markAll = find.widgetWithText(TextButton, 'Đánh dấu cả lớp có mặt');
      expect(
        tester.widget<TextButton>(markAll).style!.backgroundColor!.resolve({}),
        const Color(0xFFEFF6FF),
      );
      final progressBar = find.byType(LinearProgressIndicator);
      expect(tester.getSize(progressBar).height, 4);
      final excused = find.widgetWithText(FilledButton, 'Có phép').first;
      await tester.tap(excused);
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(excused)
            .style!
            .backgroundColor!
            .resolve({}),
        const Color(0xFFDBEAFE),
      );
      expect(tester.widget<LinearProgressIndicator>(progressBar).value, 0.5);
      expect(find.byType(BottomSheet), findsNothing);
      expect(writes, isEmpty);
      final save = find.widgetWithText(FilledButton, 'Lưu điểm danh (1/2)');
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(writes.single['attendances'], [
        {'student_id': 'one', 'status': 'excused', 'note': ''},
      ]);
      expect(find.text('Chưa điểm danh'), findsOneWidget);
      expect(find.text('Đã lưu điểm danh.'), findsOneWidget);
      expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(writes, hasLength(1));
      expect(find.text('Điểm danh đã được lưu.'), findsOneWidget);
      final noteButton = find.byTooltip(
        'Ghi chú điểm danh của Nguyễn Minh Anh',
      );
      await tester.tap(noteButton.first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Nghỉ có báo trước');
      await tester.tap(find.text('Áp dụng'));
      await tester.pumpAndSettle();
      final editNote = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.tooltip == 'Sửa ghi chú điểm danh của Nguyễn Minh Anh',
      );
      final noteStyle = tester.widget<IconButton>(editNote).style!;
      expect(noteStyle.backgroundColor, isNull);
      expect(noteStyle.foregroundColor!.resolve({}), const Color(0xFF986111));
      expect(tester.widget<Text>(find.text('Nghỉ có báo trước')).maxLines, 1);
      await tester.tap(find.widgetWithText(FilledButton, 'Có mặt').last);
      await tester.pumpAndSettle();
      final completeProgress = tester.widget<LinearProgressIndicator>(
        progressBar,
      );
      expect(completeProgress.value, 1);
      expect(completeProgress.color, const Color(0xFF16A34A));
      expect(find.text('Lưu điểm danh (2/2)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('attendance stacks unsaved actions and handles each choice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var writes = 0;
    final api = apiWith((request) async {
      if (request.path == '/api/classes/class') {
        return {
          'data': {'can_manage': true},
        };
      }
      if (request.path.endsWith('/students')) {
        return {
          'data': {
            'students': [
              {'student_id': 'one', 'full_name': 'An'},
            ],
            'total': 1,
          },
        };
      }
      if (request.method != 'GET') writes++;
      return {
        'data': [
          if (writes > 0)
            {'id': 'record', 'student_id': 'one', 'status': 'present'},
        ],
      };
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => TeacherAttendanceScreen(
                    api: api,
                    classId: 'class',
                    sessionId: 'session',
                    title: 'Toán',
                  ),
                ),
              ),
              child: const Text('Mở điểm danh'),
            ),
          ),
        ),
      ),
    );

    final open = find.text('Mở điểm danh');
    final back = find.byType(BackButton);
    final dialog = find.byType(Dialog);
    final save = find.widgetWithText(FilledButton, 'Lưu và quay lại');
    final discard = find.widgetWithText(FilledButton, 'Bỏ thay đổi');
    final stay = find.widgetWithText(TextButton, 'Tiếp tục chỉnh');

    await tester.tap(open);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Có mặt'));
    await tester.pump();
    await tester.tap(back);
    await tester.pumpAndSettle();

    final container = tester.getRect(
      find.descendant(of: dialog, matching: find.byType(SingleChildScrollView)),
    );
    expect(container.left, 28);
    expect(container.right, 332);
    final primary = tester.getRect(save);
    final destructive = tester.getRect(discard);
    final secondary = tester.getRect(stay);
    expect(primary.height, 44);
    expect(destructive.height, 42);
    expect(secondary.height, 38);
    expect(primary.width, container.width - 48);
    expect(destructive.left, primary.left);
    expect(destructive.right, primary.right);
    expect(secondary.left, primary.left);
    expect(secondary.right, primary.right);
    expect(destructive.top - primary.bottom, 8);
    expect(secondary.top - destructive.bottom, 4);

    await tester.tap(stay);
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(find.textContaining('Chưa lưu'), findsOneWidget);
    expect(writes, 0);
    await tester.tap(back);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(open, findsOneWidget);
    expect(writes, 1);

    await tester.tap(open);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Vắng'));
    await tester.pump();
    await tester.tap(back);
    await tester.pumpAndSettle();
    await tester.tap(discard);
    await tester.pumpAndSettle();
    expect(open, findsOneWidget);
    expect(writes, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('attendance searches by account from eight students', (
    tester,
  ) async {
    final api = apiWith((request) async {
      if (request.path.endsWith('/students')) {
        return {
          'data': {
            'students': [
              for (var i = 1; i <= 8; i++)
                {
                  'student_id': '$i',
                  'full_name': 'Học viên $i',
                  'user_name': 'account$i',
                },
            ],
            'total': 8,
          },
        };
      }
      if (request.path == '/api/classes/class') {
        return {
          'data': {'can_manage': true},
        };
      }
      return {'data': <Map<String, dynamic>>[]};
    });
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherAttendanceScreen(
          api: api,
          classId: 'class',
          sessionId: 'session',
          title: 'Toán',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ' ACCOUNT8 ');
    await tester.pumpAndSettle();
    expect(find.text('Học viên 8'), findsOneWidget);
    expect(find.text('Học viên 1'), findsNothing);
  });

  testWidgets(
    'existing attendance uses its record id and reverting a choice clears the draft',
    (tester) async {
      final writes = <String>[];
      var status = 'absent';
      final api = apiWith((request) async {
        if (request.path == '/api/classes/class')
          return {
            'data': {'can_manage': true},
          };
        if (request.path.endsWith('/students'))
          return {
            'data': {
              'students': [
                {'student_id': 'one', 'full_name': 'An'},
              ],
              'total': 1,
            },
          };
        if (request.method != 'GET') {
          writes.add(request.method + ' ' + request.path);
          status = request.data['status'] as String;
        }
        return {
          'data': [
            {'id': 'existing', 'student_id': 'one', 'status': status},
          ],
        };
      });
      await tester.pumpWidget(
        MaterialApp(
          home: TeacherAttendanceScreen(
            api: api,
            classId: 'class',
            sessionId: 'session',
            title: 'Toán',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Có mặt'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Vắng'));
      await tester.pump();
      expect(find.textContaining('Chưa lưu'), findsNothing);
      expect(writes, isEmpty);
      await tester.tap(find.widgetWithText(FilledButton, 'Có mặt'));
      await tester.pump();
      await tester.tap(find.text('Lưu điểm danh (1/1)'));
      await tester.pumpAndSettle();
      expect(writes, ['PUT /api/sessions/session/attendances/existing']);
      expect(find.textContaining('Chưa lưu'), findsNothing);
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
    final absent = find.widgetWithText(FilledButton, 'Vắng');
    await tester.tap(absent);
    await tester.pump();
    await tester.tap(find.text('Lưu điểm danh (1/1)'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<FilledButton>(absent).style!.backgroundColor!.resolve({}),
      const Color(0xFFFEE2E2),
    );
    expect(find.textContaining('Chưa xác nhận lưu được'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
