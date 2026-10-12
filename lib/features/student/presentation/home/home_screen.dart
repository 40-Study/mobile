import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/data/daily_goals_storage.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_event.dart';
import 'package:study/features/student/bloc/achievement/achievement_state.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/home/home_event.dart';
import 'package:study/features/student/bloc/home/home_state.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/data/models/schedule_item_model.dart';
import 'package:study/features/student/presentation/home/widgets/widgets.dart';
import 'package:study/features/student/presentation/learning/course_detail/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/features/student/presentation/widgets/widgets.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.userName,
    this.onDrawerTap,
    this.onNavigateToTab,
  });

  final String? userName;
  final VoidCallback? onDrawerTap;
  final void Function(int tabIndex)? onNavigateToTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeStarted());
    context.read<AchievementBloc>().add(const AchievementStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StudentHomeTopBar(
              onDrawerTap: widget.onDrawerTap,
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationScreen(),
                ),
              ),
              onAvatarTap: () => widget.onNavigateToTab?.call(4),
            ),
            Expanded(
              child: BlocConsumer<HomeBloc, HomeState>(
                listenWhen: (prev, curr) =>
                    curr is HomeSuccess && curr.classCourseNavigation != null,
                listener: (context, state) {
                  if (state is HomeSuccess) {
                    _handleClassCourseNavigation(
                      context,
                      state.classCourseNavigation,
                    );
                  }
                },
                builder: (context, state) {
                  return switch (state) {
                    HomeInitial() || HomeInProgress() => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    HomeFailure(:final message) =>
                      _buildError(context, message),
                    HomeSuccess() => _buildContent(context, state),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreenAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_problem, color: cs.onErrorContainer),
            ),
            AppSpacing.vGap16,
            Text(
              l10n.scheduleErrorLoadData,
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap4,
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: () =>
                  context.read<HomeBloc>().add(const HomeStarted()),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgainButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeSuccess state) {
    final activeScheduleId = _activeScheduleId(state.scheduleItems);
    final firstName = _firstName(widget.userName);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshed());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.xxl,
        ),
        children: [
          Text(
            '${_greeting()}, $firstName',
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.slate900,
              letterSpacing: -0.5,
              fontSize: 26,
            ),
          ),
          AppSpacing.vGap12,
          TodaySummary(
            scheduleCount: state.scheduleItems.length,
            assignmentCount: state.assignments.length,
          ),
          AppSpacing.vGap16,
          if (state.continueLearning != null)
            ContinueLearningCard(
              enrollment: state.continueLearning!,
              onContinueTap: () =>
                  _navigateToCourse(context, state.continueLearning!.id),
            )
          else
            ExploreCoursesCard(
              onTap: () => widget.onNavigateToTab?.call(1),
            ),
          AppSpacing.vGap24,
          _buildSections(context, state, activeScheduleId),
        ],
      ),
    );
  }

  Widget _buildSections(
    BuildContext context,
    HomeSuccess state,
    String? activeScheduleId,
  ) {
    final cs = Theme.of(context).colorScheme;
    final hasGoals =
        DailyGoalsStorage.instance.getGoals(DateTime.now()).isNotEmpty;

    // Build section widgets with hasData flag
    final sections = <({int order, bool hasData, Widget widget})>[
      // Schedule section
      (
        order: 0,
        hasData: state.scheduleItems.isNotEmpty,
        widget: _buildScheduleSection(context, state, activeScheduleId),
      ),
      // Daily goals section
      (
        order: 1,
        hasData: hasGoals,
        widget: _buildGoalsSection(context, cs),
      ),
      // Assignments section
      (
        order: 2,
        hasData: state.assignments.isNotEmpty,
        widget: _buildAssignmentsSection(context, state, cs),
      ),
      // Achievements section
      (
        order: 3,
        hasData: true, // Achievements always has stats
        widget: _buildAchievementsSection(context, cs),
      ),
    ]..sort((a, b) {
        if (a.hasData != b.hasData) return a.hasData ? -1 : 1;
        return a.order.compareTo(b.order);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((s) => s.widget).toList(),
    );
  }

  Widget _buildScheduleSection(
    BuildContext context,
    HomeSuccess state,
    String? activeScheduleId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Lịch học hôm nay',
          actionLabel: 'Xem tất cả',
          onActionTap: () => widget.onNavigateToTab?.call(2),
        ),
        AppSpacing.vGap12,
        ScheduleTimeline(
          items: state.scheduleItems.map((item) {
            return ScheduleTimelineItemData(
              time: _formatTimeRange(item.startTime, item.endTime),
              title: item.title,
              subtitle: item.instructorName ?? _typeLabel(item.type),
              type: _mapScheduleType(item.type),
              isActive: item.id == activeScheduleId,
              onTap: () => _onScheduleItemTap(context, item),
            );
          }).toList(),
        ),
        AppSpacing.vGap24,
      ],
    );
  }

  Widget _buildGoalsSection(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Mục tiêu hôm nay',
          iconColor: cs.secondary,
          actionLabel: 'Xem tất cả',
          onActionTap: () => widget.onNavigateToTab?.call(2),
        ),
        AppSpacing.vGap12,
        HomeDailyGoalsCard(onTap: () => widget.onNavigateToTab?.call(2)),
        AppSpacing.vGap24,
      ],
    );
  }

  Widget _buildAssignmentsSection(
    BuildContext context,
    HomeSuccess state,
    ColorScheme cs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Bài tập cần hoàn thành',
          iconColor: cs.tertiary,
          actionLabel: 'Xem tất cả',
          onActionTap: () => widget.onNavigateToTab?.call(1),
        ),
        AppSpacing.vGap12,
        AssignmentList(
          assignments: state.assignments,
          onItemTap: (assignment) {
            if (assignment.lessonId != null) {
              _navigateToLesson(context, assignment.lessonId!);
            } else if (assignment.enrollmentId != null) {
              _navigateToCourse(context, assignment.enrollmentId!);
            }
          },
        ),
        AppSpacing.vGap24,
      ],
    );
  }

  Widget _buildAchievementsSection(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Thành tựu tuần này',
          iconColor: cs.tertiary,
          actionLabel: 'Xem tất cả',
          onActionTap: () => widget.onNavigateToTab?.call(3),
        ),
        AppSpacing.vGap12,
        BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, achievementState) {
            return switch (achievementState) {
              AchievementSuccess() => WeeklyAchievementCard(
                  stats: achievementState.stats,
                  earnedBadgeCount: achievementState.earnedBadges.length,
                  onTap: () => widget.onNavigateToTab?.call(3),
                ),
              AchievementFailure() => AchievementPlaceholder(
                  onTap: () => widget.onNavigateToTab?.call(3),
                ),
              _ => const AchievementLoadingCard(),
            };
          },
        ),
        AppSpacing.vGap24,
      ],
    );
  }

  Future<void> _onScheduleItemTap(
    BuildContext context,
    ScheduleItemModel item,
  ) async {
    if (item.lessonId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => diContainer<LessonBloc>()
              ..add(LessonStarted(item.lessonId!)),
            child: const LessonDetailScreen(),
          ),
        ),
      );
    } else if (item.courseId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => diContainer<CourseDetailBloc>()
              ..add(CourseDetailStarted(item.courseId!)),
            child: const CourseDetailScreen(),
          ),
        ),
      );
    } else if (item.classId != null) {
      context.read<HomeBloc>().add(HomeClassCourseRequested(item.classId!));
      return; // Navigation handled via BlocConsumer listener
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.scheduleOpenItem(item.title),
          ),
        ),
      );
      return;
    }
    // Refresh home data khi quay về
    if (context.mounted) {
      context.read<HomeBloc>().add(const HomeRefreshed());
    }
  }

  void _handleClassCourseNavigation(
    BuildContext context,
    ClassCourseNavigation? nav,
  ) {
    if (nav == null) return;

    final l10n = AppLocalizations.of(context)!;

    switch (nav) {
      case ClassCourseNavigationLoading():
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      case ClassCourseNavigationSuccess(:final enrollment):
        // Close loading dialog if open
        Navigator.of(context, rootNavigator: true).pop();
        context.read<HomeBloc>().add(const HomeClassCourseNavigationHandled());
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (_) => diContainer<CourseDetailBloc>()
                ..add(CourseDetailStarted(enrollment.id)),
              child: const CourseDetailScreen(),
            ),
          ),
        ).then((_) {
          if (context.mounted) {
            context.read<HomeBloc>().add(const HomeRefreshed());
          }
        });
      case ClassCourseNavigationError(:final message):
        Navigator.of(context, rootNavigator: true).pop();
        context.read<HomeBloc>().add(const HomeClassCourseNavigationHandled());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message == 'course_not_found'
                  ? l10n.scheduleCourseNotFound
                  : l10n.scheduleNotEnrolled,
            ),
          ),
        );
    }
  }

  Future<void> _navigateToLesson(BuildContext context, String lessonId) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => diContainer<LessonBloc>()
            ..add(LessonStarted(lessonId)),
          child: const LessonDetailScreen(),
        ),
      ),
    );
    if (context.mounted) {
      context.read<HomeBloc>().add(const HomeRefreshed());
    }
  }

  Future<void> _navigateToCourse(
    BuildContext context,
    String enrollmentId,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => diContainer<CourseDetailBloc>()
            ..add(CourseDetailStarted(enrollmentId)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
    // Refresh home data khi quay về
    if (context.mounted) {
      context.read<HomeBloc>().add(const HomeRefreshed());
    }
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  ScheduleItemType _mapScheduleType(String type) {
    return switch (type.toLowerCase()) {
      'livestream' => ScheduleItemType.livestream,
      'quiz' => ScheduleItemType.quiz,
      'deadline' => ScheduleItemType.deadline,
      _ => ScheduleItemType.video,
    };
  }

  String? _activeScheduleId(List<ScheduleItemModel> items) {
    final now = DateTime.now();
    ScheduleItemModel? current;
    ScheduleItemModel? next;

    for (final item in items) {
      final isCurrent =
          !item.startTime.isAfter(now) && item.endTime.isAfter(now);
      if (isCurrent &&
          (current == null || item.startTime.isBefore(current.startTime))) {
        current = item;
      } else if (item.startTime.isAfter(now) &&
          (next == null || item.startTime.isBefore(next.startTime))) {
        next = item;
      }
    }

    return current?.id ?? next?.id;
  }

  String _typeLabel(String type) {
    return switch (type.toLowerCase()) {
      'livestream' => 'Trực tuyến',
      'quiz' => 'Bài kiểm tra',
      'deadline' => 'Hạn nộp',
      _ => 'Video',
    };
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String _firstName(String? name) {
    final normalized = name?.trim();
    if (normalized == null || normalized.isEmpty) return 'bạn';
    return normalized.split(RegExp(r'\s+')).last;
  }
}
