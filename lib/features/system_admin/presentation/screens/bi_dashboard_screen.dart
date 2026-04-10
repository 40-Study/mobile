import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/theme/app_colors.dart';
import '../../bloc/dashboard/bi_dashboard_cubit.dart';
import '../../bloc/dashboard/bi_dashboard_state.dart';
import '../widgets/widgets.dart';

/// Màn hình Tổng quan BI Dashboard
class BIDashboardScreen extends StatelessWidget {
  const BIDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BIDashboardCubit()..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<BIDashboardCubit, BIDashboardState>(
        builder: (context, state) {
          if (state.status == BIDashboardStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BIDashboardStatus.failure) {
            return BIEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Không thể tải dữ liệu',
              subtitle: state.errorMessage,
              action: () => context.read<BIDashboardCubit>().loadDashboard(),
              actionLabel: 'Thử lại',
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<BIDashboardCubit>().loadDashboard(),
            child: CustomScrollView(
              slivers: [
                // Modern Header
                SliverToBoxAdapter(
                  child: BIAppHeader(
                    greeting: _getGreeting(),
                    userName: 'Admin',
                    title: 'Tổng quan kinh doanh',
                    subtitle: 'Theo dõi hiệu suất nền tảng',
                    notificationCount: state.alerts.length,
                    onNotificationTap: () {},
                    onAvatarTap: () {},
                  ),
                ),

                // Period selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'Thời gian',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: BIPeriodSelector(
                              periods: const ['7 ngày', '30 ngày', '90 ngày', '1 năm'],
                              selected: state.selectedPeriod.index,
                              onChanged: (index) {
                                context
                                    .read<BIDashboardCubit>()
                                    .changePeriod(TimePeriod.values[index]);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: _buildContent(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BIDashboardState state) {
    final metrics = state.metrics;
    if (metrics == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Hero revenue card
          BIHeroMetricCard(
            label: 'Tổng doanh thu',
            value: metrics.totalRevenue,
            trend: metrics.revenueGrowth,
            chartData: const [65, 78, 72, 85, 92, 88, 95, 102, 98, 110, 118, 125],
          ),

          const SizedBox(height: 16),

          // Key metrics grid
          Row(
            children: [
              Expanded(
                child: BIMetricCard(
                  label: 'EBITDA',
                  value: metrics.ebitda,
                  suffix: 'VND',
                  trend: 12.5,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BIMetricCard(
                  label: 'Lợi nhuận ròng',
                  value: metrics.netProfit,
                  suffix: 'VND',
                  trend: metrics.profitMargin,
                  icon: Icons.trending_up_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: BIMetricCard(
                  label: 'Số dư tiền mặt',
                  value: metrics.cashBalance,
                  suffix: 'VND',
                  icon: Icons.savings_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BIMetricCard(
                  label: 'Burn Rate',
                  value: metrics.burnRate,
                  suffix: '/tháng',
                  trend: -5.2,
                  trendUp: true,
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Investment & AI Section
          BISectionHeader(
            title: 'Đầu tư & AI',
            icon: Icons.auto_awesome_rounded,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: BIMetricCard(
                  label: 'Tổng đầu tư',
                  value: metrics.totalInvestment,
                  icon: Icons.account_balance_rounded,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BIMetricCard(
                  label: 'ROI trung bình',
                  value: metrics.averageRoi * 100,
                  suffix: '%',
                  trend: 8.5,
                  icon: Icons.show_chart_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: BIMetricCard(
                  label: 'Chi phí AI',
                  value: metrics.aiCost,
                  icon: Icons.memory_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BIMetricCard(
                  label: 'Doanh thu AI',
                  value: metrics.aiRevenue,
                  trend: 24.3,
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Top performing centers
          BISectionHeader(
            title: 'Trung tâm hoạt động tốt nhất',
            subtitle: 'Đóng góp doanh thu cao nhất',
            action: () {},
            actionLabel: 'Xem tất cả',
          ),

          const SizedBox(height: 12),

          ...state.topCenters.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CenterListCard(
                center: entry.value,
                showRank: true,
                rank: entry.key + 1,
                onTap: () {},
              ),
            );
          }),

          const SizedBox(height: 24),

          // Declining centers
          if (state.decliningCenters.isNotEmpty) ...[
            BISectionHeader(
              title: 'Cần chú ý',
              subtitle: 'Trung tâm có hiệu suất giảm',
              icon: Icons.warning_amber_rounded,
            ),

            const SizedBox(height: 12),

            ...state.decliningCenters.map((center) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CenterListCard(
                  center: center,
                  onTap: () {},
                ),
              );
            }),

            const SizedBox(height: 24),
          ],

          // Alerts
          if (state.alerts.isNotEmpty) ...[
            BISectionHeader(
              title: 'Cảnh báo gần đây',
              icon: Icons.notifications_active_rounded,
              action: () {},
              actionLabel: 'Xem tất cả',
            ),

            const SizedBox(height: 12),

            ...state.alerts.map((alert) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BIAlertCard(
                  alert: alert,
                  onTap: () {},
                ),
              );
            }),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
