import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/teacher/bloc/dashboard/teacher_dashboard_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';

class MockTeacherRepository extends Mock implements TeacherRepository {}

void main() {
  group('TeacherDashboardCubit', () {
    late TeacherRepository repository;
    late TeacherDashboardCubit cubit;

    final mockStats = const TeacherStatsModel(
      monthlyRevenue: 42850000,
      newStudents: 128,
      completionRate: 94.2,
      totalCourses: 3,
      activeCourses: 2,
      totalStudents: 1240,
    );

    final mockWallet = const TeacherWalletModel(
      balance: 45280000,
      monthlyIncome: 12450000,
      incomeChangePercent: 15.2,
      isPremium: true,
    );

    final mockNotifications = <TeacherNotificationModel>[
      const TeacherNotificationModel(
        id: '1',
        title: 'Test notification',
        type: 'system',
        createdAt: '2 phút trước',
      ),
    ];

    final mockSchedules = <TeacherScheduleModel>[
      const TeacherScheduleModel(
        id: '1',
        title: 'Test schedule',
        startTime: '2024-03-14T19:30:00',
      ),
    ];

    final mockCourses = <CourseModel>[
      const CourseModel(
        id: '1',
        name: 'Test Course',
        status: 'active',
      ),
    ];

    final mockAssignments = <PendingAssignmentModel>[
      const PendingAssignmentModel(
        id: '1',
        studentName: 'Test Student',
        assignmentTitle: 'Test Assignment',
        submittedAt: '1 giờ trước',
      ),
    ];

    final mockActivities = <TeacherActivityModel>[
      const TeacherActivityModel(
        id: '1',
        title: 'Test Activity',
        type: ActivityType.newStudent,
        createdAt: 'HÔM NAY',
      ),
    ];

    setUp(() {
      repository = MockTeacherRepository();
      cubit = TeacherDashboardCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state should be TeacherDashboardInitial', () {
      expect(cubit.state, const TeacherDashboardInitial());
    });

    blocTest<TeacherDashboardCubit, TeacherDashboardState>(
      'loadDashboard should emit [Loading, Loaded] when successful',
      setUp: () {
        when(() => repository.getStats()).thenAnswer((_) async => mockStats);
        when(() => repository.getWallet()).thenAnswer((_) async => mockWallet);
        when(() => repository.getNotifications())
            .thenAnswer((_) async => mockNotifications);
        when(() => repository.getUpcomingSchedule())
            .thenAnswer((_) async => mockSchedules);
        when(() => repository.getCourses(pageSize: 10))
            .thenAnswer((_) async => mockCourses);
        when(() => repository.getPendingAssignments())
            .thenAnswer((_) async => mockAssignments);
        when(() => repository.getActivities())
            .thenAnswer((_) async => mockActivities);
      },
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const TeacherDashboardLoading(),
        isA<TeacherDashboardLoaded>()
            .having((s) => s.stats, 'stats', mockStats)
            .having((s) => s.wallet, 'wallet', mockWallet)
            .having((s) => s.notifications, 'notifications', mockNotifications)
            .having((s) => s.schedules, 'schedules', mockSchedules)
            .having((s) => s.courses, 'courses', mockCourses)
            .having(
                (s) => s.pendingAssignments, 'assignments', mockAssignments)
            .having((s) => s.activities, 'activities', mockActivities),
      ],
      verify: (_) {
        verify(() => repository.getStats()).called(1);
        verify(() => repository.getWallet()).called(1);
        verify(() => repository.getNotifications()).called(1);
        verify(() => repository.getUpcomingSchedule()).called(1);
        verify(() => repository.getCourses(pageSize: 10)).called(1);
        verify(() => repository.getPendingAssignments()).called(1);
        verify(() => repository.getActivities()).called(1);
      },
    );

    blocTest<TeacherDashboardCubit, TeacherDashboardState>(
      'loadDashboard should emit [Loading, Failure] when repository throws',
      setUp: () {
        when(() => repository.getStats())
            .thenThrow(Exception('Failed to load stats'));
      },
      build: () => cubit,
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const TeacherDashboardLoading(),
        isA<TeacherDashboardFailure>()
            .having((s) => s.message, 'message', contains('Failed to load')),
      ],
    );

    blocTest<TeacherDashboardCubit, TeacherDashboardState>(
      'refresh should reload dashboard data',
      setUp: () {
        when(() => repository.getStats()).thenAnswer((_) async => mockStats);
        when(() => repository.getWallet()).thenAnswer((_) async => mockWallet);
        when(() => repository.getNotifications())
            .thenAnswer((_) async => mockNotifications);
        when(() => repository.getUpcomingSchedule())
            .thenAnswer((_) async => mockSchedules);
        when(() => repository.getCourses(pageSize: 10))
            .thenAnswer((_) async => mockCourses);
        when(() => repository.getPendingAssignments())
            .thenAnswer((_) async => mockAssignments);
        when(() => repository.getActivities())
            .thenAnswer((_) async => mockActivities);
      },
      build: () => cubit,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const TeacherDashboardLoading(),
        isA<TeacherDashboardLoaded>(),
      ],
    );
  });
}
