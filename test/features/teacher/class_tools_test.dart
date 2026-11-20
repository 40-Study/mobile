import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_class_tools_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/tool_form.dart';

class _Api extends TeacherApi {
  _Api({
    required this.assign,
    this.archived = false,
    this.assignedTeacher = false,
  }) : super(dio: Dio());
  final bool assign, archived, assignedTeacher;
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    if (path == '/classes/class')
      return {
        'data': {
          'id': 'class',
          'name': 'Lớp Dart',
          'status': archived ? 'archived' : 'active',
          'can_manage': true,
          'can_assign_teachers': assign,
        },
      };
    if (path == '/classes/me') {
      return {
        'data': {
          'classes': [
            if (assignedTeacher) {'id': 'class'},
          ],
        },
      };
    }
    return {
      'data': {'teachers': <dynamic>[], 'students': <dynamic>[], 'total': 0},
    };
  }
}

void main() {
  testWidgets('class manage does not imply permission to assign teachers', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherClassToolsScreen(
          classId: 'class',
          canManage: true,
          api: _Api(assign: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Giáo viên'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Thêm thành viên'), findsNothing);
  });
  testWidgets(
    'explicit teacher assignment capability shows add member action',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TeacherClassToolsScreen(
            classId: 'class',
            canManage: true,
            api: _Api(assign: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Giáo viên'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Thêm thành viên'), findsOneWidget);
    },
  );
  testWidgets('archived classes suppress student management writes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherClassToolsScreen(
          classId: 'class',
          canManage: true,
          api: _Api(assign: true, archived: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Học viên'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Thêm thành viên'), findsNothing);
  });
  test(
    'unpaginated testcase arrays terminate even at exactly page size',
    () async {
      final api = _PagesApi(paginated: false);
      final rows = await toolPages(api, '/assignments/id/testcases');
      expect(rows.length, 100);
      expect(api.calls, 1);
    },
  );
  test('roster includes later pages instead of truncating students', () async {
    final api = _PagesApi(paginated: true);
    final rows = await toolPages(
      api,
      '/classes/id/students',
      keys: ['students'],
    );
    expect(rows.length, 101);
    expect(api.calls, 2);
  });
  for (final assigned in [false, true]) {
    testWidgets(
      'assignment writes require actual teaching ownership: $assigned',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TeacherClassToolsScreen(
              classId: 'class',
              canManage: true,
              api: _Api(assign: false, assignedTeacher: assigned),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bài tập lập trình'));
        await tester.pumpAndSettle();
        expect(
          find.byTooltip('Tạo bài tập'),
          assigned ? findsOneWidget : findsNothing,
        );
      },
    );
  }
}

class _PagesApi extends TeacherApi {
  _PagesApi({required this.paginated}) : super(dio: Dio());
  final bool paginated;
  int calls = 0;
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    calls++;
    final rows = List.generate(
      calls == 1 ? 100 : 1,
      (i) => {'id': '$calls/$i'},
    );
    if (!paginated) return {'data': rows};
    return {
      'data': {'students': rows, 'total': 101},
    };
  }
}
