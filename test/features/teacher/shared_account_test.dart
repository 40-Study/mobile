import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/account/presentation/shared_account_content.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/profile/profile_cubit.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/parent/presentation/profile/parent_profile_screen.dart';
import 'package:study/features/parent/presentation/profile/widgets/widgets.dart';
import 'package:study/features/student/presentation/profile/profile_screen.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/profile/teacher_profile_screen.dart';
import 'package:study/features/teacher/presentation/teacher_shell.dart';

import '../../support/screen_fixtures.dart';
import '../../support/teacher_screen_fixtures.dart';

class _NoTeacherRequests extends TeacherApi {
  _NoTeacherRequests() : super(dio: Dio());
  int reads = 0;
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    reads++;
    throw StateError('Account must not request $path');
  }
}

class _FailedWorkplace extends TeacherFixtureWorkplace {
  _FailedWorkplace(super.api);
  @override
  Future<void> initialize() async {
    initialized = true;
    error = 'Không tải được nơi làm việc.';
    notifyListeners();
  }
}

class _ChangeableWorkplace extends TeacherFixtureWorkplace {
  _ChangeableWorkplace(super.api);
  void changeScope() {
    revision++;
    notifyListeners();
  }
}

void main() {
  const teacher = ProfileModel(
    id: 'teacher-profile',
    roleName: 'TEACHER',
    systemRoleId: 'teacher-role',
    displayName: 'Giáo viên',
  );
  const student = ProfileModel(
    id: 'student-profile',
    roleName: 'STUDENT',
    systemRoleId: 'student-role',
    displayName: 'Học sinh',
  );
  setUp(setUpScreenFixtures);
  tearDown(() => GetIt.instance.reset());

  testWidgets('Teacher account reuses common widgets without Teacher APIs', (
    tester,
  ) async {
    when(() => auth.getProfiles()).thenAnswer((_) async => [teacher, student]);
    final api = _NoTeacherRequests();
    await pumpScreenFixture(tester, TeacherProfileScreen(api: api));
    expect(find.byType(SharedAccountContent), findsOneWidget);
    expect(find.byType(ProfileCard), findsOneWidget);
    expect(find.byType(SwitchProfileSection), findsOneWidget);
    expect(find.byType(SettingsSection), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(GeneralSection),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(GeneralSection), findsOneWidget);
    expect(find.text('Thu nhập cá nhân'), findsNothing);
    expect(find.text('Nơi làm việc'), findsNothing);
    expect(find.text('Quản lý con'), findsNothing);
    expect(api.reads, 0);
    expect(tester.takeException(), isNull);
    await disposeScreenFixture(tester);
  });

  testWidgets('common switcher uses existing ProfileCubit and AuthBloc', (
    tester,
  ) async {
    when(() => auth.getProfiles()).thenAnswer((_) async => [teacher, student]);
    when(
      () => auth.switchRole(
        roleId: 'student-role',
        roleType: 'system',
        organizationId: null,
      ),
    ).thenAnswer((_) async => const AuthResponse(activeProfile: student));
    await pumpScreenFixture(tester, const TeacherProfileScreen());
    await tester.tap(find.byType(ProfileSwitcherCard).at(1));
    await tester.pumpAndSettle();
    verify(
      () => auth.switchRole(
        roleId: 'student-role',
        roleType: 'system',
        organizationId: null,
      ),
    ).called(1);
    final context = tester.element(find.byType(SharedAccountContent));
    expect(
      (context.read<AuthBloc>().state as AuthAuthenticated).activeProfile?.id,
      student.id,
    );
    expect(tester.takeException(), isNull);
    await disposeScreenFixture(tester);
  });

  testWidgets(
    'account remains available while workplace initialization fails',
    (tester) async {
      final api = _NoTeacherRequests();
      final workplace = _FailedWorkplace(api);
      await pumpScreenFixture(
        tester,
        TeacherShell(api: api, workplace: workplace),
      );
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileCard), findsOneWidget);
      expect(find.byType(SettingsSection), findsOneWidget);
      expect(api.reads, 0);
      expect(tester.takeException(), isNull);
      await disposeScreenFixture(tester);
      workplace.dispose();
    },
  );

  testWidgets(
    'organization revision retains account provider and account position',
    (tester) async {
      final api = TeacherFixtureApi();
      final workplace = _ChangeableWorkplace(api);
      await pumpScreenFixture(
        tester,
        TeacherShell(api: api, workplace: workplace),
      );
      await tester.tap(find.text('Tài khoản').last);
      await tester.pumpAndSettle();
      final provider = tester
          .element(find.byType(ProfileCard))
          .read<ProfileCubit>();
      clearInteractions(auth);
      workplace.changeScope();
      await tester.pumpAndSettle();
      expect(
        tester.element(find.byType(ProfileCard)).read<ProfileCubit>(),
        same(provider),
      );
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        4,
      );
      verifyNever(() => auth.getProfiles());
      expect(tester.takeException(), isNull);
      await disposeScreenFixture(tester);
      workplace.dispose();
    },
  );

  testWidgets(
    'profile discovery error leaves personal and logout actions reachable',
    (tester) async {
      when(() => auth.getProfiles()).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/auth/me/profiles')),
      );
      await pumpScreenFixture(tester, const TeacherProfileScreen());
      expect(find.text('Thử lại vai trò'), findsOneWidget);
      expect(find.byType(ProfileCard), findsOneWidget);
      expect(find.byType(SettingsSection), findsOneWidget);
      await tester.scrollUntilVisible(find.byType(LogoutTile), 200);
      expect(find.byType(LogoutTile), findsOneWidget);
      expect(tester.takeException(), isNull);
      await disposeScreenFixture(tester);
    },
  );

  for (final parent in [false, true]) {
    testWidgets(
      '${parent ? 'Parent' : 'Student'} preserves role-only account item',
      (tester) async {
        await pumpScreenFixture(
          tester,
          parent ? const ParentProfileScreen() : const ProfileScreen(),
        );
        expect(find.byType(SharedAccountContent), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text(parent ? 'Quản lý con' : 'Portfolio'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(parent ? 'Quản lý con' : 'Portfolio'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await disposeScreenFixture(tester);
      },
    );
  }
}
