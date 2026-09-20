import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_cubit.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_state.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_bloc.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_event.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key, this.parentName});

  final String? parentName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentDashboardBloc, ParentDashboardState>(
      builder: (context, state) {
        return switch (state) {
          ParentDashboardInitial() || ParentDashboardLoading() =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
          ParentDashboardFailure(:final message) =>
            _ErrorView(message: message),
          ParentDashboardSuccess(
            :final alerts,
            :final childOverviews,
            :final monthlyStats,
            :final schedule,
            :final courses,
          ) =>
            _DashboardContent(
              parentName: parentName,
              alerts: alerts,
              childOverviews: childOverviews,
              monthlyStats: monthlyStats,
              schedule: schedule,
              courses: courses,
            ),
        };
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreenAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync_problem, size: 48, color: cs.error),
            AppSpacing.vGap16,
            Text('Không thể tải dữ liệu', style: tt.titleMedium),
            AppSpacing.vGap4,
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: () => context
                  .read<ParentDashboardBloc>()
                  .add(ParentDashboardRefreshed()),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    this.parentName,
    required this.alerts,
    required this.childOverviews,
    required this.monthlyStats,
    required this.schedule,
    required this.courses,
  });

  final String? parentName;
  final List<ParentAlertModel> alerts;
  final List<ChildOverviewModel> childOverviews;
  final MonthlyStats monthlyStats;
  final List<ChildScheduleModel> schedule;
  final List<ChildCourseModel> courses;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ParentDashboardBloc>().add(ParentDashboardRefreshed());
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Top section - Greeting + Child card
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.md,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${_getDisplayName(parentName)} 👋',
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Cùng theo dõi hành trình học tập của con nhé!',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                AppSpacing.vGap12,
                BlocBuilder<ChildSelectorCubit, ChildSelectorState>(
                  builder: (context, state) {
                    final child =
                        state.selectedChild ?? state.children.firstOrNull;
                    if (child == null) return const SizedBox.shrink();
                    return _ChildCard(
                      child: child,
                      onTap: () => _showChildPicker(context, state.children),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom section - Cards với background
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
              children: [
                // Next lesson card
                _NextLessonCard(
                  schedule: schedule.isNotEmpty ? schedule.first : null,
                ),
                AppSpacing.vGap12,

                // Two cards row: Progress + Attendance
                BlocBuilder<ChildSelectorCubit, ChildSelectorState>(
                  builder: (context, state) {
                    final child =
                        state.selectedChild ?? state.children.firstOrNull;
                    if (child == null) return const SizedBox.shrink();
                    final overview = childOverviews
                        .where((o) => o.childId == child.id)
                        .firstOrNull;
                    final nextLesson =
                        schedule.isNotEmpty ? schedule.first : null;
                    final course = _findMatchingCourse(courses, nextLesson);
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _ProgressCard(course: course)),
                          AppSpacing.hGap12,
                          Expanded(
                            child: _AttendanceCard(
                              rate: overview?.attendanceRate ?? 0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                AppSpacing.vGap12,

                // Tuition card
                _TuitionCard(
                  amount: 600000,
                  courseName: 'Khoá Python cơ bản',
                  onPayTap: () {},
                ),
                AppSpacing.vGap12,

                // Suggestion card
                const _SuggestionCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Match course với schedule theo keyword trong tên
  ChildCourseModel? _findMatchingCourse(
    List<ChildCourseModel> courses,
    ChildScheduleModel? schedule,
  ) {
    if (courses.isEmpty) return null;
    if (schedule == null) return courses.first;

    final className = (schedule.className ?? '').toLowerCase();
    if (className.isEmpty) return courses.first;

    // Extract keywords từ class name (bỏ "lop", "k1", số)
    final keywords = className
        .replaceAll(RegExp(r'lop|lớp|\d+|k\d+', caseSensitive: false), '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();

    if (keywords.isEmpty) return courses.first;

    // Tìm course có chứa keyword
    for (final course in courses) {
      final courseName = course.courseName.toLowerCase();
      for (final keyword in keywords) {
        if (courseName.contains(keyword)) {
          return course;
        }
      }
    }

    return courses.first;
  }

  String _getDisplayName(String? name) {
    if (name == null || name.trim().isEmpty) return 'bạn';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return 'anh ${parts.last}';
    }
    return parts.last;
  }

  void _showChildPicker(BuildContext context, List<ChildModel> children) {
    if (children.length <= 1) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Chọn con',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            ...children.map((child) => ListTile(
                  leading: CircleAvatar(
                    child: Text(child.fullName[0].toUpperCase()),
                  ),
                  title: Text(child.fullName),
                  onTap: () {
                    context.read<ChildSelectorCubit>().select(child);
                    Navigator.pop(ctx);
                  },
                )),
            AppSpacing.vGap16,
          ],
        ),
      ),
    );
  }
}

// Child card - matches mockup
class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, this.onTap});

  final ChildModel child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: child.avatarUrl != null
                      ? NetworkImage(child.avatarUrl!)
                      : null,
                  child: child.avatarUrl == null
                      ? Text(
                          child.fullName[0].toUpperCase(),
                          style: tt.titleLarge?.copyWith(color: cs.primary),
                        )
                      : null,
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.fullName,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        child.className ?? 'Học sinh',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Next lesson card - matches mockup "Buổi học tiếp theo"
class _NextLessonCard extends StatelessWidget {
  const _NextLessonCard({this.schedule});

  final ChildScheduleModel? schedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final timeRemaining =
        schedule != null ? _formatTimeRemaining(schedule!) : 'Chưa có lịch';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.calendar_today, size: 20, color: cs.primary),
              ),
              AppSpacing.hGap12,
              Text(
                'Buổi học tiếp theo',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (schedule != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: TogetherSemanticColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    timeRemaining,
                    style: tt.labelSmall?.copyWith(
                      color: TogetherSemanticColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.vGap12,
          if (schedule != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.school, size: 24, color: cs.primary),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule!.className?.isNotEmpty == true
                            ? schedule!.className!
                            : schedule!.topic,
                        style:
                            tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (schedule!.topic.isNotEmpty &&
                          schedule!.className?.isNotEmpty == true)
                        Text(
                          schedule!.topic,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      AppSpacing.vGap4,
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: _formatDate(schedule!.date),
                      ),
                      _InfoRow(
                        icon: Icons.access_time,
                        text: _formatTimeRange(
                            schedule!.startTime, schedule!.endTime),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    side: BorderSide(color: cs.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Xem lịch học',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppSpacing.hGap4,
                      Icon(Icons.arrow_forward, size: 14, color: cs.onSurface),
                    ],
                  ),
                ),
              ],
            )
          else
            Center(
              child: Text(
                'Chưa có buổi học nào sắp tới',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimeRemaining(ChildScheduleModel s) {
    final timeParts = s.startTime.split(':');
    final startDateTime = DateTime(
      s.date.year,
      s.date.month,
      s.date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    final now = DateTime.now();
    final diff = startDateTime.difference(now);
    if (diff.isNegative) return 'Đang diễn ra';
    if (diff.inDays > 0) return 'Còn ${diff.inDays} ngày';
    if (diff.inHours > 0) return 'Còn ${diff.inHours} giờ';
    return 'Còn ${diff.inMinutes} phút';
  }

  String _formatDate(DateTime date) {
    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final idx = date.weekday == 7 ? 0 : date.weekday;
    return '${weekdays[idx]}, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTimeRange(String start, String end) {
    // start/end format: "19:00:00"
    return '${start.substring(0, 5)} - ${end.substring(0, 5)}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          AppSpacing.hGap4,
          Text(text, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// Progress card - "Tiến độ khoá học"
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({this.course});

  final ChildCourseModel? course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final progress = course?.progressPercent ?? 0;
    final courseName = course?.courseName ?? 'Chưa có khoá học';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.trending_up, size: 16, color: cs.primary),
              ),
              AppSpacing.hGap8,
              Expanded(
                child: Text(
                  'Tiến độ khoá học',
                  style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          Text(
            courseName,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          AppSpacing.vGap8,
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
              ),
              AppSpacing.hGap8,
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          AppSpacing.vGap8,
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Text(
              'Xem chi tiết',
              style: tt.labelSmall?.copyWith(color: cs.primary),
            ),
            label: Icon(Icons.arrow_forward, size: 14, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

// Attendance card - "Điểm danh" (thay cho "Mức độ tập trung")
class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: TogetherSemanticColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: TogetherSemanticColors.success,
                ),
              ),
              AppSpacing.hGap8,
              Expanded(
                child: Text(
                  'Điểm danh',
                  style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.bar_chart, size: 20, color: cs.onSurfaceVariant),
            ],
          ),
          AppSpacing.vGap16,
          Text(
            '${rate.toStringAsFixed(0)}%',
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.vGap4,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: TogetherSemanticColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '↑ 5% so với tuần trước',
              style: tt.labelSmall?.copyWith(
                color: TogetherSemanticColors.success,
              ),
            ),
          ),
          AppSpacing.vGap12,
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Text(
              'Xem chi tiết',
              style: tt.labelSmall?.copyWith(color: cs.primary),
            ),
            label: Icon(Icons.arrow_forward, size: 14, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

// Tuition card - "Học phí" (pink/red background)
class _TuitionCard extends StatelessWidget {
  const _TuitionCard({
    required this.amount,
    required this.courseName,
    this.onPayTap,
  });

  final double amount;
  final String courseName;
  final VoidCallback? onPayTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFFCA5A5).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFFCA5A5),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 20,
              color: Color(0xFFDC2626),
            ),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Học phí',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                RichText(
                  text: TextSpan(
                    style: tt.bodySmall?.copyWith(color: Colors.black87),
                    children: [
                      const TextSpan(text: 'Còn '),
                      TextSpan(
                        text: _formatCurrency(amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const TextSpan(text: ' chưa thanh toán'),
                    ],
                  ),
                ),
                Text(
                  courseName,
                  style: tt.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onPayTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thanh toán ngay',
                  style: tt.labelSmall?.copyWith(color: Colors.white),
                ),
                AppSpacing.hGap4,
                const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '${formatted}đ';
  }
}

// Suggestion card - "Gợi ý cho con"
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ABFC).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Text('✨', style: TextStyle(fontSize: 14)),
              ),
              AppSpacing.hGap8,
              Text(
                'Gợi ý cho con',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          AppSpacing.vGap12,

          // Course suggestion
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course image
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF3776AB),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Center(
                  child: Text('🐍', style: TextStyle(fontSize: 32)),
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Python nâng cao',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TogetherSemanticColors.success
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'Phù hợp nhất',
                            style: tt.labelSmall?.copyWith(
                              color: TogetherSemanticColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap4,
                    Text(
                      'Tiếp nối Python cơ bản, giúp con phát triển kỹ năng lập trình chuyên sâu hơn.',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGap8,
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14, color: cs.onSurfaceVariant),
                        AppSpacing.hGap4,
                        Text(
                          '24 buổi',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        AppSpacing.hGap12,
                        Icon(Icons.payments_outlined,
                            size: 14, color: cs.onSurfaceVariant),
                        AppSpacing.hGap4,
                        Text(
                          '3.600.000đ',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
          AppSpacing.vGap12,

          // View course link
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Text(
                'Xem khoá học',
                style: tt.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              label: Icon(Icons.arrow_forward, size: 16, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}
