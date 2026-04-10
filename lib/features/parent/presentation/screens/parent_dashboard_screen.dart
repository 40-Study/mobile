import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/bloc/children/children_selector_cubit.dart';
import 'package:study/features/parent/bloc/children/children_selector_state.dart';
import 'package:study/features/parent/bloc/parent_dashboard/parent_dashboard_cubit.dart';
import 'package:study/features/parent/bloc/parent_dashboard/parent_dashboard_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/screens/parent_main_screen.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
            color: cs.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Student Selector
        const StudentSelectorDropdown(),
        const SizedBox(height: AppSpacing.xl),

        // Student Overview Card
        BlocBuilder<ChildrenSelectorCubit, ChildrenSelectorState>(
          builder: (context, selectorState) {
            if (selectorState is ChildrenSelectorLoaded &&
                selectorState.selectedChild != null) {
              final child = selectorState.selectedChild!;
              return _StudentOverviewCard(child: child);
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Tuition Summary Card
        _TuitionSummaryCard(
          totalTuition: 15000000,
          paidAmount: 10000000,
          remainingAmount: 5000000,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Focus Chart
        const FocusChartCompact(),
        const SizedBox(height: AppSpacing.lg),

        // Schedule - tap to go to schedule tab
        GestureDetector(
          onTap: () {
            ParentMainScreen.switchToTab(context, ParentMainScreen.tabTracking);
          },
          child: const ChildScheduleCompact(),
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
                  color: cs.textSecondary,
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
      child: Icon(icon, color: cs.textSecondary, size: AppIconSize.md),
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
                      color: cs.textSecondary,
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
        ).textTheme.bodyMedium?.copyWith(color: cs.textSecondary),
      ),
    );
  }
}

class _StudentOverviewCard extends StatelessWidget {
  const _StudentOverviewCard({required this.child});

  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderXxl,
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: cs.shadowCard,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.primaryContainer,
                backgroundImage: child.avatarUrl != null
                    ? NetworkImage(child.avatarUrl!)
                    : null,
                child: child.avatarUrl == null
                    ? Icon(Icons.person, color: cs.primary)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
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
                    Text(
                      '${child.displayGrade} • ${child.displaySchool}',
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
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: 'Bài hoàn thành',
                  value: '12',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'Chưa hoàn thành',
                  value: '3',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: 'Chuyên cần',
                  value: child.attendancePercentage,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TuitionSummaryCard extends StatelessWidget {
  const _TuitionSummaryCard({
    required this.totalTuition,
    required this.paidAmount,
    required this.remainingAmount,
  });

  final double totalTuition;
  final double paidAmount;
  final double remainingAmount;

  String _formatCurrency(double amount) {
    final normalized = amount.round();
    return '${NumberFormat.decimalPattern('vi_VN').format(normalized)}đ';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = totalTuition > 0 ? paidAmount / totalTuition : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderXxl,
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: cs.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Học phí',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(cs.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã thanh toán',
                      style: TextStyle(
                        color: cs.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatCurrency(paidAmount),
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Còn lại',
                      style: TextStyle(
                        color: cs.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatCurrency(remainingAmount),
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

