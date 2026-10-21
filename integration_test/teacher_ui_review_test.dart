import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:study/features/teacher/presentation/teacher_shell.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/theme/style.dart';
import 'package:study/theme/util.dart';

import '../test/support/screen_fixtures.dart';
import '../test/support/teacher_screen_fixtures.dart';

/// Native review harness. Uses test API responses, never a live account.
/// Enable with --dart-define=TEACHER_NATIVE_REVIEW=true on a simulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const enabled = bool.fromEnvironment('TEACHER_NATIVE_REVIEW');
  testWidgets('capture Teacher native phone surfaces', (tester) async {
    await setUpScreenFixtures();
    final api = TeacherPreviewApi.enabled
        ? TeacherPreviewApi()
        : TeacherFixtureApi();
    final workplace = TeacherFixtureWorkplace(api);
    final theme = ValueNotifier(false);
    await pumpScreenFixture(
      tester,
      ValueListenableBuilder<bool>(
        valueListenable: theme,
        builder: (context, dark, _) => Theme(
          data: dark
              ? MaterialTheme(createTextTheme(context: context)).dark()
              : MaterialTheme(createTextTheme(context: context)).light(),
          child: TeacherShell(api: api, workplace: workplace),
        ),
      ),
      size: null,
      disableAnimations: false,
    );
    tester
        .element(find.byType(TeacherShell))
        .read<AuthBloc>()
        .emit(
          const AuthAuthenticated(
            user: UserModel(
              id: 'teacher-review',
              email: 'teacher@example.test',
              fullName: 'Nguyễn Thu',
            ),
            activeProfile: ProfileModel(
              id: 'teacher-profile',
              roleName: 'TEACHER',
              displayName: 'Giáo viên',
            ),
          ),
        );
    await tester.pumpAndSettle();
    final udid = Platform.environment['SIMULATOR_UDID'];
    // simctl runs on the host; do not try to execute it from the iOS process.
    // The host reads the marker then captures the currently displayed screen.
    Future<void> hold(String name) async {
      debugPrint('TEACHER_REVIEW_READY:$name');
      await Future<void>.delayed(const Duration(seconds: 8));
    }

    await hold('phone-home-light');
    await tester.tap(find.text('Lịch dạy').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tháng'));
    await tester.pumpAndSettle();
    await hold('phone-schedule-light');
    await tester.tap(find.text('Lớp học').last);
    await tester.pumpAndSettle();
    await hold('phone-classes-light');
    await tester.tap(
      find
          .text(
            TeacherPreviewApi.enabled
                ? 'Python cơ bản · PY26A'
                : 'Toán tư duy · Lớp 6',
          )
          .first,
    );
    await tester.pumpAndSettle();
    await hold('phone-class-light');
    await tester.ensureVisible(find.widgetWithText(Tab, 'Bảng điểm'));
    await tester.tap(find.widgetWithText(Tab, 'Bảng điểm'));
    await tester.pumpAndSettle();
    await hold('phone-grades-light');
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Khóa học').last);
    await tester.pumpAndSettle();
    await hold('phone-courses-light');
    await tester.tap(
      find
          .text(
            TeacherPreviewApi.enabled
                ? 'Python cho người mới bắt đầu'
                : 'Toán tư duy cho học sinh lớp 6',
          )
          .first,
    );
    await tester.pumpAndSettle();
    await hold('phone-course-detail-light');
    await tester.scrollUntilVisible(find.text('Mở giáo trình').first, 250);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mở giáo trình').first);
    await tester.pumpAndSettle();
    await hold('phone-course-outline-light');
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thu nhập cá nhân').first);
    await tester.pumpAndSettle();
    await hold('phone-earnings-light');
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tài khoản').last);
    await tester.pumpAndSettle();
    await hold('phone-account-light');
    theme.value = true;
    await tester.pumpAndSettle();
    await hold('phone-account-dark');
    await tester.tap(find.text('Hôm nay').last);
    await tester.pumpAndSettle();
    await hold('phone-home-dark');
    expect(tester.takeException(), isNull, reason: udid);
    await disposeScreenFixture(tester);
    workplace.dispose();
    theme.dispose();
    await GetIt.instance.reset();
  }, skip: !enabled);
}
