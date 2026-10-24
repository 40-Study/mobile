import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_state.dart';
import 'package:study/features/student/data/models/schedule_item_model.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';
import 'package:study/features/student/presentation/learning/course_detail/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/schedule/widgets/widgets.dart';
import 'package:study/features/student/presentation/widgets/widgets.dart';
import 'package:study/theme/theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(const ScheduleStarted());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: context.surfaceBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StudentAppHeader(
              categoryLabel: 'THỜI KHÓA BIỂU',
              title: 'Lịch học',
              icon: Icons.calendar_month_rounded,
              iconBackgroundColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              iconBorderColor: const Color(0xFFBAE6FD),
              showNotification: false,
              showAvatar: false,
              trailing: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context
                        .read<ScheduleBloc>()
                        .add(ScheduleDateSelected(DateTime.now()));
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.025),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.today_rounded,
                      color: cs.slate700,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocConsumer<ScheduleBloc, ScheduleState>(
                listenWhen: (prev, curr) =>
                    curr is ScheduleSuccess &&
                    curr.classCourseNavigation != null,
                listener: (context, state) {
                  if (state is ScheduleSuccess) {
                    _handleClassCourseNavigation(
                      context,
                      state.classCourseNavigation,
                    );
                  }
                },
                builder: (context, state) {
                  return switch (state) {
                    ScheduleInitial() ||
                    ScheduleInProgress() =>
                      const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ScheduleFailure(:final message) =>
                      _buildError(context, message),
                    ScheduleSuccess() => _buildContent(context, state),
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
              'Không thể tải lịch học',
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
                  context.read<ScheduleBloc>().add(const ScheduleStarted()),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScheduleSuccess state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ScheduleBloc>().add(const ScheduleStarted());
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
          // Header tóm tắt tháng
          MonthSummary(
            eventCount: state.eventDates.length,
            currentMonth: state.currentMonth,
          ),
          AppSpacing.vGap16,

          // Calendar Widget dạng Card độc lập
          CalendarWidget(
            currentMonth: state.currentMonth,
            selectedDate: state.selectedDate,
            eventDates: state.eventDates,
            onDateSelected: (date) {
              context.read<ScheduleBloc>().add(ScheduleDateSelected(date));
            },
            onMonthChanged: (month) {
              context.read<ScheduleBloc>().add(ScheduleMonthChanged(month));
            },
          ),
          AppSpacing.vGap24,

          // Tiêu đề ngày được chọn
          SelectedDateHeader(
            selectedDate: state.selectedDate,
            itemCount: state.selectedDateItems.length,
          ),
          AppSpacing.vGap12,

          // Timeline ca học
          if (state.isLoadingDay)
            const LoadingSchedule()
          else if (state.selectedDateItems.isEmpty)
            const FreeDay()
          else
            ScheduleTimeline(
              items: state.selectedDateItems.map((item) {
                final hasInstructor = item.instructorName != null &&
                    item.instructorName!.isNotEmpty;
                final hasLocation =
                    item.location != null && item.location!.isNotEmpty;
                final subtitle = hasInstructor
                    ? 'GV: ${item.instructorName}'
                    : (hasLocation ? item.location! : 'Tự học trực tuyến');
                return ScheduleTimelineItemData(
                  time: _formatTimeRange(item.startTime, item.endTime),
                  title: item.title,
                  subtitle: subtitle,
                  type: _mapScheduleType(item.type),
                  isActive: _isCurrentOrNext(item.startTime, item.endTime),
                  onTap: () => _onScheduleItemTap(context, item),
                );
              }).toList(),
            ),

          AppSpacing.vGap24,

          // Mục tiêu hàng ngày
          DailyGoalsSection(date: state.selectedDate),
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
            create: (_) => diContainer<LessonBloc>()
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
            create: (_) => diContainer<CourseDetailBloc>()
              ..add(CourseDetailStarted(item.courseId!)),
            child: const CourseDetailScreen(),
          ),
        ),
      );
    } else if (item.classId != null) {
      context
          .read<ScheduleBloc>()
          .add(ScheduleClassCourseRequested(item.classId!));
    }
  }

  void _handleClassCourseNavigation(
    BuildContext context,
    ScheduleClassCourseNavigation? nav,
  ) {
    if (nav == null) return;

    switch (nav) {
      case ScheduleClassCourseNavigationLoading():
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      case ScheduleClassCourseNavigationSuccess(:final enrollment):
        Navigator.of(context, rootNavigator: true).pop();
        context
            .read<ScheduleBloc>()
            .add(const ScheduleClassCourseNavigationHandled());
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider(
              create: (_) => diContainer<CourseDetailBloc>()
                ..add(CourseDetailStarted(enrollment.id)),
              child: const CourseDetailScreen(),
            ),
          ),
        );
      case ScheduleClassCourseNavigationError(:final message):
        Navigator.of(context, rootNavigator: true).pop();
        context
            .read<ScheduleBloc>()
            .add(const ScheduleClassCourseNavigationHandled());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message == 'course_not_found'
                  ? 'Khóa học của lớp này hiện không còn khả dụng'
                  : 'Bạn chưa được ghi danh vào khóa học của lớp này',
            ),
          ),
        );
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

  bool _isCurrentOrNext(DateTime start, DateTime end) {
    final now = DateTime.now();
    return !start.isAfter(now) && end.isAfter(now);
  }
}
