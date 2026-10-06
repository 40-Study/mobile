// test/features/student/presentation/student_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/presentation/student_shell.dart';
import 'package:study/features/student/presentation/learning/learning_screen.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/features/student/repository/student_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockStudentRepository extends Mock implements StudentRepository {}

void _stubMocks(
  _MockStudentRepository studentRepo,
  _MockAuthRepository authRepo,
) {
  // HomeBloc needs
  when(
    () => studentRepo.getContinueLearning(),
  ).thenAnswer((_) async => const Result.success(null));
  when(
    () => studentRepo.getTodaySchedule(),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => studentRepo.getPendingAssignments(),
  ).thenAnswer((_) async => const Result.success([]));

  // LearningBloc needs
  when(
    () => studentRepo.getActiveEnrollments(),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => studentRepo.getAllCourses(page: any(named: 'page')),
  ).thenAnswer((_) async => const Result.success([]));

  // ScheduleBloc needs
  when(
    () => studentRepo.getEventDates(any()),
  ).thenAnswer((_) async => const Result.success(<DateTime>{}));

  // AchievementBloc needs
  when(() => authRepo.getSavedUser()).thenAnswer((_) async => null);
  when(
    () => studentRepo.getStats(),
  ).thenAnswer((_) async => const Result.success(StudentStatsModel()));
  when(
    () => studentRepo.getBadges(),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => studentRepo.getCertificates(),
  ).thenAnswer((_) async => const Result.success([]));
}

late _MockStudentRepository _mockStudentRepo;
late _MockAuthRepository _mockAuthRepo;

Widget _buildShell({StudentTab initialTab = StudentTab.home}) {
  return BlocProvider<AuthBloc>(
    create: (_) => AuthBloc(_mockAuthRepo),
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
  group('StudentShell', () {
    setUp(() {
      _mockStudentRepo = _MockStudentRepository();
      _mockAuthRepo = _MockAuthRepository();
      _stubMocks(_mockStudentRepo, _mockAuthRepo);

      final di = GetIt.instance;
      di.registerSingleton<StudentRepository>(_mockStudentRepo);
      di.registerSingleton<AuthRepository>(_mockAuthRepo);

      // Register blocs as factories (match di_bloc_module.dart)
      di.registerFactory<HomeBloc>(() => HomeBloc(_mockStudentRepo));
      di.registerFactory<LearningBloc>(() => LearningBloc(_mockStudentRepo));
      di.registerFactory<ScheduleBloc>(() => ScheduleBloc(_mockStudentRepo));
      di.registerFactory<AchievementBloc>(
        () => AchievementBloc(_mockStudentRepo, _mockAuthRepo),
      );
    });

    tearDown(() async {
      await GetIt.instance.reset();
    });

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
      await tester.pumpAndSettle();

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
