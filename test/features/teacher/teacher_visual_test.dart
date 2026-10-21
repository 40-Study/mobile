import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_gradebook_screen.dart';
import 'package:study/features/teacher/presentation/courses/teacher_courses_screen.dart';
import 'package:study/features/teacher/presentation/earnings/teacher_earnings_screen.dart';
import 'package:study/features/teacher/presentation/teacher_shell.dart';
import 'package:study/features/teacher/presentation/courses/course_detail_screen.dart';
import 'package:study/features/teacher/presentation/courses/course_outline_screen.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_screen.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/student/presentation/student_shell.dart';
import 'package:study/features/parent/presentation/parent_shell.dart';
import 'package:study/theme/style.dart';
import 'package:study/theme/util.dart';

import '../../support/screen_fixtures.dart';
import '../../support/teacher_screen_fixtures.dart';

class _VisualBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

void main() {
  _VisualBinding();
  setUpAll(() async {
    await (FontLoader(
      'Roboto',
    )..addFont(rootBundle.load('google_fonts/Roboto-Medium.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  setUp(setUpScreenFixtures);
  tearDown(() => GetIt.instance.reset());
  if (const bool.fromEnvironment('TEACHER_CAPTURE')) {
    for (final entry in <String, Widget>{
      'student-reference': const StudentShell(),
      'parent-reference': const ParentShell(),
    }.entries) {
      testWidgets('capture ${entry.key} content format', (tester) async {
        await pumpScreenFixture(
          tester,
          RepaintBoundary(
            key: const ValueKey('teacher-capture'),
            child: entry.value,
          ),
          size: const Size(390, 844),
        );
        expect(tester.takeException(), isNull);
        await _capture(tester, entry.key);
        await disposeScreenFixture(tester);
      });
    }
  }
  for (final dark in [false, true]) {
    for (final detail in ['class', 'course', 'outline']) {
      testWidgets(
        '$detail detail full data ${dark ? 'dark' : 'light'} and double text',
        (tester) async {
          final api = TeacherPreviewApi();
          await pumpScreenFixture(
            tester,
            Builder(
              builder: (context) => Theme(
                data: dark
                    ? MaterialTheme(createTextTheme(context: context)).dark()
                    : Theme.of(context),
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: RepaintBoundary(
                    key: const ValueKey('teacher-capture'),
                    child: detail == 'class'
                        ? TeacherClassScreen(
                            api: api,
                            classId: 'python',
                            workplaceLabel: 'Cá nhân',
                          )
                        : detail == 'outline'
                        ? TeacherCourseOutlineScreen(
                            api: api,
                            courseId: 'python',
                            writable: true,
                          )
                        : TeacherCourseDetailScreen(
                            api: api,
                            courseId: 'python',
                          ),
                  ),
                ),
              ),
            ),
            size: const Size(360, 844),
          );
          expect(tester.takeException(), isNull);
          expect(
            find.text(
              detail == 'class'
                  ? 'Python cơ bản · PY26A'
                  : detail == 'outline'
                  ? 'Giáo trình'
                  : 'Python cho người mới bắt đầu',
            ),
            findsWidgets,
          );
          if (const bool.fromEnvironment('TEACHER_CAPTURE'))
            await _capture(tester, '$detail-detail-${dark ? 'dark' : 'light'}');
          await disposeScreenFixture(tester);
        },
      );
    }
  }
  for (final width in [360, 1024]) {
    testWidgets('Teacher populated preview at ${width}px and large text', (
      tester,
    ) async {
      final api = TeacherPreviewApi();
      final workplace = TeacherFixtureWorkplace(api);
      await pumpScreenFixture(
        tester,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(width == 360 ? 1 : 2)),
            child: RepaintBoundary(
              key: const ValueKey('teacher-capture'),
              child: TeacherShell(api: api, workplace: workplace),
            ),
          ),
        ),
        size: Size(width.toDouble(), 1024),
      );
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('TEACHER_CAPTURE'))
        await _capture(tester, 'preview-$width-home');
      await tester.tap(find.text('Khóa học').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Python cho người mới bắt đầu'), findsOneWidget);
      if (const bool.fromEnvironment('TEACHER_CAPTURE'))
        await _capture(tester, 'preview-$width-courses');
      await disposeScreenFixture(tester);
      workplace.dispose();
    });
  }
  for (final width in [360, 1024]) {
    testWidgets('Teacher shell supports ${width}px with double text scale', (
      tester,
    ) async {
      final api = TeacherFixtureApi(),
          workplace = TeacherFixtureWorkplace(TeacherFixtureApi());
      await pumpScreenFixture(
        tester,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: TeacherShell(api: api, workplace: workplace),
          ),
        ),
        size: Size(width.toDouble(), 1024),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Khóa học').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await disposeScreenFixture(tester);
      workplace.dispose();
    });
  }
  for (final width in [360, 390]) {
    for (final dark in [false, true]) {
      testWidgets(
        'Teacher shell ${width}px ${dark ? 'dark' : 'light'} and large text',
        (tester) async {
          final api = TeacherFixtureApi();
          final workplace = TeacherFixtureWorkplace(api);
          await pumpScreenFixture(
            tester,
            Builder(
              builder: (context) => Theme(
                data: dark
                    ? MaterialTheme(createTextTheme(context: context)).dark()
                    : Theme.of(context),
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(dark ? 1.3 : 1)),
                  child: RepaintBoundary(
                    key: const ValueKey('teacher-capture'),
                    child: TeacherShell(api: api, workplace: workplace),
                  ),
                ),
              ),
            ),
            size: Size(width.toDouble(), 844),
          );
          expect(find.text('Hôm nay'), findsWidgets);
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('TEACHER_CAPTURE'))
            await _capture(tester, 'phone-$width-${dark ? 'dark' : 'light'}');
          await disposeScreenFixture(tester);
          workplace.dispose();
        },
      );
    }
  }
  for (final name in ['courses', 'grades', 'earnings']) {
    testWidgets('Teacher $name narrow phone capture', (tester) async {
      final api = TeacherFixtureApi();
      final screen = switch (name) {
        'courses' => TeacherCoursesScreen(api: api),
        'grades' => TeacherGradebookScreen(
          api: api,
          classId: 'teacher-class',
          canWrite: true,
        ),
        _ => TeacherEarningsScreen(api: api),
      };
      await pumpScreenFixture(
        tester,
        RepaintBoundary(key: const ValueKey('teacher-capture'), child: screen),
        size: const Size(360, 800),
      );
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('TEACHER_CAPTURE'))
        await _capture(tester, '$name-phone');
      await disposeScreenFixture(tester);
    });
  }
}

Future<void> _capture(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('teacher-capture')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = await Directory(
      '/tmp/teacher-ui-review',
    ).create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
