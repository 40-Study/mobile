import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/bloc/dashboard/teacher_dashboard_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/presentation/screens/teacher_main_screen.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/widgets/section_header.dart';

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
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: AppSpacing.lg),
                    Text(message),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed:
                          context.read<TeacherDashboardCubit>().loadDashboard,
                      child: const Text('Thử lại'),
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
    final now = DateTime.now();
    final todaySchedules = state.schedules.where((s) {
      final dateTime = DateTime.tryParse(s.startTime);
      if (dateTime == null) return false;
      return dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day;
    }).toList();

    return SafeArea(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          // Header
          _Header(
            teacherName: state.teacherName,
            avatarUrl: state.avatarUrl,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Wallet Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _WalletCard(wallet: state.wallet),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Quick Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _QuickStatsRow(stats: state.stats),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Today's Schedule
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: SectionHeader(
              title: 'Lịch dạy hôm nay',
              actionLabel: 'Xem tất cả',
              onActionTap: () {
                TeacherMainScreen.switchToTab(context, TeacherMainScreen.tabActions);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (todaySchedules.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
              child: _EmptyCard(message: 'Không có buổi học nào hôm nay'),
            )
          else
            ...todaySchedules.take(2).map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppLayout.screenMargin,
                      right: AppLayout.screenMargin,
                      bottom: AppSpacing.md,
                    ),
                    child: _ScheduleCard(schedule: s),
                  ),
                ),
          const SizedBox(height: AppSpacing.lg),

          // Pending Assignments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: SectionHeader(
              title: 'Bài tập chờ xử lý',
              actionLabel: 'Xem tất cả',
              onActionTap: () {
                TeacherMainScreen.switchToTab(context, TeacherMainScreen.tabActions);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.pendingAssignments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
              child: _EmptyCard(message: 'Không có bài tập chờ chấm'),
            )
          else
            ...state.pendingAssignments.take(3).map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppLayout.screenMargin,
                      right: AppLayout.screenMargin,
                      bottom: AppSpacing.sm,
                    ),
                    child: _AssignmentCard(assignment: a),
                  ),
                ),
          const SizedBox(height: AppSpacing.xxl),

          // Recent Activities Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _SectionCard(
              title: 'Hoạt động gần đây',
              actionLabel: 'Xem tất cả',
              onActionTap: () {},
              child: Column(
                children: state.activities
                    .take(3)
                    .map((a) => _ActivityItem(activity: a))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.teacherName, this.avatarUrl});

  final String teacherName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final iconBgColor = cs.surfaceContainerHighest;

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
            backgroundColor: iconBgColor,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(Icons.person, color: textColor, size: 28)
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Chào $teacherName!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Badge(
              smallSize: 8,
              child: Icon(Icons.notifications_outlined, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.wallet});

  final TeacherWalletModel wallet;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: cs.gradientRich,
        boxShadow: cs.shadowPrimary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số dư khả dụng',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatCurrency(wallet.balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (wallet.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'ACCOUNT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Monthly income
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng thu nhập tháng này',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '+${_formatCurrency(wallet.monthlyIncome)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.trending_up,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          Builder(
            builder: (context) => Row(
              children: [
                Expanded(
                  child: _WalletButton(
                    label: 'Rút tiền',
                    isPrimary: false,
                    onTap: () {
                      TeacherMainScreen.switchToTab(
                        context,
                        TeacherMainScreen.tabRevenue,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _WalletButton(
                    label: 'Chi tiết',
                    isPrimary: true,
                    onTap: () {
                      TeacherMainScreen.switchToTab(
                        context,
                        TeacherMainScreen.tabRevenue,
                      );
                    },
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
    return '${NumberFormat.decimalPattern('vi_VN').format(normalized)}đ';
  }
}

class _WalletButton extends StatelessWidget {
  const _WalletButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? Colors.white.withValues(alpha: 0.25)
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.white : const Color(0xFF3B5BDB),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.stats});

  final TeacherStatsModel stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.people_outline,
            label: 'Học viên mới',
            value: stats.newStudents.toString(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.shopping_cart_outlined,
            label: 'Đơn hàng',
            value: '42',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.play_circle_outline,
            label: 'Live Stream',
            value: '8.2M',
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
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
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cs.primary, size: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
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

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});

  final TeacherScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateTime = DateTime.tryParse(schedule.startTime);
    final timeStr =
        dateTime != null ? DateFormat('HH:mm').format(dateTime) : '';
    final period = dateTime != null && dateTime.hour >= 12 ? 'PM' : 'AM';

    final now = DateTime.now();
    final isNearStart = dateTime != null &&
        dateTime.difference(now).inMinutes <= 30 &&
        dateTime.difference(now).inMinutes >= -15;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNearStart
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Time
          Column(
            children: [
              Text(
                timeStr,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Container(
            width: 1,
            height: 40,
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.courseName ?? schedule.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (schedule.studentCount > 0) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${schedule.studentCount} Học viên',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Action button
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: isNearStart ? cs.primary : cs.primaryContainer,
              foregroundColor: isNearStart ? cs.onPrimary : cs.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(isNearStart ? 'Vào lớp' : 'Chuẩn bị'),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment});

  final PendingAssignmentModel assignment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primaryContainer,
            backgroundImage: assignment.studentAvatar != null
                ? NetworkImage(assignment.studentAvatar!)
                : null,
            child: assignment.studentAvatar == null
                ? Text(
                    assignment.studentName.isNotEmpty
                        ? assignment.studentName[0].toUpperCase()
                        : 'S',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.studentName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assignment.assignmentTitle,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(color: cs.primary),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Chấm bài'),
          ),
        ],
      ),
    );
  }
}


class _ActivityItem extends StatelessWidget {
  const _ActivityItem({required this.activity});

  final TeacherActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final iconColor = switch (activity.type) {
      ActivityType.withdrawal => Colors.green,
      ActivityType.newStudent => cs.primary,
      ActivityType.coursePurchase => Colors.orange,
      ActivityType.review => Colors.amber,
      ActivityType.livestream => Colors.red,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                if (activity.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.subtitle!,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  activity.createdAt,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
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
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
              ),
              if (actionLabel != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}
