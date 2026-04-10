import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import '../widgets/widgets.dart';

/// Màn hình Phân tích với biểu đồ và so sánh
class BIAnalyticsScreen extends StatefulWidget {
  const BIAnalyticsScreen({super.key});

  @override
  State<BIAnalyticsScreen> createState() => _BIAnalyticsScreenState();
}

class _BIAnalyticsScreenState extends State<BIAnalyticsScreen> {
  int _selectedPeriod = 1;

  final _revenueByCenter = [
    const RankingDataPoint(label: 'Elite Academy', value: 580000000),
    const RankingDataPoint(label: 'Future Learn', value: 420000000),
    const RankingDataPoint(label: 'Smart Study', value: 385000000),
    const RankingDataPoint(label: 'NextGen Edu', value: 320000000),
    const RankingDataPoint(label: 'Digital Campus', value: 275000000),
  ];

  final _revenueOverTime = [
    TimeSeriesDataPoint(date: DateTime(2025, 5), value: 1850000000),
    TimeSeriesDataPoint(date: DateTime(2025, 6), value: 1920000000),
    TimeSeriesDataPoint(date: DateTime(2025, 7), value: 2050000000),
    TimeSeriesDataPoint(date: DateTime(2025, 8), value: 2180000000),
    TimeSeriesDataPoint(date: DateTime(2025, 9), value: 2280000000),
    TimeSeriesDataPoint(date: DateTime(2025, 10), value: 2450000000),
  ];

  final _investmentVsRevenue = [
    const ComparisonDataPoint(label: 'Elite', value1: 145000000, value2: 580000000),
    const ComparisonDataPoint(label: 'Future', value1: 120000000, value2: 420000000),
    const ComparisonDataPoint(label: 'Smart', value1: 110000000, value2: 385000000),
    const ComparisonDataPoint(label: 'NextGen', value1: 95000000, value2: 320000000),
    const ComparisonDataPoint(label: 'Digital', value1: 88000000, value2: 275000000),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BICompactHeader(
              title: 'Phân tích',
              subtitle: 'Biểu đồ và so sánh dữ liệu',
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.compare_arrows_rounded),
                  tooltip: 'So sánh trung tâm',
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  Row(
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
                            selected: _selectedPeriod,
                            onChanged: (index) => setState(() => _selectedPeriod = index),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Revenue over time
                  BISectionHeader(
                    title: 'Doanh thu theo thời gian',
                    icon: Icons.show_chart_rounded,
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
                    child: Column(
                      children: [
                        BILineChart(
                          data: _revenueOverTime,
                          height: 200,
                          lineColor: cs.primary,
                          showDots: true,
                          showGrid: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tháng 5',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                            Text('Tháng 10',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Revenue by center
                  BISectionHeader(
                    title: 'Doanh thu theo trung tâm',
                    subtitle: 'Top 5 trung tâm',
                    icon: Icons.bar_chart_rounded,
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
                      data: _revenueByCenter
                          .map((d) => RankingDataPoint(
                                label: d.label,
                                value: d.value,
                                color: cs.primary,
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Investment vs Revenue
                  BISectionHeader(
                    title: 'Đầu tư vs Doanh thu',
                    subtitle: 'So sánh hiệu quả chi tiêu',
                    icon: Icons.compare_rounded,
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
                    child: BIComparisonChart(
                      label1: 'Đầu tư',
                      label2: 'Doanh thu',
                      data: _investmentVsRevenue,
                      color1: cs.tertiary,
                      color2: cs.secondary,
                      height: 220,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ROI Ranking
                  BISectionHeader(
                    title: 'Xếp hạng ROI',
                    icon: Icons.emoji_events_rounded,
                    action: () {},
                    actionLabel: 'Xem tất cả',
                  ),
                  const SizedBox(height: 12),
                  ..._buildROIRanking(context),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildROIRanking(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final roiData = [
      {'name': 'Elite Academy', 'roi': 4.0, 'category': 'high'},
      {'name': 'Future Learn Hub', 'roi': 3.5, 'category': 'high'},
      {'name': 'Smart Study Center', 'roi': 3.5, 'category': 'high'},
      {'name': 'NextGen Education', 'roi': 3.4, 'category': 'high'},
      {'name': 'Digital Campus', 'roi': 3.1, 'category': 'medium'},
    ];

    return roiData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final roi = data['roi'] as double;
      final isHigh = roi >= 3.0;

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isHigh
                    ? cs.secondary.withValues(alpha: 0.15)
                    : cs.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '#${index + 1}',
                style: tt.labelSmall?.copyWith(
                  color: isHigh ? cs.secondary : cs.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data['name'] as String,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isHigh
                    ? cs.secondary.withValues(alpha: 0.15)
                    : cs.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${roi.toStringAsFixed(2)}x',
                style: tt.labelLarge?.copyWith(
                  color: isHigh ? cs.secondary : cs.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
