import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/bloc/parent_dashboard/parent_dashboard_cubit.dart';
import 'package:study/features/parent/bloc/parent_dashboard/parent_dashboard_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/screens/child_detail_screen.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/widgets/section_header.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ParentDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
        builder: (context, state) {
          return switch (state) {
            ParentDashboardInitial() || ParentDashboardLoading() =>
              const Center(child: CircularProgressIndicator()),
            ParentDashboardLoaded() => RefreshIndicator(
              onRefresh: context.read<ParentDashboardCubit>().refresh,
              child: _DashboardContent(state: state),
            ),
            ParentDashboardFailure(:final message) => Center(
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
                        .read<ParentDashboardCubit>()
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

  final ParentDashboardLoaded state;

  void _navigateToChildDetail(BuildContext context, ChildModel child) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChildDetailScreen(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalClasses = state.children.fold<int>(
      0,
      (sum, child) => sum + child.classCount,
    );
    final averageAttendance = state.children.isEmpty
        ? 0
        : state.children
                  .map((child) => child.attendanceRate)
                  .reduce((a, b) => a + b) /
              state.children.length;
    final unreadNotifications = state.notifications
        .where((n) => !n.isRead)
        .length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppLayout.dashboardPadding,
      children: [
        const _DashboardTopRow(roleLabel: 'Parent Hub'),
        const SizedBox(height: AppSpacing.xl),
        RichText(
          text: TextSpan(
            style: textTheme.headlineSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
            children: [
              const TextSpan(text: 'Chao buoi sang, '),
              TextSpan(
                text: state.parentName,
                style: TextStyle(color: cs.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Hom nay ban co ${state.children.length} con dang theo doi '
          'va $unreadNotifications thong bao moi.',
          style: textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _HeroMetricCard(
          title: 'CHUYEN CAN TRUNG BINH',
          value: '${(averageAttendance * 100).toStringAsFixed(0)}%',
          delta: '+${unreadNotifications.toString()}',
          subtitle: 'thong bao chua doc',
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MiniMetricCard(
                icon: Icons.child_care_outlined,
                title: 'HOC SINH',
                value: state.children.length.toString(),
              ),
            ),
            const SizedBox(width: AppLayout.gutter),
            Expanded(
              child: _MiniMetricCard(
                icon: Icons.class_outlined,
                title: 'LOP HOC',
                value: totalClasses.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        const SectionHeader(
          title: 'Lop hoc cua con',
          actionLabel: 'Xem tat ca',
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.children.isEmpty)
          const _EmptyCard(message: 'Chua co du lieu hoc sinh')
        else
          ...state.children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ChildOverviewCard(
                child: child,
                onTap: () => _navigateToChildDetail(context, child),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),

        const SectionHeader(title: 'Thong bao moi', actionLabel: 'Xem tat ca'),
        const SizedBox(height: AppSpacing.sm),
        if (state.notifications.isEmpty)
          const _EmptyCard(message: 'Khong co thong bao moi')
        else
          ...state.notifications
              .take(4)
              .map(
                (notification) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _NotificationCard(notification: notification),
                ),
              ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
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
                '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
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
      width: 40,
      height: 40,
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
                  style: TextStyle(
                    color: cs.onPrimary.withValues(alpha: 0.7),
                  ),
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
              borderRadius: AppRadius.borderMd,
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

class _ChildOverviewCard extends StatelessWidget {
  const _ChildOverviewCard({required this.child, required this.onTap});

  final ChildModel child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: AppRadius.borderXxl,
      onTap: onTap,
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: cs.surfaceTintedPrimary,
          borderRadius: AppRadius.borderXxl,
          border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
          boxShadow: cs.shadowCard,
        ),
        child: Row(
          children: [
            Container(
              width: AppIconSize.hero,
              height: AppIconSize.hero,
              decoration: BoxDecoration(
                gradient: cs.gradientPrimary,
                borderRadius: AppRadius.borderMd,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.person_outline, color: cs.onPrimary),
            ),
            const SizedBox(width: AppLayout.gutter),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${child.displayGrade} • ${child.classCount} lop',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              child.attendancePercentage,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final ParentNotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: cs.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: notification.isRead
                  ? cs.surfaceContainerLow
                  : cs.primaryContainer,
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(
              notification.isRead
                  ? Icons.notifications_none
                  : Icons.notifications,
              size: AppIconSize.md,
              color: notification.isRead
                  ? cs.surfaceContainerHighest
                  : cs.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (notification.subtitle?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    notification.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
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
