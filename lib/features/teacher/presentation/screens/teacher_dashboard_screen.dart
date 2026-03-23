import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/teacher/bloc/dashboard/teacher_dashboard_cubit.dart';
import 'package:study/features/teacher/presentation/widgets/widgets.dart';

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
      backgroundColor: cs.surface,
      appBar: const TeacherAppBar(title: 'Giảng viên'),
      body: BlocBuilder<TeacherDashboardCubit, TeacherDashboardState>(
        builder: (context, state) {
          return switch (state) {
            TeacherDashboardInitial() ||
            TeacherDashboardLoading() =>
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
                    const SizedBox(height: 16),
                    Text(message),
                    const SizedBox(height: 16),
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

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Revenue chart
        RevenueChartCard(
          revenue: state.stats.monthlyRevenue,
          chartData: state.stats.revenueData,
        ),
        const SizedBox(height: 16),

        // Stats cards
        StatsCard(
          icon: Icons.people_outline,
          label: 'HỌC VIÊN MỚI',
          value: '+${state.stats.newStudents}',
        ),
        const SizedBox(height: 12),
        StatsCard(
          icon: Icons.check_circle_outline,
          label: 'TỶ LỆ HOÀN THÀNH',
          value: '${state.stats.completionRate.toStringAsFixed(1)}%',
        ),
        const SizedBox(height: 24),

        // Notifications section
        SectionHeader(
          title: 'Thông báo mới',
          actionLabel: 'XEM TẤT CẢ',
          onActionTap: () {},
        ),
        const SizedBox(height: 12),
        ...state.notifications.map(
          (n) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: NotificationListItem(notification: n),
          ),
        ),
        const SizedBox(height: 24),

        // Schedule section
        SectionHeader(
          title: 'Lịch dạy sắp tới',
          actionIcon: Icons.calendar_today_outlined,
          onActionTap: () {},
        ),
        const SizedBox(height: 12),
        ...state.schedules.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ScheduleCard(schedule: s),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
