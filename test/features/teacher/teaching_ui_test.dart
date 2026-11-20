import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_grade_columns_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_gradebook_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_attendance_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_screen.dart';

import '../../support/teacher_screen_fixtures.dart';

class _Api extends TeacherFixtureApi {
  final columns = <Map<String, dynamic>>[
    {
      'id': 'a',
      'name': 'Điểm A',
      'grade_type': 'assignment',
      'max_score': 10,
      'weight': 1,
    },
    {
      'id': 'b',
      'name': 'Điểm B',
      'grade_type': 'quiz',
      'max_score': 10,
      'weight': 1,
    },
  ];
  List<String>? reordered;
  String? deleted;
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    if (path.endsWith('/grade-columns')) return Future.value({'data': columns});
    if (path.endsWith('/grades'))
      return Future.value({
        'data': {'columns': columns, 'students': <dynamic>[]},
      });
    if (path.endsWith('/attendances'))
      return Future.value({
        'data': [
          {'student_id': 'student', 'status': 'absent'},
        ],
      });
    return super.get(path, query: query);
  }

  @override
  Future<dynamic> put(String path, {dynamic data}) async {
    if (path.endsWith('/reorder')) {
      reordered = List<String>.from(data['column_ids'] as List);
      final ordered = [
        for (final id in reordered!) columns.singleWhere((c) => c['id'] == id),
      ];
      columns
        ..clear()
        ..addAll(ordered);
      return {'data': true};
    }
    throw StateError('Unexpected write');
  }

  @override
  Future<dynamic> delete(String path, {dynamic data}) async {
    deleted = path;
    columns.removeWhere((c) => path.endsWith('/${c['id']}'));
    return {'data': true};
  }
}

void main() {
  testWidgets('class has direct assignment and grade tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherClassScreen(
          api: _Api(),
          classId: 'teacher-class',
          workplaceLabel: 'Cá nhân',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<TabBar>(find.byType(TabBar)).tabs.length, 5);
    await tester.ensureVisible(find.widgetWithText(Tab, 'Bài tập'));
    await tester.tap(find.widgetWithText(Tab, 'Bài tập'));
    await tester.pumpAndSettle();
    expect(find.text('Tạo bài tập'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'grade columns reorder sends complete ID order and removal resets selection',
    (tester) async {
      final api = _Api();
      await tester.pumpWidget(
        MaterialApp(
          home: TeacherGradebookScreen(
            api: api,
            classId: 'teacher-class',
            canWrite: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Điểm A').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Quản lý cột điểm'));
      await tester.pumpAndSettle();
      expect(find.byType(TeacherGradeColumnsScreen), findsOneWidget);
      await tester.tap(find.byTooltip('Thao tác cột Điểm A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Di chuyển xuống'));
      await tester.pumpAndSettle();
      expect(api.reordered, ['b', 'a']);
      await tester.tap(find.byTooltip('Thao tác cột Điểm A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa cấu hình cột'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
      await tester.pumpAndSettle();
      expect(api.deleted, '/classes/teacher-class/grade-columns/a');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<DropdownButtonFormField<String>>(
              find.byType(DropdownButtonFormField<String>),
            )
            .initialValue,
        isNull,
      );
    },
  );
  testWidgets('bulk present asks before overwriting existing absent status', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherAttendanceScreen(
          api: _Api(),
          classId: 'teacher-class',
          sessionId: 'teacher-session',
          title: 'Lớp toán',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đánh dấu tất cả có mặt'));
    await tester.pumpAndSettle();
    expect(find.text('Ghi đè điểm danh đã chọn?'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chưa lưu'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'teaching schedule switches month and keeps reminders in its own menu',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeacherScheduleScreen(
              api: _Api(),
              organizationId: null,
              workplaceLabel: 'Cá nhân',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tháng'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Tùy chọn lịch dạy'));
      await tester.pumpAndSettle();
      expect(find.text('Nhắc lịch'), findsOneWidget);
    },
  );
}
