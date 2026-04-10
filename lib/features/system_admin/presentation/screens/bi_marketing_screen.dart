import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import '../widgets/widgets.dart';

/// Marketing Tracking Screen
class BIMarketingScreen extends StatelessWidget {
  const BIMarketingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Mock data
    final channelData = [
      DonutDataPoint(label: 'Social Media', value: 45, color: cs.primary),
      DonutDataPoint(label: 'Search', value: 28, color: cs.secondary),
      DonutDataPoint(label: 'Referral', value: 18, color: cs.tertiary),
      DonutDataPoint(label: 'Direct', value: 9, color: cs.outline),
    ];

    final centerMarketingSpend = [
      const RankingDataPoint(label: 'Elite Academy', value: 85000000),
      const RankingDataPoint(label: 'Future Learn', value: 65000000),
      const RankingDataPoint(label: 'Smart Study', value: 55000000),
      const RankingDataPoint(label: 'NextGen Edu', value: 48000000),
      const RankingDataPoint(label: 'Digital Campus', value: 42000000),
    ];

    final channelPerformance = [
      {
        'channel': 'Social Media',
        'spend': 185000000,
        'acquisitions': 4250,
        'cac': 43500,
        'conversion': 3.8,
      },
      {
        'channel': 'Google Ads',
        'spend': 125000000,
        'acquisitions': 2150,
        'cac': 58100,
        'conversion': 2.4,
      },
      {
        'channel': 'Referral',
        'spend': 45000000,
        'acquisitions': 1850,
        'cac': 24300,
        'conversion': 8.5,
      },
      {
        'channel': 'Direct',
        'spend': 0,
        'acquisitions': 980,
        'cac': 0,
        'conversion': 12.2,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Marketing',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary metrics
            Row(
              children: [
                Expanded(
                  child: BIMetricCard(
                    label: 'Total Spend',
                    value: 355000000,
                    suffix: 'VND',
                    trend: 12.5,
                    icon: Icons.campaign_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BIMetricCard(
                    label: 'Acquisitions',
                    value: 9230,
                    trend: 28.3,
                    icon: Icons.person_add_rounded,
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
                    label: 'Avg CAC',
                    value: 38500,
                    suffix: 'VND',
                    trend: -8.2,
                    trendUp: true,
                    icon: Icons.price_check_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BIMetricCard(
                    label: 'Conversion',
                    value: 4.8,
                    suffix: '%',
                    trend: 15.5,
                    icon: Icons.sync_alt_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Acquisition by channel
            BISectionHeader(
              title: 'Acquisition by Channel',
              icon: Icons.pie_chart_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                boxShadow: cs.shadowCard,
              ),
              child: Row(
                children: [
                  BIDonutChart(
                    data: channelData,
                    size: 140,
                    strokeWidth: 20,
                    centerWidget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '9.2K',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total',
                          style: tt.labelSmall?.copyWith(
                            color: cs.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: channelData.map((c) {
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
                                '${c.value.toStringAsFixed(0)}%',
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

            // Channel performance
            BISectionHeader(
              title: 'Channel Performance',
              icon: Icons.analytics_rounded,
            ),
            const SizedBox(height: 12),
            ...channelPerformance.map((channel) {
              final cac = channel['cac'] as int;
              final isEfficient = cac < 50000 || cac == 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          channel['channel'] as String,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isEfficient
                                ? cs.secondary.withValues(alpha: 0.1)
                                : cs.tertiary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cac == 0 ? 'Free' : '${(cac / 1000).toStringAsFixed(1)}K CAC',
                            style: tt.labelSmall?.copyWith(
                              color: isEfficient ? cs.secondary : cs.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ChannelStat(
                          label: 'Spend',
                          value: _formatCurrency(
                              (channel['spend'] as int).toDouble()),
                        ),
                        const SizedBox(width: 16),
                        _ChannelStat(
                          label: 'Users',
                          value: '${channel['acquisitions']}',
                        ),
                        const SizedBox(width: 16),
                        _ChannelStat(
                          label: 'Conv.',
                          value: '${channel['conversion']}%',
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Spend by center
            BISectionHeader(
              title: 'Marketing Spend by Center',
              icon: Icons.business_rounded,
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
                data: centerMarketingSpend.map((d) {
                  return RankingDataPoint(
                    label: d.label,
                    value: d.value,
                    color: cs.tertiary,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double val) {
    if (val >= 1e9) return '${(val / 1e9).toStringAsFixed(1)}B';
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(0)}M';
    if (val >= 1e3) return '${(val / 1e3).toStringAsFixed(0)}K';
    return val == 0 ? 'Free' : val.toStringAsFixed(0);
  }
}

class _ChannelStat extends StatelessWidget {
  const _ChannelStat({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.textTertiary,
            ),
          ),
          Text(
            value,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isHighlight ? cs.secondary : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
