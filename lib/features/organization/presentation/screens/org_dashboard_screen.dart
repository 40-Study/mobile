import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/organization/bloc/dashboard/org_dashboard_cubit.dart';
import 'package:study/features/organization/data/models/models.dart';
import 'package:study/features/organization/presentation/screens/organization_main_screen.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/widgets/section_header.dart';

class OrgDashboardScreen extends StatefulWidget {
  const OrgDashboardScreen({super.key});

  @override
  State<OrgDashboardScreen> createState() => _OrgDashboardScreenState();
}

class _OrgDashboardScreenState extends State<OrgDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrgDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<OrgDashboardCubit, OrgDashboardState>(
        builder: (context, state) {
          return switch (state) {
            OrgDashboardInitial() || OrgDashboardLoading() =>
              const Center(child: CircularProgressIndicator()),
            OrgDashboardLoaded() => RefreshIndicator(
                onRefresh: context.read<OrgDashboardCubit>().refresh,
                child: _DashboardContent(state: state),
              ),
            OrgDashboardFailure(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: AppSpacing.lg),
                    Text(message),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: context.read<OrgDashboardCubit>().loadDashboard,
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

  final OrgDashboardLoaded state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          // Header
          _Header(
            organizationName: state.organizationName,
            avatarUrl: state.avatarUrl,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Cash Flow Overview Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _CashFlowCard(stats: state.stats),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Quick Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _QuickCashFlowStats(stats: state.stats),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Finance Alerts
          if (state.financeAlerts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
              child: SectionHeader(
                title: 'Canh bao tai chinh',
                actionLabel: '${state.financeAlerts.length} canh bao',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...state.financeAlerts.take(3).map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppLayout.screenMargin,
                      right: AppLayout.screenMargin,
                      bottom: AppSpacing.sm,
                    ),
                    child: _AlertCard(alert: alert),
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Top Revenue Courses
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: SectionHeader(
              title: 'Khoa hoc doanh thu cao',
              actionLabel: 'Xem tat ca',
              onActionTap: () {},
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.topCourses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
              child: _EmptyCard(message: 'Chua co du lieu doanh thu'),
            )
          else
            ...state.topCourses.take(3).map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppLayout.screenMargin,
                      right: AppLayout.screenMargin,
                      bottom: AppSpacing.sm,
                    ),
                    child: _CourseRevenueCard(course: course),
                  ),
                ),
          const SizedBox(height: AppSpacing.xl),

          // Top Revenue Teachers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: SectionHeader(
              title: 'Giao vien doanh thu cao',
              actionLabel: 'Xem tat ca',
              onActionTap: () {
                OrganizationMainScreen.switchToTab(
                  context,
                  OrganizationMainScreen.tabTeachers,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.topTeachers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
              child: _EmptyCard(message: 'Chua co du lieu doanh thu'),
            )
          else
            ...state.topTeachers.take(3).map(
                  (teacher) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppLayout.screenMargin,
                      right: AppLayout.screenMargin,
                      bottom: AppSpacing.sm,
                    ),
                    child: _TeacherRevenueCard(teacher: teacher),
                  ),
                ),
          const SizedBox(height: AppSpacing.xl),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _QuickActionsCard(),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.organizationName, this.avatarUrl});

  final String organizationName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.lg,
        AppLayout.screenMargin,
        0,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.primaryContainer,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(Icons.domain, color: cs.primary, size: 28)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quan ly dong tien',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                ),
                Text(
                  organizationName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              OrganizationMainScreen.switchToTab(
                context,
                OrganizationMainScreen.tabFinance,
              );
            },
            icon: Badge(
              smallSize: 8,
              child: Icon(Icons.account_balance_wallet_outlined, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _CashFlowCard extends StatelessWidget {
  const _CashFlowCard({required this.stats});

  final OrgStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isProfit = stats.netProfit >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isProfit
              ? [const Color(0xFF059669), const Color(0xFF10B981)]
              : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isProfit ? Colors.green : Colors.red).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loi nhuan thang nay',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${stats.profitMargin.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _formatCurrency(stats.netProfit),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Income vs Expense
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _CashFlowStatItem(
                    icon: Icons.arrow_downward_rounded,
                    iconColor: Colors.greenAccent,
                    label: 'Tong thu',
                    value: _formatCurrency(stats.totalIncome),
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _CashFlowStatItem(
                    icon: Icons.arrow_upward_rounded,
                    iconColor: Colors.redAccent.shade100,
                    label: 'Tong chi',
                    value: _formatCurrency(stats.totalExpense),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final normalized = amount.round();
    return '${NumberFormat.decimalPattern('vi_VN').format(normalized)}d';
  }
}

class _CashFlowStatItem extends StatelessWidget {
  const _CashFlowStatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickCashFlowStats extends StatelessWidget {
  const _QuickCashFlowStats({required this.stats});

  final OrgStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.schedule,
            iconColor: Colors.orange,
            label: 'Cho thanh toan',
            value: _formatShortCurrency(stats.pendingPayments),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.trending_up,
            iconColor: Colors.green,
            label: 'Tang truong',
            value: '+${stats.revenueChangePercent.toStringAsFixed(1)}%',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.people_outline,
            iconColor: cs.primary,
            label: 'Hoc vien moi',
            value: '+${stats.newStudentsThisMonth}',
          ),
        ),
      ],
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: cs.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final FinanceAlertModel alert;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bgColor, iconColor, icon) = switch (alert.severity) {
      FinanceAlertSeverity.critical => (
          Colors.red.withValues(alpha: 0.1),
          Colors.red,
          Icons.error_outline,
        ),
      FinanceAlertSeverity.warning => (
          Colors.orange.withValues(alpha: 0.1),
          Colors.orange,
          Icons.warning_amber_rounded,
        ),
      FinanceAlertSeverity.info => (
          cs.primaryContainer.withValues(alpha: 0.5),
          cs.primary,
          Icons.info_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseRevenueCard extends StatelessWidget {
  const _CourseRevenueCard({required this.course});

  final CourseRevenueModel course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPositive = course.revenueChange >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: course.isTrending
              ? Colors.green.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Rank/Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: course.isTrending
                  ? const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    )
                  : null,
              color: course.isTrending ? null : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              course.isTrending ? Icons.trending_up : Icons.school_outlined,
              color: course.isTrending ? Colors.white : cs.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${course.teacherName} • ${course.totalStudents} hoc vien',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Revenue
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatShortCurrency(course.totalRevenue),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: cs.onSurface,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${course.revenueChange.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '${amount.toStringAsFixed(0)}d';
  }
}

class _TeacherRevenueCard extends StatelessWidget {
  const _TeacherRevenueCard({required this.teacher});

  final TeacherRevenueModel teacher;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPositive = teacher.revenueChange >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: teacher.isTopPerformer
              ? Colors.amber.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.primaryContainer,
                backgroundImage: teacher.avatarUrl != null
                    ? NetworkImage(teacher.avatarUrl!)
                    : null,
                child: teacher.avatarUrl == null
                    ? Text(
                        teacher.teacherName.isNotEmpty
                            ? teacher.teacherName[0].toUpperCase()
                            : 'T',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              if (teacher.isTopPerformer)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.star, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.teacherName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${teacher.totalCourses} khoa hoc • ${teacher.totalStudents} hoc vien',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Revenue & Pending
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatShortCurrency(teacher.totalRevenue),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: cs.onSurface,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${teacher.revenueChange.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '${amount.toStringAsFixed(0)}d';
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hanh dong nhanh',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.payments_outlined,
                  label: 'Thanh toan',
                  color: Colors.green,
                  onTap: () {
                    OrganizationMainScreen.switchToTab(
                      context,
                      OrganizationMainScreen.tabFinance,
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.analytics_outlined,
                  label: 'Bao cao',
                  color: cs.primary,
                  onTap: () {
                    OrganizationMainScreen.switchToTab(
                      context,
                      OrganizationMainScreen.tabFinance,
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Tao khoa hoc',
                  color: Colors.orange,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
