import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/home/home_event.dart';
import 'package:study/features/student/bloc/home/home_state.dart';
import 'package:study/features/student/presentation/home/widgets/assignment_list.dart';
import 'package:study/features/student/presentation/home/widgets/continue_learning_card.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
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

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshed());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text(
            '${_greeting()}, ${_firstName(widget.userName)}',
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.vGap4,
          Text(
            _formatToday(DateTime.now()),
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          _DailyOverview(
            scheduleCount: state.scheduleItems.length,
            assignmentCount: state.assignments.length,
          ),
          AppSpacing.vGap24,

          if (state.continueLearning != null) ...[
            ContinueLearningCard(
              enrollment: state.continueLearning!,
              onContinueTap: () =>
                  _navigateToCourse(context, state.continueLearning!.id),
            ),
            AppSpacing.vGap24,
          ],

          SectionHeader(
            title: 'Lịch học hôm nay',
            icon: Icons.calendar_today,
            actionLabel: 'Xem tất cả',
            onActionTap: () => widget.onNavigateToTab?.call(2),
          ),
          AppSpacing.vGap12,
          ScheduleTimeline(
            items: state.scheduleItems.map((item) {
              return ScheduleTimelineItemData(
                time: _formatTimeRange(item.startTime, item.endTime),
                title: item.title,
                subtitle:
                    '${_typeLabel(item.type)} • ${item.instructorName ?? ""}',
                type: _mapScheduleType(item.type),
                isActive: _isCurrentOrNext(item.startTime, item.endTime),
              );
            }).toList(),
          ),
          AppSpacing.vGap24,

          SectionHeader(
            title: 'Bài tập cần hoàn thành',
            icon: Icons.assignment,
            actionLabel: 'Xem tất cả',
            onActionTap: () => widget.onNavigateToTab?.call(1),
          ),
          AppSpacing.vGap12,
          AssignmentList(
            assignments: state.assignments,
            onItemTap: (assignment) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mở bài tập: ${assignment.title}')),
              );
            },
          ),
          AppSpacing.vGap32,
        ],
      ),
    );
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

  bool _isCurrentOrNext(DateTime start, DateTime end) {
    final now = DateTime.now();
    return start.isAfter(now) || (start.isBefore(now) && end.isAfter(now));
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

  String _formatToday(DateTime date) {
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} tháng ${date.month}';
  }
}

class _DailyOverview extends StatelessWidget {
  const _DailyOverview({
    required this.scheduleCount,
    required this.assignmentCount,
  });

  final int scheduleCount;
  final int assignmentCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _OverviewItem(
              icon: Icons.calendar_month_outlined,
              value: '$scheduleCount',
              label: 'buổi học',
              color: cs.primary,
              background: cs.primaryContainer,
            ),
          ),
          SizedBox(
            height: 42,
            child: VerticalDivider(color: cs.outlineVariant),
          ),
          Expanded(
            child: _OverviewItem(
              icon: Icons.task_alt_outlined,
              value: '$assignmentCount',
              label: 'bài cần làm',
              color: cs.tertiary,
              background: cs.tertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
        AppSpacing.hGap12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                label,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
