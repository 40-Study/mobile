// test/features/student/presentation/student_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/learning/learning_screen.dart';
import 'package:study/features/student/presentation/student_shell.dart';
import 'package:study/features/student/repository/student_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStudentRepository extends Mock implements StudentRepository {}

/// StudentShell lấy StudentRepository/AuthRepository từ [diContainer] để tạo
/// các bloc của từng tab, nên test phải đăng ký bản mock rồi dọn lại sau mỗi
/// test.
void _registerRepositories() {
  final studentRepository = _MockStudentRepository();
  final authRepository = _MockAuthRepository();

  when(authRepository.getSavedUser).thenAnswer((_) async => null);

  when(studentRepository.getContinueLearning)
      .thenAnswer((_) async => const Result<EnrollmentModel?, Failure>.success(null));
  when(studentRepository.getTodaySchedule).thenAnswer(
    (_) async => const Result<List<ScheduleItemModel>, Failure>.success([]),
  );
  when(studentRepository.getPendingAssignments).thenAnswer(
    (_) async => const Result<List<AssignmentModel>, Failure>.success([]),
  );
  when(studentRepository.getStats).thenAnswer(
    (_) async => const Result<StudentStatsModel, Failure>.success(
      StudentStatsModel(),
    ),
  );
  when(studentRepository.getBadges).thenAnswer(
    (_) async => const Result<List<BadgeModel>, Failure>.success([]),
  );
  when(studentRepository.getCertificates).thenAnswer(
    (_) async => const Result<List<CertificateModel>, Failure>.success([]),
  );
  when(studentRepository.getActiveEnrollments).thenAnswer(
    (_) async => const Result<List<EnrollmentModel>, Failure>.success([]),
  );
  when(() => studentRepository.getAllCourses()).thenAnswer(
    (_) async => const Result<List<CourseModel>, Failure>.success([]),
  );
  when(() => studentRepository.getEventDates(any())).thenAnswer(
    (_) async => const Result<Set<DateTime>, Failure>.success({}),
  );
  when(() => studentRepository.getScheduleByDate(any())).thenAnswer(
    (_) async => const Result<List<ScheduleItemModel>, Failure>.success([]),
  );

  diContainer
    ..registerSingleton<StudentRepository>(studentRepository)
    ..registerSingleton<AuthRepository>(authRepository);
}

Widget _buildShell({StudentTab initialTab = StudentTab.home}) {
  return BlocProvider<AuthBloc>(
    create: (_) => AuthBloc(_MockAuthRepository()),
    child: MaterialApp(home: StudentShell(initialTab: initialTab)),
  );
}

Future<void> _pumpShell(
  WidgetTester tester, {
  StudentTab initialTab = StudentTab.home,
}) async {
  await tester.pumpWidget(_buildShell(initialTab: initialTab));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(_registerRepositories);

  tearDown(() async {
    await diContainer.reset();
  });

  group('StudentShell', () {
    testWidgets('should display 5 bottom navigation items', (tester) async {
      await _pumpShell(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('should show home tab content when home is selected', (
      tester,
    ) async {
      await _pumpShell(tester);

      expect(find.text('40Study'), findsOneWidget);
      expect(find.text('Trang chủ'), findsOneWidget);
    });

    testWidgets('should switch tab khi tap navigation item', (tester) async {
      await _pumpShell(tester);

      expect(find.text('40Study'), findsOneWidget);

      await tester.tap(find.text('Học tập'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(LearningScreen), findsOneWidget);
      expect(find.text('40Study'), findsNothing);
    });

    testWidgets('should start on given initialTab', (tester) async {
      await _pumpShell(tester, initialTab: StudentTab.schedule);

      expect(find.text('Lịch học'), findsNWidgets(2));
    });

    testWidgets('should have StudentTab enum with 5 values', (tester) async {
      expect(StudentTab.values.length, 5);
      expect(StudentTab.values, contains(StudentTab.home));
      expect(StudentTab.values, contains(StudentTab.learning));
      expect(StudentTab.values, contains(StudentTab.schedule));
      expect(StudentTab.values, contains(StudentTab.achievement));
      expect(StudentTab.values, contains(StudentTab.profile));
    });
  });
}
