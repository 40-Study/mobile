import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/index.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_cubit.dart';
import 'package:study/features/student/bloc/lesson_detail/lesson_detail_cubit.dart';
import 'package:study/features/student/bloc/student_dashboard/student_dashboard_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/course_detail_screen.dart';
import 'package:study/features/student/presentation/screens/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/screens/student_learning_screen.dart';
import 'package:study/features/student/presentation/screens/student_main_screen.dart';
import 'package:study/features/student/presentation/widgets/dashboard/dashboard_widgets.dart';
import 'package:study/features/weather/weather.dart';

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

  void _openCityPicker(BuildContext context) {
    final cubit = context.read<WeatherBackgroundCubit>();
    CityPickerSheet.show(
      context,
      selectedCity: cubit.selectedCity,
      onCitySelected: cubit.selectCity,
      onUseGPS: cubit.useGPS,
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
        Row(
          children: [
            Expanded(child: GreetingHeader(name: state.studentName)),
            IconButton(
              onPressed: () => _openCityPicker(context),
              icon: Icon(Icons.location_on_outlined, color: cs.primary),
              tooltip: 'Chon thanh pho',
            ),
            IconButton(
              onPressed: () =>
                  NavigationService.of(context).navigateTo(Routes.weatherDemo),
              icon: Icon(Icons.wb_sunny_outlined, color: cs.primary),
              tooltip: 'Weather Demo',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        StreakHeroCard(
          streakDays: state.stats.overallProgress.toInt(),
          totalClasses: state.stats.totalClasses,
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
        DashboardSectionRow(
          title: 'Bai tap can hoan thien',
          action:
              '${state.enrollments.where((e) => e.progress < 100).length}'
              ' Can nop',
          actionColor: cs.primary,
          onActionTap: () => StudentMainScreen.switchToTab(
            context,
            StudentMainScreen.tabLearning,
            segment: StudentLearningScreen.segmentAssignments,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.enrollments.isEmpty)
          const DashboardEmptyCard(message: 'Khong co bai tap nao')
        else ...[
          DashboardAssignmentCard(
            category: state.enrollments.first.courseName ?? 'Khoa hoc',
            title: state.enrollments.first.nextLesson ?? 'Bai tap',
            daysLeft: 2,
            avatarCount: state.enrollments.first.completedLessons,
            onTap: () => _openLessonDetail(
              context,
              lessonId: 'l1',
              lessonTitle:
                  state.enrollments.first.nextLesson ?? 'Bai tap',
              initialTab: 2,
            ),
            onSubmit: () => _openLessonDetail(
              context,
              lessonId: 'l1',
              lessonTitle:
                  state.enrollments.first.nextLesson ?? 'Bai tap',
              initialTab: 2,
            ),
          ),
          if (state.enrollments.length > 1) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: MiniAssignmentCard(
                    label: 'LY THUYET',
                    title: state.enrollments[1].courseName ?? 'Bai tap',
                    deadline: 'Het han: Hom nay',
                    onTap: () => _openLessonDetail(
                      context,
                      lessonId: 'l1',
                      lessonTitle: state.enrollments[1].courseName ??
                          'Bai tap',
                      initialTab: 2,
                    ),
                  ),
                ),
                if (state.enrollments.length > 2) ...[
                  const SizedBox(width: AppLayout.gutter),
                  Expanded(
                    child: MiniAssignmentCard(
                      label: 'THUC HANH',
                      title: state.enrollments[2].courseName ?? 'Bai tap',
                      deadline: 'Het han: 15 Thg 10',
                      onTap: () => _openLessonDetail(
                        context,
                        lessonId: 'l1',
                        lessonTitle: state.enrollments[2].courseName ??
                            'Bai tap',
                        initialTab: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Tiep tuc hoc',
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
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
      ],
    );
  }
}
