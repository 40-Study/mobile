import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_event.dart';
import 'package:study/features/student/bloc/achievement/achievement_state.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/bloc/home/home_event.dart';
import 'package:study/features/student/bloc/home/home_state.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_event.dart';
import 'package:study/features/student/data/models/schedule_item_model.dart';
import 'package:study/features/student/presentation/home/widgets/assignment_list.dart';
import 'package:study/features/student/presentation/home/widgets/continue_learning_card.dart';
import 'package:study/features/student/presentation/home/widgets/daily_goal_card.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';
import 'package:study/features/student/presentation/home/widgets/weekly_achievement_card.dart';
import 'package:study/features/student/presentation/learning/course_detail_screen.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/features/student/repository/student_repository_impl.dart';
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
            child: Column(
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
                if (state.continueLearning != null) ...[
                  SectionHeader(
                    title: 'Mục tiêu hôm nay',
                    iconColor: cs.secondary,
                  ),
                  AppSpacing.vGap12,
                  DailyGoalCard(
                    enrollment: state.continueLearning!,
                    onTap: () {
                      context.read<ScheduleBloc>().add(
                        ScheduleDateSelected(DateTime.now()),
                      );
                      widget.onNavigateToTab?.call(2);
                    },
                  ),
                  AppSpacing.vGap24,
                ],
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mở bài tập: ${assignment.title}'),
                      ),
                    );
                  },
                ),
                AppSpacing.vGap24,
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
            ),
          ),
        ],
      ),
    );
  }

  void _onScheduleItemTap(BuildContext context, ScheduleItemModel item) {
    if (item.lessonId != null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => LessonBloc(StudentRepositoryImpl())
              ..add(LessonStarted(item.lessonId!)),
            child: const LessonDetailScreen(),
          ),
        ),
      );
    } else if (item.courseId != null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => CourseDetailBloc(StudentRepositoryImpl())
              ..add(CourseDetailStarted(item.courseId!)),
            child: const CourseDetailScreen(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mở: ${item.title}')),
      );
    }
  }

  void _navigateToCourse(BuildContext context, String enrollmentId) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) =>
              CourseDetailBloc(StudentRepositoryImpl())
                ..add(CourseDetailStarted(enrollmentId)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
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
