import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class FocusDetailScreen extends StatelessWidget {
  const FocusDetailScreen({
    super.key,
    required this.focusTracking,
  });

  final FocusTrackingModel focusTracking;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Chi tiết tập trung'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppLayout.screenMargin),
        children: [
          // Overview Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: cs.gradientPrimary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  '${focusTracking.averageFocus.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Điểm tập trung trung bình',
                  style: TextStyle(
                    color: cs.onPrimary.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Tổng buổi',
                      value: focusTracking.totalSessions.toString(),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: cs.onPrimary.withValues(alpha: 0.3),
                    ),
                    _StatItem(
                      label: 'Buổi tốt nhất',
                      value: focusTracking.bestSession != null
                          ? '${focusTracking.bestSession!.focusScore.toStringAsFixed(0)}%'
                          : 'N/A',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: cs.onPrimary.withValues(alpha: 0.3),
                    ),
                    _StatItem(
                      label: 'Cần cải thiện',
                      value: focusTracking.worstSession != null
                          ? '${focusTracking.worstSession!.focusScore.toStringAsFixed(0)}%'
                          : 'N/A',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Chart placeholder
          Text(
            'Biểu đồ theo thời gian',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Text('📊 Biểu đồ tập trung'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // All Sessions
          Text(
            'Tất cả buổi học (${focusTracking.sessions.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...focusTracking.sessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SessionDetailCard(session: session),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: cs.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: cs.onPrimary.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SessionDetailCard extends StatelessWidget {
  const _SessionDetailCard({required this.session});

  final FocusSessionModel session;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final focusColor = session.focusScore >= 80
        ? Colors.green
        : session.focusScore >= 60
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Focus score indicator
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: focusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: focusColor.withValues(alpha: 0.5),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '${session.focusScore.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: focusColor,
                  fontSize: 14,
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
                  session.className,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: cs.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.date,
                      style: TextStyle(
                        color: cs.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      Icons.timer,
                      size: 14,
                      color: cs.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${session.durationMinutes} phút',
                      style: TextStyle(
                        color: cs.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (session.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.note!,
                    style: TextStyle(
                      color: cs.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Progress indicator
          _FocusLevelIndicator(score: session.focusScore),
        ],
      ),
    );
  }
}

class _FocusLevelIndicator extends StatelessWidget {
  const _FocusLevelIndicator({required this.score});

  final double score;

  String get _level {
    if (score >= 80) return 'Tốt';
    if (score >= 60) return 'Khá';
    return 'Cần cải thiện';
  }

  Color get _color {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _level,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
