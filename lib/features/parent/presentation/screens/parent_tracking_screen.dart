import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/bloc/children/children_selector_cubit.dart';
import 'package:study/features/parent/bloc/children/children_selector_state.dart';
import 'package:study/features/parent/bloc/tracking/parent_tracking_cubit.dart';
import 'package:study/features/parent/bloc/tracking/parent_tracking_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/theme/app_colors.dart';

class ParentTrackingScreen extends StatefulWidget {
  const ParentTrackingScreen({super.key});

  @override
  State<ParentTrackingScreen> createState() => _ParentTrackingScreenState();
}

class _ParentTrackingScreenState extends State<ParentTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  void _loadData() {
    final selectedChild = context.read<ChildrenSelectorCubit>().selectedChild;
    if (selectedChild != null) {
      context.read<ParentTrackingCubit>().loadTracking(selectedChild.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Student Selector
            Padding(
              padding: const EdgeInsets.all(AppLayout.screenMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theo dõi học tập',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const StudentSelectorDropdown(),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: cs.primary,
                unselectedLabelColor: cs.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(text: 'Tap trung'),
                  Tab(text: 'Lich hoc'),
                  Tab(text: 'Bai tap'),
                  Tab(text: 'Ket qua'),
                  Tab(text: 'Diem danh'),
                  Tab(text: 'Giao vien'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tab Content
            Expanded(
              child: BlocListener<ChildrenSelectorCubit, ChildrenSelectorState>(
                listener: (context, state) {
                  if (state is ChildrenSelectorLoaded && state.selectedChild != null) {
                    context.read<ParentTrackingCubit>().loadTracking(state.selectedChild!.id);
                  }
                },
                child: BlocBuilder<ParentTrackingCubit, ParentTrackingState>(
                  builder: (context, state) {
                    return switch (state) {
                      ParentTrackingInitial() || ParentTrackingLoading() =>
                        const Center(child: CircularProgressIndicator()),
                      ParentTrackingLoaded() => TabBarView(
                          controller: _tabController,
                          children: [
                            _FocusTrackingTab(focusTracking: state.focusTracking),
                            const _ScheduleTab(),
                            _AssignmentProgressTab(progress: state.assignmentProgress),
                            _PerformanceTab(performance: state.performanceOverview),
                            _AttendanceTab(attendance: state.attendanceSummary),
                            _TeacherInfoTab(teacher: state.teacherInfo),
                          ],
                        ),
                      ParentTrackingFailure(:final message) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: cs.error),
                              const SizedBox(height: AppSpacing.lg),
                              Text(message),
                              const SizedBox(height: AppSpacing.lg),
                              FilledButton(
                                onPressed: _loadData,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                    };
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusTrackingTab extends StatelessWidget {
  const _FocusTrackingTab({required this.focusTracking});

  final FocusTrackingModel focusTracking;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Điểm TB',
                value: '${focusTracking.averageFocus.toStringAsFixed(1)}%',
                icon: Icons.psychology,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MetricCard(
                title: 'Tổng buổi',
                value: focusTracking.totalSessions.toString(),
                icon: Icons.event,
                color: cs.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Best & Worst Session
        if (focusTracking.bestSession != null) ...[
          _SessionHighlightCard(
            title: 'Buổi tốt nhất',
            session: focusTracking.bestSession!,
            isPositive: true,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (focusTracking.worstSession != null) ...[
          _SessionHighlightCard(
            title: 'Buổi cần cải thiện',
            session: focusTracking.worstSession!,
            isPositive: false,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Focus Chart
        FocusChart(
          sessions: focusTracking.sessions,
          height: 260,
          showFilters: true,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Session List
        Text(
          'Lịch sử các buổi học',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...focusTracking.sessions.map(
          (session) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _FocusSessionCard(session: session),
          ),
        ),
      ],
    );
  }
}

class _AssignmentProgressTab extends StatelessWidget {
  const _AssignmentProgressTab({required this.progress});

  final AssignmentProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Summary
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Tổng bài',
                value: progress.totalAssignments.toString(),
                icon: Icons.assignment,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MetricCard(
                title: 'Hoàn thành',
                value: progress.completedCount.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MetricCard(
                title: 'Thiếu',
                value: progress.missingCount.toString(),
                icon: Icons.cancel,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Assignment List
        Text(
          'Chi tiết bài tập',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (progress.assignments.isEmpty)
          const _EmptyCard(message: 'Chưa có bài tập')
        else
          ...progress.assignments.map(
            (assignment) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AssignmentCard(assignment: assignment),
            ),
          ),
      ],
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  const _PerformanceTab({required this.performance});

  final PerformanceOverviewModel performance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Summary
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Điểm TB',
                value: performance.averageScore.toStringAsFixed(1),
                icon: Icons.grade,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MetricCard(
                title: 'Cao nhất',
                value: performance.highestScore.toStringAsFixed(1),
                icon: Icons.arrow_upward,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MetricCard(
                title: 'Thấp nhất',
                value: performance.lowestScore.toStringAsFixed(1),
                icon: Icons.arrow_downward,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Performance List
        Text(
          'Điểm từng bài',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (performance.performances.isEmpty)
          const _EmptyCard(message: 'Chưa có kết quả')
        else
          ...performance.performances.map(
            (perf) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: PerformanceCard(performance: perf),
            ),
          ),
      ],
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab({required this.attendance});

  final AttendanceSummaryModel attendance;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: cs.gradientPrimary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                '${(attendance.attendanceRate * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Tỷ lệ chuyên cần',
                style: TextStyle(
                  color: cs.onPrimary.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Stats Grid
        Row(
          children: [
            Expanded(
              child: _AttendanceStatCard(
                label: 'Có mặt',
                value: attendance.presentCount,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _AttendanceStatCard(
                label: 'Vắng',
                value: attendance.absentCount,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _AttendanceStatCard(
                label: 'Muộn',
                value: attendance.lateCount,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _AttendanceStatCard(
                label: 'Có phép',
                value: attendance.excusedCount,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TeacherInfoTab extends StatelessWidget {
  const _TeacherInfoTab({this.teacher});

  final TeacherInfoModel? teacher;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (teacher == null) {
      return const Center(
        child: _EmptyCard(message: 'Chưa có thông tin giáo viên'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Teacher Profile Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: cs.primaryContainer,
                backgroundImage: teacher!.avatarUrl != null
                    ? NetworkImage(teacher!.avatarUrl!)
                    : null,
                child: teacher!.avatarUrl == null
                    ? Icon(Icons.person, size: 48, color: cs.primary)
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                teacher!.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (teacher!.specialization != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  teacher!.specialization!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.textSecondary,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (teacher!.yearsOfExperience != null)
                _TeacherInfoRow(
                  icon: Icons.work_outline,
                  label: 'Kinh nghiệm',
                  value: '${teacher!.yearsOfExperience} năm',
                ),
              if (teacher!.email != null)
                _TeacherInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: teacher!.email!,
                ),
              if (teacher!.phone != null)
                _TeacherInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Điện thoại',
                  value: teacher!.phone!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Helper Widgets
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: TextStyle(
              color: cs.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionHighlightCard extends StatelessWidget {
  const _SessionHighlightCard({
    required this.title,
    required this.session,
    required this.isPositive,
  });

  final String title;
  final FocusSessionModel session;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isPositive ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPositive ? Icons.emoji_events : Icons.trending_down,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  session.className,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  session.date,
                  style: TextStyle(
                    color: cs.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${session.focusScore.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusSessionCard extends StatelessWidget {
  const _FocusSessionCard({required this.session});

  final FocusSessionModel session;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final focusColor = session.focusScore >= 80
        ? Colors.green
        : session.focusScore >= 60
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: focusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${session.focusScore.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: focusColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.className,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${session.date} • ${session.durationMinutes} phút',
                  style: TextStyle(
                    color: cs.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceStatCard extends StatelessWidget {
  const _AttendanceStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: cs.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherInfoRow extends StatelessWidget {
  const _TeacherInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: cs.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.textSecondary,
            ),
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppLayout.screenMargin),
      child: ChildSchedule(),
    );
  }
}
