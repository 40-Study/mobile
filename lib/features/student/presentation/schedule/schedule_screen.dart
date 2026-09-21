import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_event.dart';
import 'package:study/features/student/bloc/schedule/schedule_state.dart';
import 'package:study/features/student/data/models/schedule_item_model.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';
import 'package:study/features/student/presentation/learning/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/schedule/widgets/widgets.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/tab_screen_header.dart';

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
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            return switch (state) {
              ScheduleInitial() || ScheduleInProgress() => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
              ScheduleFailure(:final message) => _buildError(context, message),
              ScheduleSuccess() => _buildContent(context, state),
            };
          },
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
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ScheduleBloc>().add(const ScheduleStarted());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const TabScreenHeader(
            title: 'Lịch học',
            subtitle: 'Quản lý thời gian học tập.',
          ),
          // Calendar section
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonthSummary(
                  eventCount: state.eventDates.length,
                  currentMonth: state.currentMonth,
                ),
                AppSpacing.vGap16,
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
              ],
            ),
          ),

          // Background layer với schedule
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
                SelectedDateHeader(
                  selectedDate: state.selectedDate,
                  itemCount: state.selectedDateItems.length,
                ),
                AppSpacing.vGap16,

                // Schedule timeline
                if (state.isLoadingDay)
                  const LoadingSchedule()
                else if (state.selectedDateItems.isEmpty)
                  const FreeDay()
                else
                  ScheduleTimeline(
                    items: state.selectedDateItems.map((item) {
                      return ScheduleTimelineItemData(
                        time: _formatTimeRange(item.startTime, item.endTime),
                        title: item.title,
                        subtitle:
                            '${_typeLabel(item.type)} • ${item.instructorName ?? ""}',
                        type: _mapScheduleType(item.type),
                        isActive: _isCurrentOrNext(item.startTime, item.endTime),
                        onTap: () => _onScheduleItemTap(context, item),
                      );
                    }).toList(),
                  ),

                AppSpacing.vGap24,
                DailyGoalsSection(date: state.selectedDate),
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
            create: (_) => LessonBloc(diContainer<StudentRepository>())
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
            create: (_) => CourseDetailBloc(diContainer<StudentRepository>())
              ..add(CourseDetailStarted(item.courseId!)),
            child: const CourseDetailScreen(),
          ),
        ),
      );
    } else if (item.classId != null) {
      _navigateToClassCourse(context, item.classId!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mở: ${item.title}')),
      );
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
        Navigator.push(
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
}
