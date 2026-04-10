import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../data/models/bi_models.dart';

/// Card displaying a partner center in the list
class CenterListCard extends StatelessWidget {
  const CenterListCard({
    super.key,
    required this.center,
    this.onTap,
    this.showRank = false,
    this.rank,
  });

  final PartnerCenter center;
  final VoidCallback? onTap;
  final bool showRank;
  final int? rank;

  String _formatCurrency(double val) {
    if (val >= 1e9) {
      return '${(val / 1e9).toStringAsFixed(1)}B';
    } else if (val >= 1e6) {
      return '${(val / 1e6).toStringAsFixed(1)}M';
    }
    return NumberFormat('#,###').format(val);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
          boxShadow: cs.shadowCard,
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (showRank && rank != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _getRankColor(rank!, cs),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#$rank',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                _CenterAvatar(name: center.name, status: center.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        center.name,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _StatusBadge(status: center.status),
                          const SizedBox(width: 8),
                          Text(
                            '${center.totalUsers} users',
                            style: tt.labelSmall?.copyWith(
                              color: cs.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(center.revenue),
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _GrowthIndicator(value: center.growthPercentage),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MetricChip(
                  icon: Icons.pie_chart_outline_rounded,
                  label: 'Contrib',
                  value: '${center.revenueContribution.toStringAsFixed(1)}%',
                  color: cs.primary,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  icon: Icons.trending_up_rounded,
                  label: 'ROI',
                  value: '${center.roi.toStringAsFixed(2)}x',
                  color: center.roi >= 2.0 ? cs.secondary : cs.tertiary,
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI',
                  value: '${center.aiUsage.toStringAsFixed(0)}%',
                  color: cs.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank, ColorScheme cs) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return cs.primary;
  }
}

class _CenterAvatar extends StatelessWidget {
  const _CenterAvatar({required this.name, required this.status});

  final String name;
  final CenterStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final initials = name.split(' ').take(2).map((e) => e[0]).join();
    final color = _getStatusAccentColor(status, cs);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: tt.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusAccentColor(CenterStatus status, ColorScheme cs) {
    switch (status) {
      case CenterStatus.growing:
        return cs.secondary;
      case CenterStatus.active:
        return cs.primary;
      case CenterStatus.declining:
        return cs.tertiary;
      case CenterStatus.atRisk:
        return cs.error;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CenterStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (label, color) = switch (status) {
      CenterStatus.growing => ('Growing', cs.secondary),
      CenterStatus.active => ('Active', cs.primary),
      CenterStatus.declining => ('Declining', cs.tertiary),
      CenterStatus.atRisk => ('At Risk', cs.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _GrowthIndicator extends StatelessWidget {
  const _GrowthIndicator({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isPositive = value >= 0;
    final color = isPositive ? cs.secondary : cs.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded,
          size: 12,
          color: color,
        ),
        Text(
          '${isPositive ? '+' : ''}${value.toStringAsFixed(1)}%',
          style: tt.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: tt.labelSmall?.copyWith(
                      color: cs.textTertiary,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    value,
                    style: tt.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
