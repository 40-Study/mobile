import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/widgets/simple_gradient_background.dart';
import '../../data/models/bi_models.dart';
import '../widgets/widgets.dart';

/// Center Insight Detail Screen - NO MANAGEMENT FEATURES
class BICenterInsightScreen extends StatefulWidget {
  const BICenterInsightScreen({
    super.key,
    required this.centerId,
    this.centerName,
  });

  final String centerId;
  final String? centerName;

  @override
  State<BICenterInsightScreen> createState() => _BICenterInsightScreenState();
}

class _BICenterInsightScreenState extends State<BICenterInsightScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - replace with actual API call
  final _insight = CenterInsight(
    centerId: '1',
    centerName: 'Elite Academy',
    revenueContribution: 580000000,
    revenuePercentage: 23.7,
    revenueTrend: List.generate(
      12,
      (i) => RevenueDataPoint(
        date: DateTime.now().subtract(Duration(days: (11 - i) * 30)),
        value: 380000000 + (i * 18000000) + (i % 3 * 5000000),
      ),
    ),
    financial: const FinancialBreakdown(
      revenue: 580000000,
      aiCost: 38000000,
      infrastructureCost: 25000000,
      supportCost: 15000000,
      otherCosts: 12000000,
      ebitda: 145000000,
      netProfit: 116000000,
    ),
    investment: const InvestmentAnalysis(
      marketingSpend: 85000000,
      aiCost: 38000000,
      totalInvestment: 145000000,
      roi: 4.0,
    ),
    aiPerformance: AIPerformance(
      totalRequests: 458000,
      cost: 38000000,
      generatedRevenue: 152000000,
      roi: 4.0,
      costPerUser: 15500,
      usageTrend: List.generate(
        7,
        (i) => AIUsageDataPoint(
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          requests: 60000 + (i * 2000) + (i % 2 * 5000),
          cost: 5000000 + (i * 200000),
        ),
      ),
    ),
    topContributors: const [
      TopContributor(
        userId: '1',
        userName: 'Nguyen Van A',
        avatarUrl: '',
        contribution: 12500000,
        coursesCompleted: 15,
      ),
      TopContributor(
        userId: '2',
        userName: 'Tran Thi B',
        avatarUrl: '',
        contribution: 9800000,
        coursesCompleted: 12,
      ),
      TopContributor(
        userId: '3',
        userName: 'Le Van C',
        avatarUrl: '',
        contribution: 8200000,
        coursesCompleted: 10,
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SimpleGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        title: Text(
          _insight.centerName,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revenue',
                        style: tt.bodySmall?.copyWith(color: cs.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCurrency(_insight.revenueContribution),
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_insight.revenuePercentage}%',
                    style: tt.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: cs.primary,
            unselectedLabelColor: cs.textSecondary,
            indicatorColor: cs.primary,
            indicatorWeight: 2,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Financial'),
              Tab(text: 'AI'),
              Tab(text: 'Users'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(insight: _insight),
                _FinancialTab(insight: _insight),
                _AITab(insight: _insight),
                _UsersTab(insight: _insight),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _formatCurrency(double val) {
    if (val >= 1e9) {
      return '${NumberFormat('#,##0.0').format(val / 1e9)}B VND';
    } else if (val >= 1e6) {
      return '${NumberFormat('#,##0').format(val / 1e6)}M VND';
    }
    return NumberFormat('#,###').format(val);
  }
}

// Overview Tab
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.insight});

  final CenterInsight insight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue trend chart
          BISectionHeader(title: 'Revenue Trend', icon: Icons.show_chart_rounded),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                BILineChart(
                  data: insight.revenueTrend
                      .map((d) => TimeSeriesDataPoint(
                            date: d.date,
                            value: d.value,
                          ))
                      .toList(),
                  height: 180,
                  lineColor: cs.primary,
                  showDots: true,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ChartLabel(label: '12 months ago'),
                    _ChartLabel(label: 'Today'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Key metrics
          BISectionHeader(title: 'Key Metrics', icon: Icons.analytics_rounded),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BIMetricCard(
                  label: 'EBITDA',
                  value: insight.financial.ebitda,
                  suffix: 'VND',
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BIMetricCard(
                  label: 'Net Profit',
                  value: insight.financial.netProfit,
                  suffix: 'VND',
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
                  label: 'ROI',
                  value: insight.investment.roi * 100,
                  suffix: '%',
                  icon: Icons.pie_chart_rounded,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BIMetricCard(
                  label: 'AI ROI',
                  value: insight.aiPerformance.roi * 100,
                  suffix: '%',
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// Financial Tab
class _FinancialTab extends StatelessWidget {
  const _FinancialTab({required this.insight});

  final CenterInsight insight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final costs = [
      DonutDataPoint(label: 'AI', value: insight.financial.aiCost, color: cs.primary),
      DonutDataPoint(label: 'Infra', value: insight.financial.infrastructureCost, color: cs.secondary),
      DonutDataPoint(label: 'Support', value: insight.financial.supportCost, color: cs.tertiary),
      DonutDataPoint(label: 'Other', value: insight.financial.otherCosts, color: cs.outline),
    ];

    final totalCost = costs.fold<double>(0, (sum, c) => sum + c.value);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BISectionHeader(title: 'Financial Breakdown', icon: Icons.account_balance_rounded),
          const SizedBox(height: 16),

          // Revenue & Profit
          Row(
            children: [
              Expanded(
                child: _FinancialItem(
                  label: 'Revenue',
                  value: insight.financial.revenue,
                  color: cs.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialItem(
                  label: 'Total Costs',
                  value: totalCost,
                  color: cs.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FinancialItem(
                  label: 'EBITDA',
                  value: insight.financial.ebitda,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialItem(
                  label: 'Net Profit',
                  value: insight.financial.netProfit,
                  color: cs.secondary,
                  isPrimary: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Cost breakdown
          BISectionHeader(title: 'Cost Breakdown', icon: Icons.pie_chart_rounded),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                BIDonutChart(
                  data: costs,
                  size: 140,
                  strokeWidth: 20,
                  centerWidget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: tt.labelSmall?.copyWith(color: cs.textTertiary),
                      ),
                      Text(
                        _formatShort(totalCost),
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: costs.map((c) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: c.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(c.label, style: tt.bodySmall),
                            ),
                            Text(
                              _formatShort(c.value),
                              style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Investment analysis
          BISectionHeader(title: 'Investment Analysis', icon: Icons.insights_rounded),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: cs.gradientSurfacePrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _InvestmentRow(
                  label: 'Marketing Spend',
                  value: insight.investment.marketingSpend,
                ),
                _InvestmentRow(
                  label: 'AI Cost',
                  value: insight.investment.aiCost,
                ),
                const Divider(height: 24),
                _InvestmentRow(
                  label: 'Total Investment',
                  value: insight.investment.totalInvestment,
                  isBold: true,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ROI = Revenue / Investment',
                        style: tt.labelMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        '${insight.investment.roi.toStringAsFixed(2)}x',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _formatShort(double val) {
    if (val >= 1e9) return '${(val / 1e9).toStringAsFixed(1)}B';
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(0)}M';
    return '${(val / 1e3).toStringAsFixed(0)}K';
  }
}

// AI Tab
class _AITab extends StatelessWidget {
  const _AITab({required this.insight});

  final CenterInsight insight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ai = insight.aiPerformance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BISectionHeader(title: 'AI Performance', icon: Icons.auto_awesome_rounded),
          const SizedBox(height: 16),

          // AI metrics
          Row(
            children: [
              Expanded(
                child: BIMetricCard(
                  label: 'Total Requests',
                  value: ai.totalRequests.toDouble(),
                  icon: Icons.api_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BIMetricCard(
                  label: 'AI Cost',
                  value: ai.cost,
                  suffix: 'VND',
                  icon: Icons.payments_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BIMetricCard(
                  label: 'AI Revenue',
                  value: ai.generatedRevenue,
                  suffix: 'VND',
                  icon: Icons.attach_money_rounded,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BIMetricCard(
                  label: 'Cost/User',
                  value: ai.costPerUser,
                  suffix: 'VND',
                  icon: Icons.person_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // AI ROI Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.secondary, cs.secondary.withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: cs.shadowSecondary,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI ROI',
                        style: tt.titleMedium?.copyWith(
                          color: cs.onSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Revenue generated per 1 VND spent',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${ai.roi.toStringAsFixed(2)}x',
                  style: tt.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Usage trend
          BISectionHeader(title: 'Usage Trend (7 days)', icon: Icons.timeline_rounded),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
            ),
            child: BIBarChart(
              data: ai.usageTrend
                  .map((d) => ChartDataPoint(
                        label: _getDayLabel(d.date),
                        value: d.requests.toDouble(),
                      ))
                  .toList(),
              barColor: cs.tertiary,
              height: 160,
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    return DateFormat('EEE').format(date);
  }
}

// Users Tab
class _UsersTab extends StatelessWidget {
  const _UsersTab({required this.insight});

  final CenterInsight insight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BISectionHeader(
            title: 'Top Contributors',
            subtitle: 'Users with highest revenue contribution',
            icon: Icons.people_rounded,
          ),
          const SizedBox(height: 16),

          ...insight.topContributors.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _getRankColor(index),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#${index + 1}',
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      user.userName.split(' ').map((e) => e[0]).take(2).join(),
                      style: tt.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.userName,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${user.coursesCompleted} courses completed',
                          style: tt.bodySmall?.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatCurrency(user.contribution),
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      Text(
                        'contribution',
                        style: tt.labelSmall?.copyWith(
                          color: cs.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return const Color(0xFFFFD700);
    if (index == 1) return const Color(0xFFC0C0C0);
    if (index == 2) return const Color(0xFFCD7F32);
    return const Color(0xFF6B7280);
  }

  String _formatCurrency(double val) {
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(1)}M';
    if (val >= 1e3) return '${(val / 1e3).toStringAsFixed(0)}K';
    return NumberFormat('#,###').format(val);
  }
}

// Helper widgets
class _ChartLabel extends StatelessWidget {
  const _ChartLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Text(
      label,
      style: tt.labelSmall?.copyWith(color: cs.textTertiary),
    );
  }
}

class _FinancialItem extends StatelessWidget {
  const _FinancialItem({
    required this.label,
    required this.value,
    required this.color,
    this.isPrimary = false,
  });

  final String label;
  final double value;
  final Color color;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? color.withValues(alpha: 0.15) : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? color.withValues(alpha: 0.3) : cs.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(value),
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPrimary ? color : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double val) {
    if (val >= 1e9) return '${(val / 1e9).toStringAsFixed(1)}B';
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(0)}M';
    return '${(val / 1e3).toStringAsFixed(0)}K';
  }
}

class _InvestmentRow extends StatelessWidget {
  const _InvestmentRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final double value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (isBold ? tt.titleSmall : tt.bodyMedium)?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(value),
            style: (isBold ? tt.titleMedium : tt.bodyMedium)?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? cs.primary : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double val) {
    if (val >= 1e9) return '${(val / 1e9).toStringAsFixed(1)}B VND';
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(0)}M VND';
    return '${(val / 1e3).toStringAsFixed(0)}K VND';
  }
}
