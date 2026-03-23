import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({
    super.key,
    required this.revenue,
    required this.chartData,
  });

  final double revenue;
  final List<double> chartData;

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'DOANH THU THÁNG NÀY',
                style: tt.labelSmall?.copyWith(
                  color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: _formatCurrency(revenue),
                  style: tt.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                TextSpan(
                  text: ' VND',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 80,
            child: _SimpleBarChart(data: chartData, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  const _SimpleBarChart({
    required this.data,
    required this.color,
  });

  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: data.map((value) {
        final height = (value / maxValue) * 80;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              height: height.clamp(8.0, 80.0),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3 + (value / maxValue) * 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
