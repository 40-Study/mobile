import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_cubit.dart';
import 'package:study/features/student/bloc/lesson_detail/lesson_detail_cubit.dart';
import 'package:study/features/student/bloc/student_dashboard/student_dashboard_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/cart_screen.dart';
import 'package:study/features/student/presentation/screens/course_detail_screen.dart';
import 'package:study/features/student/presentation/screens/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/screens/notifications_screen.dart';
import 'package:study/features/student/presentation/screens/student_learning_screen.dart';
import 'package:study/features/student/presentation/screens/student_main_screen.dart';
import 'package:study/features/student/presentation/widgets/dashboard/dashboard_widgets.dart';
import 'package:study/index.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<StudentDashboardCubit, StudentDashboardState>(
        builder: (context, state) {
          return switch (state) {
            StudentDashboardInitial() ||
            StudentDashboardLoading() =>
              const Center(child: CircularProgressIndicator()),
            StudentDashboardLoaded() => RefreshIndicator(
                onRefresh: context.read<StudentDashboardCubit>().refresh,
                child: _DashboardBody(state: state),
              ),
            StudentDashboardFailure(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: AppIconSize.hero, color: cs.error),
                    const SizedBox(height: AppSpacing.lg),
                    Text(message),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed:
                          context.read<StudentDashboardCubit>().loadDashboard,
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state});

  final StudentDashboardLoaded state;

  void _openNotifications(BuildContext context) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: const NotificationsScreen(),
        ),
      ),
    );
  }

  void _openCart(BuildContext context) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: const CartScreen(),
        ),
      ),
    );
  }

  void _openCourseDetail(BuildContext context, EnrollmentModel enrollment) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: BlocProvider(
            create: (_) => CourseDetailCubit(
              repository: repository,
              enrollmentId: enrollment.id,
              courseId: enrollment.courseId,
            ),
            child: CourseDetailScreen(
              enrollmentId: enrollment.id,
              courseId: enrollment.courseId,
              courseTitle: enrollment.courseName ?? '',
            ),
          ),
        ),
      ),
    );
  }

  void _openLessonDetail(
    BuildContext context, {
    required String lessonId,
    required String lessonTitle,
    int initialTab = 0,
  }) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => LessonDetailCubit(
            repository: repository,
            lessonId: lessonId,
          ),
          child: LessonDetailScreen(
            lessonId: lessonId,
            lessonTitle: lessonTitle,
            initialTab: initialTab,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppLayout.dashboardPadding,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        LocationHeader(
          onNotificationTap: () => _openNotifications(context),
          onCartTap: () => _openCart(context),
          notificationCount: state.stats.totalCourses > 0 ? 3 : 0,
          cartCount: 0,
        ),
        const SizedBox(height: AppSpacing.xl),
        LevelHeroCard(
          level: state.stats.overallProgress.toInt(),
          name: state.studentName,
        ),
        const SizedBox(height: AppSpacing.xxl),
        DashboardSectionRow(
          title: 'Lich hoc hom nay',
          action: 'Xem tat ca',
          onActionTap: () => StudentMainScreen.switchToTab(
            context,
            StudentMainScreen.tabLearning,
            segment: StudentLearningScreen.segmentSchedule,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.todaySchedules.isEmpty)
          const DashboardEmptyCard(message: 'Khong co buoi hoc nao hom nay')
        else
          ...state.todaySchedules
              .take(3)
              .toList()
              .asMap()
              .entries
              .map((entry) {
            final schedule = entry.value;
            final isFirst = entry.key == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: DashboardScheduleCard(
                label: isFirst ? 'SAP DIEN RA' : 'TIEP THEO',
                time: schedule.timeDisplay,
                title: schedule.className ?? 'Buoi hoc',
                subtitle: schedule.title ?? '',
                location: schedule.meetingUrl != null
                    ? 'Phong Zoom'
                    : (schedule.teacherName ?? ''),
                isUpcoming: isFirst,
                isLive: schedule.isLive,
                onTap: () => _openLessonDetail(
                  context,
                  lessonId: schedule.id,
                  lessonTitle: schedule.title ?? schedule.className ?? '',
                ),
              ),
            );
          }),
        const SizedBox(height: AppSpacing.xxl),
        // Pending assignments section with real data
        DashboardSectionRow(
          title: 'Bai tap can lam',
          action: '${state.pendingAssignments.length} bai tap',
          actionColor: const Color(0xFFEF4444),
          onActionTap: () => StudentMainScreen.switchToTab(
            context,
            StudentMainScreen.tabLearning,
            segment: StudentLearningScreen.segmentAssignments,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.pendingAssignments.isEmpty)
          const DashboardEmptyCard(message: 'Khong co bai tap nao can lam')
        else
          ...state.pendingAssignments.take(3).map((assignment) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: PendingAssignmentCard(
                  assignment: assignment,
                  onTap: () => _openLessonDetail(
                    context,
                    lessonId: assignment.id,
                    lessonTitle: assignment.title,
                    initialTab: 2,
                  ),
                ),
              )),
        const SizedBox(height: AppSpacing.xxl),
        // Continue learning section
        Text(
          'Tiep tuc hoc',
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.enrollments.isEmpty)
          const DashboardEmptyCard(
              message: 'Ban chua dang ky khoa hoc nao')
        else
          ContinueLearningCard(
            courseName: state.enrollments.first.courseName ?? 'Khoa hoc',
            progress: state.enrollments.first.progress,
            totalLessons: state.enrollments.first.totalLessons,
            completedLessons: state.enrollments.first.completedLessons,
            onTap: () =>
                _openCourseDetail(context, state.enrollments.first),
          ),
        const SizedBox(height: AppSpacing.xxl),
        // Featured posts section
        if (state.featuredPosts.isNotEmpty) ...[
          DashboardSectionRow(
            title: 'Bai viet noi bat',
            action: 'Xem tat ca',
            onActionTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          ...state.featuredPosts.take(3).map((post) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FeaturedPostCard(
                  post: post,
                  onTap: () {},
                ),
              )),
          const SizedBox(height: AppSpacing.xxl),
        ],
        // Trending courses section
        if (state.trendingCourses.isNotEmpty) ...[
          DashboardSectionRow(
            title: 'Khoa hoc xu huong',
            action: 'Xem tat ca',
            onActionTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.trendingCourses.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final course = state.trendingCourses[index];
                return TrendingCourseCard(
                  course: course,
                  onTap: () {},
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
        // Competitions section
        if (state.competitions.isNotEmpty) ...[
          DashboardSectionRow(
            title: 'Cuoc thi',
            action: '${state.competitions.length} cuoc thi',
            actionColor: const Color(0xFF8B5CF6),
            onActionTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.competitions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final competition = state.competitions[index];
                return CompetitionCard(
                  competition: competition,
                  onTap: () {},
                  onJoin: () {},
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ],
    );
  }
}
