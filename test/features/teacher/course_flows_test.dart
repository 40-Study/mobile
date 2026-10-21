import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/teacher/data/course_rules.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/courses/course_detail_screen.dart';
import 'package:study/features/teacher/presentation/courses/course_metadata_editor.dart';
import 'package:study/features/teacher/presentation/courses/course_outline_screen.dart';
import 'package:study/features/teacher/presentation/courses/teacher_courses_screen.dart';
import 'package:study/features/teacher/presentation/courses/lesson_contents_screen.dart';

class _Api extends TeacherApi {
  _Api() : super(dio: Dio());
  final calls = <({String verb, String path, dynamic data})>[];
  String status = 'draft';
  bool emptyLesson = false;
  bool failWrites = false;
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    calls.add((verb: 'GET', path: path, data: query));
    if (path == '/categories') return {'data': <dynamic>[]};
    if (path == '/courses/mine')
      return {
        'data': {
          'courses': [
            {'id': 'course', 'title': 'Khóa riêng', 'status': status},
          ],
          'total': 1,
        },
      };
    if (path == '/courses/course')
      return {
        'data': {
          'id': 'course',
          'title': 'Khóa riêng',
          'status': status,
          'description': 'Mô tả',
          'price': 100000,
          'level': 'beginner',
          'min_video_pct': 80,
          'language': 'vi',
        },
      };
    if (path == '/courses/course/sections/')
      return {
        'data': [
          {
            'id': 'section',
            'title': 'Chương đầu',
            'lessons': [
              {'id': 'lesson', 'title': 'Bài chưa soạn'},
            ],
          },
        ],
      };
    if (path == '/lessons/lesson/contents/')
      return {
        'data': emptyLesson
            ? <dynamic>[]
            : [
                {'id': 'content', 'type': 'article'},
              ],
      };
    return {'data': <dynamic>[]};
  }

  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    calls.add((verb: 'POST', path: path, data: data));
    if (failWrites) throw const FormatException('Máy chủ chưa lưu nội dung');
    if (path.endsWith('withdraw-review')) status = 'draft';
    if (path.endsWith('submit-review')) status = 'pending_review';
    return {
      'data': {'id': 'saved'},
    };
  }

  @override
  Future<dynamic> put(String path, {dynamic data}) async {
    calls.add((verb: 'PUT', path: path, data: data));
    return {
      'data': {'id': 'saved'},
    };
  }
}

void main() {
  test('pricing rejects NaN, negative, zero or excessive discounts', () {
    expect(teacherCoursePriceError('NaN'), isNotNull);
    expect(teacherCoursePriceError('-1'), isNotNull);
    expect(teacherCoursePriceError('0', below: 100), isNotNull);
    expect(teacherCoursePriceError('100', below: 100), isNotNull);
    expect(teacherCoursePriceError('50', below: 100), isNull);
    expect(teacherCoursePriceError('0'), isNull);
  });
  test(
    'pending and archived courses reject writes, reorder uses DTO shape',
    () {
      expect(teacherCourseWritable({'status': 'pending_review'}), isFalse);
      expect(teacherCourseWritable({'status': 'archived'}), isFalse);
      expect(teacherCourseWritable({'status': 'draft'}), isTrue);
      expect(
        teacherCourseReorder([
          {'id': 'b'},
          {'id': 'a'},
        ]),
        {
          'items': [
            {'id': 'b', 'display_order': 0},
            {'id': 'a', 'display_order': 1},
          ],
        },
      );
    },
  );
  testWidgets('uses authenticated own courses route and status filter', (
    tester,
  ) async {
    final api = _Api();
    await tester.pumpWidget(MaterialApp(home: TeacherCoursesScreen(api: api)));
    await tester.pumpAndSettle();
    expect(find.text('Khóa riêng'), findsOneWidget);
    expect(api.calls.first.path, '/courses/mine');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Chờ duyệt'));
    await tester.pumpAndSettle();
    expect((api.calls.last.data as Map)['status'], 'pending_review');
    expect(
      (api.calls.last.data as Map).containsKey('organization_id'),
      isFalse,
    );
  });
  testWidgets('review readiness prevents submission of empty lessons', (
    tester,
  ) async {
    final api = _Api()..emptyLesson = true;
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherCourseDetailScreen(api: api, courseId: 'course'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Kiểm tra và gửi duyệt'), 300);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kiểm tra và gửi duyệt'));
    await tester.pumpAndSettle();
    expect(find.text('Giáo trình chưa sẵn sàng'), findsOneWidget);
    expect(find.textContaining('Bài chưa soạn'), findsOneWidget);
    expect(api.calls.where((c) => c.verb == 'POST'), isEmpty);
  });
  testWidgets(
    'pending review disables information editor but allows withdrawal',
    (tester) async {
      final api = _Api()..status = 'pending_review';
      await tester.pumpWidget(
        MaterialApp(
          home: TeacherCourseDetailScreen(api: api, courseId: 'course'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Thông tin và giá'), 250);
      await tester.pumpAndSettle();
      final tile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Thông tin và giá'),
      );
      expect(tile.onTap, isNull);
      await tester.scrollUntilVisible(find.text('Rút yêu cầu duyệt'), 250);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rút yêu cầu duyệt'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Xác nhận'));
      await tester.pumpAndSettle();
      expect(
        api.calls.any(
          (c) =>
              c.verb == 'POST' && c.path == '/courses/course/withdraw-review',
        ),
        isTrue,
      );
      await tester.scrollUntilVisible(find.text('Nháp'), -300);
      await tester.pumpAndSettle();
      expect(find.text('Nháp'), findsOneWidget);
    },
  );
  testWidgets(
    'clearing discount sends null and preserves personal course scope',
    (tester) async {
      final api = _Api();
      await tester.pumpWidget(
        MaterialApp(
          home: CourseMetadataEditor(
            api: api,
            course: {
              'id': 'course',
              'title': 'Khóa thử',
              'description': 'Mô tả khóa',
              'price': 100000,
              'discount_price': 50000,
              'level': 'beginner',
              'language': 'vi',
              'min_video_pct': 80,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final discount = find.widgetWithText(
        TextFormField,
        'Giá giảm (tùy chọn)',
      );
      await tester.ensureVisible(discount);
      await tester.enterText(discount, '');
      final save = find.widgetWithText(FilledButton, 'Lưu');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      final call = api.calls.singleWhere((c) => c.verb == 'PUT');
      expect(call.path, '/courses/course');
      expect((call.data as Map)['discount_price'], isNull);
      expect((call.data as Map).containsKey('organization_id'), isFalse);
    },
  );
  testWidgets('read-only outline does not expose mutations', (tester) async {
    final api = _Api();
    await tester.pumpWidget(
      MaterialApp(
        home: TeacherCourseOutlineScreen(
          api: api,
          courseId: 'course',
          writable: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chương đầu'), findsNothing);
    expect(find.text('1. Chương đầu'), findsOneWidget);
    expect(find.text('Thêm chương'), findsNothing);
    expect(find.text('Thêm bài vào chương'), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });

  testWidgets(
    'article mutation uses HTML body and failure preserves entered content',
    (tester) async {
      final api = _Api()
        ..emptyLesson = true
        ..failWrites = true;
      await tester.pumpWidget(
        MaterialApp(
          home: TeacherLessonContentsScreen(
            api: api,
            courseId: 'course',
            lessonId: 'lesson',
            title: 'Bài học',
            writable: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Bài đọc'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Tiêu đề nội dung'),
        'Bài đọc mới',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nội dung bài đọc (HTML)'),
        '<p>Nội dung thật</p>',
      );
      final save = find.widgetWithText(FilledButton, 'Lưu');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.text('Máy chủ chưa lưu nội dung'), findsOneWidget);
      expect(find.text('<p>Nội dung thật</p>'), findsOneWidget);
      final call = api.calls.lastWhere((c) => c.verb == 'POST');
      expect(call.path, '/lessons/lesson/contents/');
      expect((call.data as Map)['type'], 'article');
      expect((call.data as Map)['article_body'], '<p>Nội dung thật</p>');
      expect((call.data as Map).containsKey('organization_id'), isFalse);
    },
  );
  testWidgets('editor asks before discarding unsaved text', (tester) async {
    final api = _Api();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseMetadataEditor(api: api),
                ),
              ),
              child: const Text('Mở'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Mở'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tên khóa học'),
      'Bản nháp chưa lưu',
    );
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Bỏ thay đổi?'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.text('Bản nháp chưa lưu'), findsOneWidget);
    expect(api.calls.where((c) => c.verb == 'POST'), isEmpty);
  });
}
