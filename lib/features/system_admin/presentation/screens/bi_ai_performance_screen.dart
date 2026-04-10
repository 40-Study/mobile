import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import '../widgets/widgets.dart';

/// Màn hình Hiệu suất AI
class BIAIPerformanceScreen extends StatelessWidget {
  const BIAIPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final aiCostByCenter = [
      const RankingDataPoint(label: 'Elite Academy', value: 38000000),
      const RankingDataPoint(label: 'Future Learn', value: 28000000),
      const RankingDataPoint(label: 'Smart Study', value: 24000000),
      const RankingDataPoint(label: 'NextGen Edu', value: 20000000),
      const RankingDataPoint(label: 'Digital Campus', value: 15000000),
    ];

    final aiUsageTrend = [
      TimeSeriesDataPoint(date: DateTime.now().subtract(const Duration(days: 6)), value: 380000),
      TimeSeriesDataPoint(date: DateTime.now().subtract(const Duration(days: 5)), value: 395000),
      TimeSeriesDataPoint(date: DateTime.now().subtract(const Duration(days: 4)), value: 420000),
      TimeSeriesDataPoint(date: DateTime.now().subtract(const Duration(days: 3)), value: 410000),
      TimeSeriesDataPoint(date: DateTime.now().subtract(const Duration(days: 2)), value: 445000),
      TimeSeriesDataPoint(date: DateTime.now().subtract(const Duration(days: 1)), value: 458000),
      TimeSeriesDataPoint(date: DateTime.now(), value: 472000),
    ];

    final aiEfficiencyData = [
      {'name': 'Elite Academy', 'cost': 38.0, 'revenue': 152.0, 'roi': 4.0},
      {'name': 'Future Learn', 'cost': 28.0, 'revenue': 112.0, 'roi': 4.0},
      {'name': 'Smart Study', 'cost': 24.0, 'revenue': 96.0, 'roi': 4.0},
      {'name': 'NextGen Edu', 'cost': 20.0, 'revenue': 80.0, 'roi': 4.0},
      {'name': 'Digital Campus', 'cost': 15.0, 'revenue': 55.0, 'roi': 3.7},
      {'name': 'EduTech Plus', 'cost': 12.0, 'revenue': 39.0, 'roi': 3.3},
      {'name': 'Classic Learning', 'cost': 8.0, 'revenue': 12.0, 'roi': 1.5},
      {'name': 'Basic Edu Hub', 'cost': 5.0, 'revenue': 4.5, 'roi': 0.9},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BICompactHeader(
              title: 'Hiệu suất AI',
              subtitle: 'Chi phí, sử dụng và hiệu quả',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary metrics
                  Row(
                    children: [
                      Expanded(
                        child: BIMetricCard(
                          label: 'Tổng chi phí AI',
                          value: 156000000,
                          suffix: 'VND',
                          trend: 8.5,
                          icon: Icons.memory_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BIMetricCard(
                          label: 'Doanh thu AI',
                          value: 624000000,
                          suffix: 'VND',
                          trend: 24.3,
                          icon: Icons.auto_awesome_rounded,
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: BIMetricCard(
                          label: 'Tổng yêu cầu',
                          value: 2850000,
                          icon: Icons.api_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BIMetricCard(
                          label: 'ROI AI nền tảng',
                          value: 4.0,
                          suffix: 'x',
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Usage trend
                  BISectionHeader(
                    title: 'Xu hướng sử dụng AI',
                    subtitle: 'Số yêu cầu hàng ngày (7 ngày)',
                    icon: Icons.timeline_rounded,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                      boxShadow: cs.shadowCard,
                    ),
                    child: BILineChart(
                      data: aiUsageTrend,
                      height: 180,
                      lineColor: cs.tertiary,
                      showDots: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Cost by center
                  BISectionHeader(
                    title: 'Chi phí AI theo trung tâm',
                    icon: Icons.payments_rounded,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                      boxShadow: cs.shadowCard,
                    ),
                    child: BIHorizontalBarChart(
                      data: aiCostByCenter
                          .map((d) => RankingDataPoint(
                                label: d.label,
                                value: d.value,
                                color: cs.tertiary,
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Efficiency ranking
                  BISectionHeader(
                    title: 'Xếp hạng hiệu quả AI',
                    subtitle: 'Doanh thu tạo ra trên mỗi VND chi tiêu',
                    icon: Icons.leaderboard_rounded,
                  ),
                  const SizedBox(height: 12),

                  ...aiEfficiencyData.asMap().entries.map((entry) {
                    final data = entry.value;
                    final roi = data['roi'] as double;
                    final isEfficient = roi >= 3.0;
                    final isInefficient = roi < 1.5;

                    Color statusColor;
                    String statusLabel;
                    IconData statusIcon;

                    if (isInefficient) {
                      statusColor = cs.error;
                      statusLabel = 'Kém hiệu quả';
                      statusIcon = Icons.warning_rounded;
                    } else if (isEfficient) {
                      statusColor = cs.secondary;
                      statusLabel = 'Hiệu quả';
                      statusIcon = Icons.check_circle_rounded;
                    } else {
                      statusColor = cs.tertiary;
                      statusLabel = 'Trung bình';
                      statusIcon = Icons.remove_circle_outline_rounded;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isInefficient
                              ? cs.error.withValues(alpha: 0.3)
                              : cs.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(statusIcon, size: 18, color: statusColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] as String,
                                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      'Chi phí: ${data['cost']}M',
                                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'DT: ${data['revenue']}M',
                                      style: tt.labelSmall?.copyWith(color: cs.secondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${roi.toStringAsFixed(1)}x',
                                  style: tt.labelLarge?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                statusLabel,
                                style: tt.labelSmall?.copyWith(color: statusColor),
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
            ),
          ),
        ],
      ),
    );
  }
}
