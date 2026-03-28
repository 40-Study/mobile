import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/bloc/dashboard/teacher_dashboard_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<TeacherDashboardCubit, TeacherDashboardState>(
        builder: (context, state) {
          return switch (state) {
            TeacherDashboardInitial() || TeacherDashboardLoading() =>
              const Center(child: CircularProgressIndicator()),
            TeacherDashboardLoaded() => RefreshIndicator(
              onRefresh: context.read<TeacherDashboardCubit>().refresh,
              child: _DashboardContent(state: state),
            ),
            TeacherDashboardFailure(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppIconSize.hero,
                    color: cs.error,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(message),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: context
                        .read<TeacherDashboardCubit>()
                        .loadDashboard,
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

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final TeacherDashboardLoaded state;

  @override
  Widget build(BuildContext context) {
    // Calculate today's lessons
    final now = DateTime.now();
    final todaySchedules = state.schedules.where((s) {
      final dateTime = DateTime.tryParse(s.startTime);
      if (dateTime == null) return false;
      return dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day;
    }).toList();
    final unreadNotifications = state.notifications
        .where((n) => !n.isRead)
        .length;

    return SafeArea(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppLayout.dashboardPadding,
        children: [
          const _DashboardTopRow(roleLabel: 'Teacher Hub'),
          const SizedBox(height: AppSpacing.xl),
          _HeaderGreeting(
            teacherName: state.teacherName,
            dateString:
                'Hom nay ban co ${todaySchedules.length} buoi day '
                'va $unreadNotifications thong bao moi.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          _HeroMetricCard(
            title: 'DOANH THU THANG NAY',
            value: _formatCurrency(state.stats.monthlyRevenue),
            delta: '+${state.stats.completionRate.toStringAsFixed(1)}%',
            subtitle: 'completion rate',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniMetricCard(
                  icon: Icons.people_outline,
                  title: 'HOC VIEN',
                  value: state.stats.totalStudents.toString(),
                ),
              ),
              const SizedBox(width: AppLayout.gutter),
              Expanded(
                child: _MiniMetricCard(
                  icon: Icons.star_outline,
                  title: 'KHOA HOC',
                  value: state.stats.activeCourses.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          const _SectionHeader(
            title: 'Lich day hom nay',
            actionLabel: 'Xem tat ca',
          ),
          const SizedBox(height: AppSpacing.md),
          if (todaySchedules.isEmpty)
            const _EmptyCard(message: 'Khong co buoi hoc nao hom nay')
          else
            ...todaySchedules.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _TodayScheduleItem(schedule: s),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),

          const _SectionHeader(
            title: 'Lop hoc cua toi',
            actionLabel: 'Xem tat ca',
          ),
          const SizedBox(height: AppSpacing.md),
          _MyClassesHorizontalList(courses: state.courses),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _HeaderGreeting extends StatelessWidget {
  const _HeaderGreeting({required this.teacherName, required this.dateString});

  final String teacherName;
  final String dateString;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        style: tt.headlineSmall?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
        children: [
          const TextSpan(text: 'Chao buoi sang, '),
          TextSpan(
            text: teacherName,
            style: TextStyle(color: cs.primary),
          ),
          TextSpan(
            text: '\n$dateString',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double amount) {
  final normalized = amount.round();
  return '${NumberFormat.decimalPattern('vi_VN').format(normalized)}đ';
}

class _DashboardTopRow extends StatelessWidget {
  const _DashboardTopRow({required this.roleLabel});

  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: cs.primaryContainer,
          child: Icon(Icons.person_outline, color: cs.primary),
        ),
        const SizedBox(width: AppLayout.gutter),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roleLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const _TopIconButton(icon: Icons.search),
        const SizedBox(width: AppSpacing.sm),
        const _TopIconButton(icon: Icons.notifications_none_rounded),
      ],
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: AppIconSize.avatar,
      height: AppIconSize.avatar,
      decoration: BoxDecoration(
        color: cs.surfaceTintedPrimary,
        borderRadius: AppRadius.borderMd,
        boxShadow: cs.shadowCard,
      ),
      child: Icon(icon, color: cs.onSurfaceVariant, size: AppIconSize.md),
    );
  }
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({
    required this.title,
    required this.value,
    required this.delta,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String delta;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderXxxl,
        gradient: cs.gradientRich,
        boxShadow: cs.shadowPrimary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: cs.onPrimary.withValues(alpha: 0.7),
                    fontSize: 12,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  value,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: cs.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              delta,
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        color: cs.surfaceTintedPrimary,
        borderRadius: AppRadius.borderXxl,
        border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
        boxShadow: cs.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primaryContainer,
                  cs.primary.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, size: AppIconSize.md, color: cs.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel});

  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: cs.onSurface,
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          Text(
            actionLabel!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
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
        vertical: AppSpacing.xl + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.4),
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _TodayScheduleItem extends StatelessWidget {
  const _TodayScheduleItem({required this.schedule});

  final TeacherScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final dateTime = DateTime.tryParse(schedule.startTime);
    final timeStr = dateTime != null
        ? DateFormat('HH:mm').format(dateTime)
        : '';

    // Check if it's time to start (within 15 minutes of start time)
    final now = DateTime.now();
    final isNearStart =
        dateTime != null &&
        dateTime.difference(now).inMinutes <= 15 &&
        dateTime.difference(now).inMinutes >= -30;

    return Container(
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isNearStart
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time column
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: AppRadius.borderSm,
            ),
            child: Text(
              timeStr,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.courseName ?? 'Lop hoc',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  schedule.title,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (schedule.studentCount > 0) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: AppIconSize.xs,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${schedule.studentCount} hoc sinh',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppLayout.gutter),
          // Action button
          if (isNearStart)
            FilledButton(
              onPressed: () {
                // TODO: Start livestream
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text('Bat dau livestream'),
            )
          else
            OutlinedButton(
              onPressed: () {
                // TODO: Prepare lesson
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text('Chuan bi'),
            ),
        ],
      ),
    );
  }
}

class _MyClassesHorizontalList extends StatelessWidget {
  const _MyClassesHorizontalList({required this.courses});

  final List<CourseModel> courses;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.class_outlined,
              size: AppIconSize.hero,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Chua co lop hoc nao',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: courses.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppLayout.gutter),
        itemBuilder: (context, index) {
          final course = courses[index];
          return _ClassCard(course: course);
        },
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.course});

  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Status color and label
    Color statusColor;
    String statusLabel;
    switch (course.status.toLowerCase()) {
      case 'published':
      case 'active':
        statusColor = cs.tertiary;
        statusLabel = 'Dang hoat dong';
      case 'archived':
        statusColor = cs.onSurfaceVariant;
        statusLabel = 'Da luu tru';
      default:
        statusColor = cs.secondary;
        statusLabel = 'Ban nhap';
    }

    return Container(
      width: 200,
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class name
          Text(
            course.displayTitle,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Student count
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: AppIconSize.sm,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${course.studentCount} hoc sinh',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const Spacer(),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Text(
              statusLabel,
              style: tt.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
