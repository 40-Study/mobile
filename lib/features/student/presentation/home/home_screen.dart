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
              )
            : null,
        title: Row(
          children: [
            Text(
              'Xin chao, ${widget.userName ?? "Ban"}',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.hGap4,
            const Text('👋'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const NotificationScreen()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 18, color: cs.primary),
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeInitial() || HomeInProgress() => const Center(
                child: CircularProgressIndicator(),
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          AppSpacing.vGap16,
          Text(message),
          AppSpacing.vGap16,
          FilledButton(
            onPressed: () => context.read<HomeBloc>().add(const HomeStarted()),
            child: const Text('Thu lai'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeSuccess state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshed());
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Continue learning
          if (state.continueLearning != null) ...[
            ContinueLearningCard(
              enrollment: state.continueLearning!,
              onContinueTap: () => _navigateToCourse(
                context,
                state.continueLearning!.id,
              ),
            ),
            AppSpacing.vGap24,
          ],

          // Today's schedule
          SectionHeader(
            title: 'Lich hoc hom nay',
            icon: Icons.calendar_today,
            actionLabel: 'Xem tat ca',
            onActionTap: () => widget.onNavigateToTab?.call(2),
          ),
          AppSpacing.vGap12,
          ScheduleTimeline(
            items: state.scheduleItems.map((item) {
              return ScheduleTimelineItemData(
                time: _formatTimeRange(item.startTime, item.endTime),
                title: item.title,
                subtitle: '${item.type} • ${item.instructorName ?? ""}',
                type: _mapScheduleType(item.type),
                isActive: _isCurrentOrNext(item.startTime, item.endTime),
              );
            }).toList(),
          ),
          AppSpacing.vGap24,

          // Assignments
          SectionHeader(
            title: 'Bai tap can hoan thanh',
            icon: Icons.assignment,
            actionLabel: 'Xem tat ca',
            onActionTap: () => widget.onNavigateToTab?.call(1),
          ),
          AppSpacing.vGap12,
          AssignmentList(
            assignments: state.assignments,
            onItemTap: (assignment) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mo bai tap: ${assignment.title}')),
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
          create: (_) => CourseDetailBloc(StudentRepositoryImpl())
            ..add(CourseDetailStarted(enrollmentId)),
          child: const CourseDetailScreen(),
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - '
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
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
}
