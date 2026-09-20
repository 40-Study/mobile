import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/data/daily_goals_storage.dart';
import 'package:study/data/motivational_quotes.dart';
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
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_event.dart';
import 'package:study/features/student/data/models/schedule_item_model.dart';
import 'package:study/features/student/presentation/home/widgets/assignment_list.dart';
import 'package:study/features/student/presentation/home/widgets/continue_learning_card.dart';
import 'package:study/features/student/presentation/home/widgets/daily_goal_card.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';
import 'package:study/features/student/presentation/home/widgets/weekly_achievement_card.dart';
import 'package:study/features/student/presentation/learning/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/repository/student_repository.dart';
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        leading: widget.onDrawerTap != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onDrawerTap,
                tooltip: 'Mở menu',
              )
            : null,
        title: Text(
          '40Study',
          style: tt.titleLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Thông báo',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationScreen(),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: cs.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Tooltip(
              message: 'Tài khoản',
              child: InkWell(
                onTap: () => widget.onNavigateToTab?.call(4),
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    _initial(widget.userName),
                    style: tt.labelLarge?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeInitial() || HomeInProgress() => const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            HomeFailure(:final message) => _buildError(context, message),
            HomeSuccess() => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
              'Không thể tải dữ liệu',
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
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final activeScheduleId = _activeScheduleId(state.scheduleItems);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshed());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.xs,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, ${_firstName(widget.userName)}',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                AppSpacing.vGap4,
                Text(
                  'Tiếp tục hành trình\nhọc tập của bạn.',
                  style: tt.headlineMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                AppSpacing.vGap12,
                _TodaySummary(
                  scheduleCount: state.scheduleItems.length,
                  assignmentCount: state.assignments.length,
                ),
                const SizedBox(height: 20),
                if (state.continueLearning != null)
                  ContinueLearningCard(
                    enrollment: state.continueLearning!,
                    onContinueTap: () =>
                        _navigateToCourse(context, state.continueLearning!.id),
                  )
                else
                  _ExploreCoursesCard(
                    onTap: () => widget.onNavigateToTab?.call(1),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                cs.primary.withValues(
                  alpha: Theme.of(context).brightness == Brightness.light
                      ? 0.045
                      : 0.065,
                ),
                cs.surfaceContainer,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
              border: Border(
                top: BorderSide(color: cs.primary.withValues(alpha: 0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.045),
                  blurRadius: 32,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.xl,
              AppSpacing.screenPadding,
              104,
            ),
            child: _buildSections(context, state, activeScheduleId),
          ),
        ],
      ),
    );
  }

  Widget _buildSections(BuildContext context, HomeSuccess state, String? activeScheduleId) {
    final cs = Theme.of(context).colorScheme;
    final hasGoals = DailyGoalsStorage.instance.getGoals(DateTime.now()).isNotEmpty;

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
    ];

    // Sort: sections with data first, then by default order
    sections.sort((a, b) {
      if (a.hasData != b.hasData) return a.hasData ? -1 : 1;
      return a.order.compareTo(b.order);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((s) => s.widget).toList(),
    );
  }

  Widget _buildScheduleSection(BuildContext context, HomeSuccess state, String? activeScheduleId) {
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
        _DailyGoalsCard(onTap: () => widget.onNavigateToTab?.call(2)),
        AppSpacing.vGap24,
      ],
    );
  }

  Widget _buildAssignmentsSection(BuildContext context, HomeSuccess state, ColorScheme cs) {
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
              AchievementFailure() => _AchievementPlaceholder(
                onTap: () => widget.onNavigateToTab?.call(3),
              ),
              _ => const _AchievementLoadingCard(),
            };
          },
        ),
      ],
    );
  }

  Future<void> _onScheduleItemTap(BuildContext context, ScheduleItemModel item) async {
    if (item.lessonId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => LessonBloc(diContainer<StudentRepository>())
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
            create: (_) => CourseDetailBloc(diContainer<StudentRepository>())
              ..add(CourseDetailStarted(item.courseId!)),
            child: const CourseDetailScreen(),
          ),
        ),
      );
    } else if (item.classId != null) {
      await _navigateToClassCourse(context, item.classId!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mở: ${item.title}')),
      );
      return;
    }
    // Refresh home data khi quay về
    if (context.mounted) {
      context.read<HomeBloc>().add(const HomeRefreshed());
    }
  }

  Future<void> _navigateToClassCourse(BuildContext context, String classId) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = diContainer<StudentRepository>();
      final classResult = await repo.getCourseIdFromClass(classId);
      if (!context.mounted) return;

      final courseId = classResult.valueOrNull;
      if (courseId == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy khóa học')),
        );
        return;
      }

      final enrollmentsResult = await repo.getActiveEnrollments();
      if (!context.mounted) return;
      Navigator.pop(context);

      final enrollments = enrollmentsResult.valueOrNull ?? [];
      final enrollment = enrollments.where((e) => e.courseId == courseId).firstOrNull;

      if (enrollment != null) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (_) => CourseDetailBloc(diContainer<StudentRepository>())
                ..add(CourseDetailStarted(enrollment.id)),
              child: const CourseDetailScreen(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn chưa đăng ký khóa học này')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _navigateToLesson(BuildContext context, String lessonId) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => LessonBloc(diContainer<StudentRepository>())
            ..add(LessonStarted(lessonId)),
          child: const LessonDetailScreen(),
        ),
      ),
    );
    if (context.mounted) {
      context.read<HomeBloc>().add(const HomeRefreshed());
    }
  }

  Future<void> _navigateToCourse(BuildContext context, String enrollmentId) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              CourseDetailBloc(diContainer<StudentRepository>())
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

  String _initial(String? name) {
    final normalized = name?.trim();
    if (normalized == null || normalized.isEmpty) return 'B';
    return normalized.substring(0, 1).toUpperCase();
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({
    required this.scheduleCount,
    required this.assignmentCount,
  });

  final int scheduleCount;
  final int assignmentCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _SummaryItem(
          icon: Icons.calendar_month_outlined,
          label: '$scheduleCount buổi học',
          color: cs.primary,
        ),
        Container(
          width: 1,
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          color: cs.outline,
        ),
        _SummaryItem(
          icon: Icons.task_alt_outlined,
          label: '$assignmentCount bài cần làm',
          color: cs.tertiary,
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        AppSpacing.hGap8,
        Text(
          label,
          style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _AchievementLoadingCard extends StatelessWidget {
  const _AchievementLoadingCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outline),
        boxShadow: AppShadows.layeredCard,
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2.5),
    );
  }
}

class _AchievementPlaceholder extends StatelessWidget {
  const _AchievementPlaceholder({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.layeredCard,
      ),
      child: Material(
        color: cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: cs.outline),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.emoji_events_outlined, color: cs.tertiary),
                AppSpacing.hGap12,
                Expanded(
                  child: Text(
                    'Mở trang Thành tích để xem các cột mốc của bạn.',
                    style: tt.bodyMedium,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyGoalsCard extends StatelessWidget {
  const _DailyGoalsCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final goalColor = cs.secondary;

    final storage = DailyGoalsStorage.instance;
    final goals = storage.getGoals(DateTime.now());
    final (completed, total) = storage.getTodayProgress();
    final progress = total > 0 ? completed / total : 0.0;
    final nextGoal = goals.where((g) => !g.isCompleted).firstOrNull;

    // Empty state - banner with illustration
    if (goals.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: const Color(0xFFC8E6C9).withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: goalColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.flag_rounded, size: 18, color: goalColor),
                        ),
                        AppSpacing.hGap12,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hãy đặt mục tiêu',
                              style: tt.titleSmall?.copyWith(
                                color: const Color(0xFF43A047),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'để bắt đầu ngày mới!',
                              style: tt.bodySmall?.copyWith(color: const Color(0xFF66BB6A)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppSpacing.vGap12,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF66BB6A),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                          AppSpacing.hGap4,
                          Text(
                            'Thêm mục tiêu',
                            style: tt.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.eco_rounded, size: 36, color: goalColor.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      );
    }

    // Has goals - normal card
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.layeredCard,
      ),
      child: Material(
        color: cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: cs.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 66,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress,
                          color: goalColor,
                          strokeWidth: 7,
                          strokeCap: StrokeCap.round,
                          backgroundColor: goalColor.withValues(alpha: 0.1),
                        ),
                      ),
                      Text(
                        '$completed/$total',
                        style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completed == total
                            ? 'Hoàn thành tất cả!'
                            : 'Còn ${total - completed} mục tiêu',
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      AppSpacing.vGap4,
                      Text(
                        nextGoal?.title ?? 'Tuyệt vời! Bạn đã hoàn thành.',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap8,
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreCoursesCard extends StatelessWidget {
  const _ExploreCoursesCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.layeredCard,
      ),
      child: Material(
        color: cs.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.school_rounded, color: cs.onPrimary),
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bắt đầu học ngay!',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      AppSpacing.vGap4,
                      Text(
                        'Khám phá các khóa học phù hợp với bạn',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: cs.onPrimaryContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
