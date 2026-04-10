import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/organization/bloc/finance/org_finance_cubit.dart';
import 'package:study/features/organization/data/models/models.dart';

class OrgFinanceScreen extends StatefulWidget {
  const OrgFinanceScreen({super.key});

  @override
  State<OrgFinanceScreen> createState() => _OrgFinanceScreenState();
}

class _OrgFinanceScreenState extends State<OrgFinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<OrgFinanceCubit>().loadFinance();
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
        child: BlocBuilder<OrgFinanceCubit, OrgFinanceState>(
          builder: (context, state) {
            return switch (state) {
              OrgFinanceInitial() || OrgFinanceLoading() =>
                const Center(child: CircularProgressIndicator()),
              OrgFinanceLoaded() => _FinanceContent(
                  state: state,
                  tabController: _tabController,
                ),
              OrgFinanceFailure(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: cs.error),
                      const SizedBox(height: AppSpacing.lg),
                      Text(message),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: context.read<OrgFinanceCubit>().loadFinance,
                        child: const Text('Thu lai'),
                      ),
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _FinanceContent extends StatelessWidget {
  const _FinanceContent({
    required this.state,
    required this.tabController,
  });

  final OrgFinanceLoaded state;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final overview = state.overview;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppLayout.screenMargin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phan tich tai chinh',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                    ),
                    Text(
                      'Cap nhat: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.tune),
                      tooltip: 'Bo loc',
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.file_download_outlined),
                      tooltip: 'Xuat bao cao',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Health Score Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
            child: _HealthScoreCard(overview: overview),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

        // Tab Bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Tong quan'),
                Tab(text: 'Doanh thu'),
                Tab(text: 'Khach hang'),
                Tab(text: 'Chi phi'),
              ],
            ),
            cs.surface.withValues(alpha: 0.95),
          ),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          _OverviewTab(overview: overview, transactions: state.transactions),
          _RevenueTab(overview: overview),
          _CustomerTab(overview: overview),
          _ExpenseTab(overview: overview),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar, this.backgroundColor);

  final TabBar tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

// ============================================================================
// HEALTH SCORE CARD
// ============================================================================
class _HealthScoreCard extends StatelessWidget {
  const _HealthScoreCard({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    final score = overview.healthScore;
    final color = score >= 75
        ? Colors.green
        : score >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Score Circle
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _ScoreCirclePainter(score: score, color: color),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toInt().toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 10,
                        color: color.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suc khoe tai chinh',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getHealthDescription(score),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _HealthChip(
                      label: 'LTV/CAC',
                      value: '${overview.ltvCacRatio.toStringAsFixed(1)}x',
                      isGood: overview.ltvCacRatio >= 3,
                    ),
                    _HealthChip(
                      label: 'Churn',
                      value: '${overview.churnRate.toStringAsFixed(1)}%',
                      isGood: overview.churnRate <= 5,
                    ),
                    _HealthChip(
                      label: 'NRR',
                      value: '${overview.nrr.toStringAsFixed(0)}%',
                      isGood: overview.nrr >= 100,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHealthDescription(double score) {
    if (score >= 75) return 'Tuyet voi! Cac chi so deu rat tot.';
    if (score >= 50) return 'Kha on. Co mot so chi so can cai thien.';
    return 'Can chu y! Nhieu chi so chua dat.';
  }
}

class _HealthChip extends StatelessWidget {
  const _HealthChip({
    required this.label,
    required this.value,
    required this.isGood,
  });

  final String label;
  final String value;
  final bool isGood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGood
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGood ? Icons.check_circle : Icons.warning,
            size: 12,
            color: isGood ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isGood ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCirclePainter extends CustomPainter {
  _ScoreCirclePainter({required this.score, required this.color});

  final double score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// OVERVIEW TAB
// ============================================================================
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.overview, required this.transactions});

  final OrgFinanceModel overview;
  final List<OrgTransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<OrgFinanceCubit>().refresh,
      child: ListView(
        padding: const EdgeInsets.all(AppLayout.screenMargin),
        children: [
          // Key Metrics Grid
          _SectionTitle(title: 'Chi so chinh'),
          const SizedBox(height: AppSpacing.md),
          _KeyMetricsGrid(overview: overview),

          const SizedBox(height: AppSpacing.xl),

          // MRR Chart
          _SectionTitle(title: 'MRR Trend'),
          const SizedBox(height: AppSpacing.md),
          _MrrTrendCard(overview: overview),

          const SizedBox(height: AppSpacing.xl),

          // Quick Stats Row
          Row(
            children: [
              Expanded(child: _QuickStatCard(
                title: 'ARR',
                value: _formatShortCurrency(overview.arr),
                subtitle: 'Doanh thu nam',
                icon: Icons.calendar_today,
                color: Colors.blue,
              )),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _QuickStatCard(
                title: 'EBITDA',
                value: _formatShortCurrency(overview.ebitda),
                subtitle: '${overview.ebitdaMargin.toStringAsFixed(1)}% margin',
                icon: Icons.trending_up,
                color: Colors.green,
                change: overview.ebitdaChange,
              )),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // P&L Summary
          _SectionTitle(title: 'Bao cao Lai/Lo'),
          const SizedBox(height: AppSpacing.md),
          _PLSummaryCard(overview: overview),

          const SizedBox(height: AppSpacing.xl),

          // Top Courses
          _SectionTitle(title: 'Khoa hoc ban chay', trailing: 'Xem tat ca'),
          const SizedBox(height: AppSpacing.md),
          ...overview.topCourses.take(3).map((c) => _TopCourseItem(course: c)),

          const SizedBox(height: AppSpacing.xl),

          // Recent Transactions
          _SectionTitle(title: 'Giao dich gan day', trailing: 'Xem tat ca'),
          const SizedBox(height: AppSpacing.md),
          ...transactions.take(5).map((t) => _TransactionItem(transaction: t)),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(0)}M';
    }
    return '${NumberFormat.decimalPattern('vi_VN').format(amount.round())}d';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: cs.onSurface,
          ),
        ),
        if (trailing != null)
          TextButton(
            onPressed: () {},
            child: Text(trailing!),
          ),
      ],
    );
  }
}

class _KeyMetricsGrid extends StatelessWidget {
  const _KeyMetricsGrid({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _MetricTile(
          label: 'MRR',
          value: _formatCurrency(overview.mrr),
          change: overview.mrrGrowth,
          icon: Icons.show_chart,
          color: Colors.blue,
        ),
        _MetricTile(
          label: 'Khach hang',
          value: NumberFormat.compact().format(overview.totalCustomers),
          change: overview.customerChange,
          icon: Icons.people,
          color: Colors.purple,
        ),
        _MetricTile(
          label: 'ARPU',
          value: _formatCurrency(overview.arpu),
          change: overview.arpuChange,
          icon: Icons.person,
          color: Colors.teal,
        ),
        _MetricTile(
          label: 'LTV',
          value: _formatCurrency(overview.ltv),
          change: overview.ltvChange,
          icon: Icons.timeline,
          color: Colors.orange,
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    return '${NumberFormat.decimalPattern('vi_VN').format(amount.round())}d';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final double change;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    Text(
                      '${change.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: cs.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MrrTrendCard extends StatelessWidget {
  const _MrrTrendCard({required this.overview});

  final OrgFinanceModel overview;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatCurrency(overview.mrr),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        overview.mrrGrowth >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: overview.mrrGrowth >= 0 ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${overview.mrrGrowth >= 0 ? '+' : ''}${overview.mrrGrowth.toStringAsFixed(1)}% vs thang truoc',
                        style: TextStyle(
                          color: overview.mrrGrowth >= 0 ? Colors.green : Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // MRR Breakdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _MrrBreakdownRow(
                    label: 'New',
                    value: overview.newMrr,
                    color: Colors.green,
                  ),
                  _MrrBreakdownRow(
                    label: 'Expansion',
                    value: overview.expansionMrr,
                    color: Colors.blue,
                  ),
                  _MrrBreakdownRow(
                    label: 'Churned',
                    value: -overview.churnedMrr,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Chart
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _LineChartPainter(
                data: overview.mrrData,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: overview.chartLabels
                .map((l) => Text(l, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${(amount / 1000000).toStringAsFixed(0)}M';
  }
}

class _MrrBreakdownRow extends StatelessWidget {
  const _MrrBreakdownRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isNegative = value < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ${isNegative ? '-' : '+'}${(value.abs() / 1000000).toStringAsFixed(1)}M',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final range = maxVal - minVal;

    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - ((data[i] - minVal) / range * size.height * 0.8 + size.height * 0.1);
      points.add(Offset(x, y));
    }

    // Gradient fill
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Points
    final dotPaint = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.change,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? change;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: cs.onSurface,
            ),
          ),
          Row(
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: 8),
                Icon(
                  change! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: change! >= 0 ? Colors.green : Colors.red,
                ),
                Text(
                  '${change!.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: change! >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PLSummaryCard extends StatelessWidget {
  const _PLSummaryCard({required this.overview});

  final OrgFinanceModel overview;

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
        children: [
          _PLRow(
            label: 'Doanh thu',
            value: overview.grossRevenue,
            isHeader: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PLRow(
            label: 'COGS',
            value: -overview.totalCogs,
            isExpense: true,
          ),
          const Divider(height: AppSpacing.lg),
          _PLRow(
            label: 'Gross Profit',
            value: overview.grossProfit,
            margin: '${overview.grossMargin.toStringAsFixed(0)}%',
          ),
          const SizedBox(height: AppSpacing.sm),
          _PLRow(
            label: 'OPEX',
            value: -overview.totalOpex,
            isExpense: true,
          ),
          const Divider(height: AppSpacing.lg),
          _PLRow(
            label: 'EBITDA',
            value: overview.ebitda,
            margin: '${overview.ebitdaMargin.toStringAsFixed(0)}%',
            isHighlight: true,
          ),
          _PLRow(
            label: 'Net Income',
            value: overview.netIncome,
            margin: '${overview.netMargin.toStringAsFixed(0)}%',
            isHighlight: true,
          ),
        ],
      ),
    );
  }
}

class _PLRow extends StatelessWidget {
  const _PLRow({
    required this.label,
    required this.value,
    this.isHeader = false,
    this.isExpense = false,
    this.isHighlight = false,
    this.margin,
  });

  final String label;
  final double value;
  final bool isHeader;
  final bool isExpense;
  final bool isHighlight;
  final String? margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isHeader || isHighlight ? cs.onSurface : cs.onSurfaceVariant,
                fontSize: isHeader ? 14 : 13,
                fontWeight: isHeader || isHighlight ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (margin != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isHighlight
                    ? Colors.green.withValues(alpha: 0.1)
                    : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                margin!,
                style: TextStyle(
                  color: isHighlight ? Colors.green : cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            _formatCurrency(value),
            style: TextStyle(
              color: isHighlight
                  ? (value >= 0 ? Colors.green : Colors.red)
                  : (isExpense ? Colors.red.shade400 : cs.onSurface),
              fontSize: isHeader ? 14 : 13,
              fontWeight: isHeader || isHighlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final prefix = amount < 0 ? '-' : '';
    final val = (amount.abs() / 1000000).toStringAsFixed(1);
    return '$prefix${val}M';
  }
}

class _TopCourseItem extends StatelessWidget {
  const _TopCourseItem({required this.course});

  final TopCourseRevenue course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.play_circle_outline, color: cs.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${course.teacherName} • ${course.unitsSold} ban',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(course.revenue / 1000000).toStringAsFixed(1)}M',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 12,
                    color: Colors.green,
                  ),
                  Text(
                    '+${course.growth.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.green,
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
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});

  final OrgTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIncome = transaction.amount > 0;

    final iconData = switch (transaction.transactionType) {
      'income' => Icons.arrow_downward,
      'payout' => Icons.arrow_upward,
      'fee' => Icons.receipt_long,
      'refund' => Icons.replay,
      _ => Icons.swap_horiz,
    };

    final iconColor = switch (transaction.transactionType) {
      'income' => Colors.green,
      'payout' => Colors.blue,
      'fee' => Colors.orange,
      'refund' => Colors.red,
      _ => cs.onSurfaceVariant,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  transaction.description ?? '',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}${NumberFormat.decimalPattern('vi_VN').format(transaction.amount.round())}d',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isIncome ? Colors.green : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REVENUE TAB
// ============================================================================
class _RevenueTab extends StatelessWidget {
  const _RevenueTab({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Revenue Hero Card
        _RevenueHeroCard(overview: overview),

        const SizedBox(height: AppSpacing.xl),

        // Revenue Breakdown
        _SectionTitle(title: 'Phan bo doanh thu'),
        const SizedBox(height: AppSpacing.md),
        _RevenueBreakdownCard(overview: overview),

        const SizedBox(height: AppSpacing.xl),

        // Sales Metrics
        _SectionTitle(title: 'Chi so ban hang'),
        const SizedBox(height: AppSpacing.md),
        _SalesMetricsGrid(overview: overview),

        const SizedBox(height: AppSpacing.xl),

        // Category Performance
        _SectionTitle(title: 'Hieu suat theo danh muc'),
        const SizedBox(height: AppSpacing.md),
        ...overview.topCategories.map((c) => _CategoryItem(category: c)),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _RevenueHeroCard extends StatelessWidget {
  const _RevenueHeroCard({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF10B981)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.4),
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
                'Tong doanh thu',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+${overview.revenueChange.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(overview.grossRevenue / 1000000).toStringAsFixed(0)}M',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          Text(
            'YTD: ${(overview.totalRevenue / 1000000000).toStringAsFixed(2)}B',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _RevenueStatChip(
                label: 'Khoa hoc',
                value: '${(overview.courseRevenue / overview.grossRevenue * 100).toStringAsFixed(0)}%',
              ),
              const SizedBox(width: AppSpacing.sm),
              _RevenueStatChip(
                label: 'Goi dky',
                value: '${(overview.subscriptionRevenue / overview.grossRevenue * 100).toStringAsFixed(0)}%',
              ),
              const SizedBox(width: AppSpacing.sm),
              _RevenueStatChip(
                label: 'Khac',
                value: '${(overview.otherRevenue / overview.grossRevenue * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueStatChip extends StatelessWidget {
  const _RevenueStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RevenueBreakdownCard extends StatelessWidget {
  const _RevenueBreakdownCard({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      _BreakdownData('Khoa hoc', overview.courseRevenue, Colors.blue),
      _BreakdownData('Goi dang ky', overview.subscriptionRevenue, Colors.green),
      _BreakdownData('Khac', overview.otherRevenue, Colors.orange),
    ];
    final total = overview.grossRevenue;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 16,
              child: Row(
                children: items.map((item) {
                  final percent = total > 0 ? item.value / total : 0.0;
                  return Expanded(
                    flex: (percent * 100).round().clamp(1, 100),
                    child: Container(color: item.color),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...items.map((item) {
            final percent = total > 0 ? (item.value / total * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(color: cs.onSurface),
                    ),
                  ),
                  Text(
                    '${(item.value / 1000000).toStringAsFixed(1)}M',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 45,
                    child: Text(
                      '${percent.toStringAsFixed(0)}%',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BreakdownData {
  final String label;
  final double value;
  final Color color;
  _BreakdownData(this.label, this.value, this.color);
}

class _SalesMetricsGrid extends StatelessWidget {
  const _SalesMetricsGrid({required this.overview});

  final OrgFinanceModel overview;

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
        children: [
          Row(
            children: [
              Expanded(
                child: _SalesMetricItem(
                  label: 'Don hang',
                  value: NumberFormat.compact().format(overview.totalOrders),
                  icon: Icons.shopping_cart,
                ),
              ),
              Expanded(
                child: _SalesMetricItem(
                  label: 'AOV',
                  value: '${(overview.avgOrderValue / 1000).toStringAsFixed(0)}K',
                  icon: Icons.attach_money,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SalesMetricItem(
                  label: 'Conversion',
                  value: '${overview.conversionRate.toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                ),
              ),
              Expanded(
                child: _SalesMetricItem(
                  label: 'Hoan tien',
                  value: '${overview.refundRate.toStringAsFixed(1)}%',
                  icon: Icons.replay,
                  isNegative: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SalesMetricItem(
                  label: 'Visitors',
                  value: NumberFormat.compact().format(overview.totalVisitors),
                  icon: Icons.visibility,
                ),
              ),
              Expanded(
                child: _SalesMetricItem(
                  label: 'Free→Paid',
                  value: '${overview.payingConversion.toStringAsFixed(1)}%',
                  icon: Icons.monetization_on,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalesMetricItem extends StatelessWidget {
  const _SalesMetricItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isNegative = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isNegative ? Colors.red : cs.primary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isNegative ? Colors.red : cs.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category});

  final CategoryRevenue category;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  '${category.courseCount} khoa hoc',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(category.revenue / 1000000).toStringAsFixed(1)}M',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, size: 12, color: Colors.green),
                  Text(
                    '+${category.growth.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 50,
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: category.percentage / 100,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
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

// ============================================================================
// CUSTOMER TAB
// ============================================================================
class _CustomerTab extends StatelessWidget {
  const _CustomerTab({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Customer Hero
        _CustomerHeroCard(overview: overview),

        const SizedBox(height: AppSpacing.xl),

        // Unit Economics
        _SectionTitle(title: 'Unit Economics'),
        const SizedBox(height: AppSpacing.md),
        _UnitEconomicsCard(overview: overview),

        const SizedBox(height: AppSpacing.xl),

        // Retention Metrics
        _SectionTitle(title: 'Chi so giu chan'),
        const SizedBox(height: AppSpacing.md),
        _RetentionMetricsCard(overview: overview),

        const SizedBox(height: AppSpacing.xl),

        // Cohort Analysis
        _SectionTitle(title: 'Phan tich Cohort'),
        const SizedBox(height: AppSpacing.md),
        _CohortTable(overview: overview),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _CustomerHeroCard extends StatelessWidget {
  const _CustomerHeroCard({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tong khach hang',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.decimalPattern().format(overview.totalCustomers),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _CustomerStatChip(
                label: 'Moi',
                value: '+${overview.newCustomers}',
                color: Colors.greenAccent,
              ),
              const SizedBox(width: AppSpacing.sm),
              _CustomerStatChip(
                label: 'Churned',
                value: '-${overview.churnedCustomers}',
                color: Colors.redAccent,
              ),
              const SizedBox(width: AppSpacing.sm),
              _CustomerStatChip(
                label: 'Active',
                value: '${overview.activeCustomers}',
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerStatChip extends StatelessWidget {
  const _CustomerStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitEconomicsCard extends StatelessWidget {
  const _UnitEconomicsCard({required this.overview});

  final OrgFinanceModel overview;

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
        children: [
          Row(
            children: [
              Expanded(
                child: _UnitEconBox(
                  label: 'LTV',
                  value: '${(overview.ltv / 1000000).toStringAsFixed(2)}M',
                  subtitle: 'Customer Lifetime Value',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _UnitEconBox(
                  label: 'CAC',
                  value: '${(overview.cac / 1000).toStringAsFixed(0)}K',
                  subtitle: 'Cost to Acquire',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: overview.ltvCacRatio >= 3
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  overview.ltvCacRatio >= 3 ? Icons.check_circle : Icons.info,
                  color: overview.ltvCacRatio >= 3 ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'LTV/CAC Ratio: ${overview.ltvCacRatio.toStringAsFixed(1)}x',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: overview.ltvCacRatio >= 3 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _UnitEconBox(
                  label: 'ARPU',
                  value: '${(overview.arpu / 1000).toStringAsFixed(0)}K',
                  subtitle: 'Avg Rev/User',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _UnitEconBox(
                  label: 'Payback',
                  value: '${overview.paybackMonths.toStringAsFixed(1)} thang',
                  subtitle: 'CAC Recovery',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitEconBox extends StatelessWidget {
  const _UnitEconBox({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: cs.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _RetentionMetricsCard extends StatelessWidget {
  const _RetentionMetricsCard({required this.overview});

  final OrgFinanceModel overview;

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
        children: [
          Row(
            children: [
              Expanded(
                child: _RetentionGauge(
                  label: 'Retention Rate',
                  value: overview.retentionRate,
                  target: 95,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _RetentionGauge(
                  label: 'Churn Rate',
                  value: overview.churnRate,
                  target: 5,
                  color: Colors.red,
                  isInverse: true,
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _RetentionGauge(
                  label: 'NRR',
                  value: overview.nrr,
                  target: 100,
                  color: Colors.blue,
                  suffix: '%',
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _RetentionGauge(
                  label: 'Completion',
                  value: overview.completionRate,
                  target: 70,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RetentionGauge extends StatelessWidget {
  const _RetentionGauge({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
    this.isInverse = false,
    this.suffix = '%',
  });

  final String label;
  final double value;
  final double target;
  final Color color;
  final bool isInverse;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isGood = isInverse ? value <= target : value >= target;

    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}$suffix',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: isGood ? color : Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: isInverse
              ? (target / value).clamp(0, 1)
              : (value / target).clamp(0, 1),
          backgroundColor: cs.surfaceContainerHigh,
          valueColor: AlwaysStoppedAnimation(isGood ? color : Colors.orange),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 4),
        Text(
          'Target: ${target.toStringAsFixed(0)}$suffix',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _CohortTable extends StatelessWidget {
  const _CohortTable({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 36,
          columnSpacing: 12,
          columns: [
            DataColumn(label: Text('Thang', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onSurface))),
            DataColumn(label: Text('KH', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onSurface))),
            ...List.generate(6, (i) => DataColumn(
              label: Text('M${i + 1}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: cs.onSurface)),
            )),
          ],
          rows: overview.cohortRetention.map((cohort) {
            return DataRow(cells: [
              DataCell(Text(cohort.month, style: TextStyle(fontSize: 11, color: cs.onSurface))),
              DataCell(Text('${cohort.initialCustomers}', style: TextStyle(fontSize: 11, color: cs.onSurface))),
              ...List.generate(6, (i) {
                if (i < cohort.retentionRates.length) {
                  final rate = cohort.retentionRates[i];
                  return DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCohortColor(rate),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${rate.toInt()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                return const DataCell(Text('-'));
              }),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Color _getCohortColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.teal;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
}

// ============================================================================
// EXPENSE TAB
// ============================================================================
class _ExpenseTab extends StatelessWidget {
  const _ExpenseTab({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      children: [
        // Expense Summary
        _ExpenseSummaryCard(overview: overview),

        const SizedBox(height: AppSpacing.xl),

        // COGS Breakdown
        _SectionTitle(title: 'Chi phi truc tiep (COGS)'),
        const SizedBox(height: AppSpacing.md),
        _COGSBreakdownCard(overview: overview),

        const SizedBox(height: AppSpacing.xl),

        // OPEX Breakdown
        _SectionTitle(title: 'Chi phi van hanh (OPEX)'),
        const SizedBox(height: AppSpacing.md),
        _OPEXBreakdownCard(overview: overview),

        const SizedBox(height: AppSpacing.xl),

        // Cash Flow
        _SectionTitle(title: 'Dong tien'),
        const SizedBox(height: AppSpacing.md),
        _CashFlowCard(overview: overview),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    final totalExpense = overview.totalCogs + overview.totalOpex;
    final expenseRatio = (totalExpense / overview.grossRevenue * 100);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDC2626), Color(0xFFF87171)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.4),
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
                'Tong chi phi',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${expenseRatio.toStringAsFixed(0)}% doanh thu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(totalExpense / 1000000).toStringAsFixed(0)}M',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _ExpenseChip(
                label: 'COGS',
                value: '${(overview.totalCogs / 1000000).toStringAsFixed(0)}M',
              ),
              const SizedBox(width: AppSpacing.sm),
              _ExpenseChip(
                label: 'OPEX',
                value: '${(overview.totalOpex / 1000000).toStringAsFixed(0)}M',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseChip extends StatelessWidget {
  const _ExpenseChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _COGSBreakdownCard extends StatelessWidget {
  const _COGSBreakdownCard({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = overview.totalCogs;
    final items = [
      _ExpenseItem('Chi tra giao vien', overview.teacherPayout, Colors.purple),
      _ExpenseItem('Phi nen tang', overview.platformFee, Colors.blue),
      _ExpenseItem('Phi thanh toan', overview.paymentProcessingFee, Colors.teal),
      _ExpenseItem('Hoan tien', overview.refunds, Colors.red),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          ...items.map((item) => _ExpenseRow(
                item: item,
                total: total,
              )),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tong COGS',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              Text(
                '${(total / 1000000).toStringAsFixed(1)}M',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OPEXBreakdownCard extends StatelessWidget {
  const _OPEXBreakdownCard({required this.overview});

  final OrgFinanceModel overview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = overview.totalOpex;
    final items = [
      _ExpenseItem('Marketing', overview.marketingCost, Colors.orange),
      _ExpenseItem('Nhan su', overview.staffCost, Colors.green),
      _ExpenseItem('Ha tang', overview.infrastructureCost, Colors.blue),
      _ExpenseItem('Khac', overview.otherOpex, Colors.grey),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          ...items.map((item) => _ExpenseRow(
                item: item,
                total: total,
              )),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tong OPEX',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              Text(
                '${(total / 1000000).toStringAsFixed(1)}M',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseItem {
  final String label;
  final double value;
  final Color color;
  _ExpenseItem(this.label, this.value, this.color);
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.item, required this.total});

  final _ExpenseItem item;
  final double total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percent = total > 0 ? (item.value / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(color: cs.onSurface, fontSize: 13),
                ),
              ),
              Text(
                '${(item.value / 1000000).toStringAsFixed(1)}M',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: cs.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(item.color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}

class _CashFlowCard extends StatelessWidget {
  const _CashFlowCard({required this.overview});

  final OrgFinanceModel overview;

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
        children: [
          Row(
            children: [
              Expanded(
                child: _CashFlowItem(
                  label: 'So du',
                  value: overview.cashBalance,
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CashFlowItem(
                  label: 'Cho thu',
                  value: overview.accountsReceivable,
                  icon: Icons.schedule,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _CashFlowItem(
                  label: 'Cho chi GV',
                  value: overview.pendingPayout,
                  icon: Icons.payments_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CashFlowItem(
                  label: 'Da chi YTD',
                  value: overview.totalPayout,
                  icon: Icons.check_circle_outline,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CashFlowItem extends StatelessWidget {
  const _CashFlowItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _formatCurrency(value),
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
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(0)}M';
    }
    return '${NumberFormat.decimalPattern('vi_VN').format(amount.round())}d';
  }
}
