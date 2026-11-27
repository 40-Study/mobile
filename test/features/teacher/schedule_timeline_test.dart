import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:study/features/auth/data/models/organization_model.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_attendance_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_timeline.dart';
import 'package:study/features/teacher/presentation/teacher_shell.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_expandable_calendar.dart';

import '../../support/screen_fixtures.dart';
import '../../support/teacher_screen_fixtures.dart';

class _ScheduleApi extends TeacherFixtureApi {
  _ScheduleApi(this.entries);
  final List<Map<String, dynamic>> entries;
  final reads = <String>[];
  final attendance = <String, Object>{
    'unmarked': <Object>[],
    'recorded': [
      {'student_id': 'student', 'status': 'present'},
    ],
  };

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    reads.add(path);
    if (path == '/me/timetable')
      return {
        'data': {'entries': entries},
      };
    if (path.endsWith('/attendances')) {
      final id = path.split('/')[2];
      final result = attendance[id];
      if (result == null) throw StateError('Unavailable');
      return {'data': result is Future<Object> ? await result : result};
    }
    if (path.startsWith('/classes/teacher-class/sessions/')) {
      return {
        'data': entries.singleWhere(
          (row) => path.endsWith('/${row['session_id']}'),
        ),
      };
    }
    return super.get(path, query: query);
  }
}

Map<String, dynamic> _row(
  String id,
  DateTime date,
  String start,
  String end, {
  String status = 'scheduled',
}) => {
  'class_id': 'teacher-class',
  'session_id': id,
  'date': teacherDate(date),
  'start_time': start,
  'end_time': end,
  'topic': id,
  'status': status,
};

void main() {
  testWidgets('only a confirmed empty attendance list is orange', (
    tester,
  ) async {
    final now = DateTime(2026, 11, 28, 14);
    final previous = DateTime(2026, 11, 27);
    final api = _ScheduleApi([
      _row('unmarked', previous, '09:00', '09:30'),
      _row('recorded', previous, '10:00', '10:30'),
      _row('failed', previous, '11:00', '11:30'),
      _row('done', previous, '12:00', '12:30', status: 'completed'),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherScheduleScreen(
          api: api,
          organizationId: null,
          workplaceLabel: 'Cá nhân',
          now: () => now,
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (now.weekday == DateTime.monday) {
      await tester.tap(find.byKey(const ValueKey('teacher-calendar-previous')));
      await tester.pumpAndSettle();
    }
    await tester.tap(
      find.descendant(
        of: find.byType(TeacherExpandableCalendar),
        matching: find.text('${previous.day}'),
      ),
    );
    await tester.pumpAndSettle();

    final dots = {
      for (final card in tester.widgetList<TeacherTimelineCard>(
        find.byType(TeacherTimelineCard),
      ))
        card.session.sessionId: card.dot,
    };
    expect(dots, {
      'unmarked': TeacherCalendarDot.unmarked,
      'recorded': TeacherCalendarDot.neutral,
      'failed': TeacherCalendarDot.neutral,
      'done': TeacherCalendarDot.completed,
    });
    expect(
      api.reads.where((path) => path.endsWith('/attendances')),
      hasLength(3),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('next eligible session opens attendance directly', (
    tester,
  ) async {
    final now = DateTime(2026, 11, 28, 14);
    final api = _ScheduleApi([
      _row('unmarked', now, '00:00', '23:59', status: 'in_progress'),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherScheduleScreen(
          api: api,
          organizationId: null,
          workplaceLabel: 'Cá nhân',
          now: () => now,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Điểm danh ngay'));
    await tester.pumpAndSettle();

    expect(find.byType(TeacherAttendanceScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'break labels respect the threshold, overlaps and filtered classes',
    (tester) async {
      final date = DateTime(2026, 11, 28);
      final classData = TeacherClassData({'id': 'teacher-class'});
      TeacherOccurrence occurrence(String name, String start, String end) =>
          TeacherOccurrence(
            json: _row(name, date, start, end),
            date: date,
            classData: classData,
          );
      final first = occurrence('first', '08:00', '09:00');
      final overlap = occurrence('overlap', '08:30', '09:15');
      final after29 = occurrence('after29', '09:44', '10:00');
      final after30 = occurrence('after30', '10:30', '11:00');
      final hidden = occurrence('hidden', '10:10', '10:20');
      final rows = [first, overlap, after29, after30];
      Future<void> show(List<TeacherOccurrence> day) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeacherScheduleTimeline(
              rows: rows,
              daySessions: day,
              dotFor: (_) => TeacherCalendarDot.upcoming,
              buildCard: (session) =>
                  SizedBox(height: 44, child: Text(session.topic)),
            ),
          ),
        ),
      );

      await show(rows);
      expect(find.text('··· Nghỉ 30 phút ···'), findsOneWidget);
      expect(find.textContaining('Nghỉ'), findsOneWidget);
      await show([...rows, hidden]);
      expect(find.textContaining('Nghỉ'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'late attendance from a prior workplace cannot mark the same session ID',
    (tester) async {
      final now = DateTime(2026, 11, 28, 14);
      final entries = [_row('unmarked', now, '09:00', '10:00')];
      final oldResponse = Completer<Object>();
      final api = _ScheduleApi(entries)
        ..attendance['unmarked'] = oldResponse.future;
      final otherApi = _ScheduleApi(entries)
        ..classData['organization_id'] = 'other'
        ..attendance['unmarked'] = [
          {'student_id': 'student'},
        ];
      Widget screen(_ScheduleApi testApi, String? organizationId) =>
          MaterialApp(
            home: TeacherScheduleScreen(
              api: testApi,
              organizationId: organizationId,
              workplaceLabel: organizationId ?? 'Cá nhân',
              now: () => now,
            ),
          );

      await tester.pumpWidget(screen(api, null));
      await tester.pumpAndSettle();
      expect(api.reads, contains('/sessions/unmarked/attendances'));
      await tester.pumpWidget(screen(otherApi, 'other'));
      await tester.pumpAndSettle();
      oldResponse.complete(<Object>[]);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TeacherTimelineCard>(find.byType(TeacherTimelineCard))
            .dot,
        TeacherCalendarDot.neutral,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the hero switches to the next session when time expires', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 28, 13, 59);
    final api = _ScheduleApi([
      _row('active', now, '13:00', '14:00', status: 'in_progress'),
      _row('next', now, '14:30', '15:30'),
    ]);
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherScheduleScreen(
          api: api,
          organizationId: null,
          workplaceLabel: 'Cá nhân',
          now: () => now,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('ĐANG DIỄN RA'), findsOneWidget);

    now = DateTime(2026, 11, 28, 14);
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();
    expect(find.textContaining('ĐANG DIỄN RA'), findsNothing);
    expect(find.textContaining('SẮP BẮT ĐẦU SAU 30 PHÚT'), findsOneWidget);
  });

  group('workspace on a narrow display', () {
    setUp(setUpScreenFixtures);
    tearDown(() => GetIt.instance.reset());

    testWidgets(
      'long names and many organizations fit the switcher and sheet',
      (tester) async {
        final api = TeacherFixtureApi();
        final workplace = TeacherFixtureWorkplace(api);
        const long =
            'Trung tâm 40Study với tên tổ chức rất dài trên màn hình nhỏ';
        workplace.organizations = [
          const OrganizationModel(id: 'long', name: long),
          for (var index = 1; index <= 12; index++)
            OrganizationModel(id: '$index', name: 'Trung tâm $index'),
        ];
        workplace.activeOrg = workplace.organizations.first;
        await pumpScreenFixture(
          tester,
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(2)),
              child: TeacherShell(api: api, workplace: workplace),
            ),
          ),
          size: const Size(320, 640),
        );
        await tester.tap(find.byTooltip('Nơi làm việc: $long'));
        await tester.pumpAndSettle();
        expect(find.text('Nơi làm việc'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'Trung tâm 12');
        await tester.pumpAndSettle();
        expect(find.text('Trung tâm 12'), findsWidgets);
        expect(tester.takeException(), isNull);
        await disposeScreenFixture(tester);
        workplace.dispose();
      },
    );
  });
}
