import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class OverviewStatistics extends StatelessWidget {
  const OverviewStatistics({super.key, required this.stats});

  final StudentStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.overview,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.vGap16,
          Row(
            children: [
              AchievementStatItem(
                icon: Icons.access_time_rounded,
                value: '${stats.totalStudyHours.toInt()}',
                label: l10n.studyHours,
                color: cs.primary,
              ),
              _divider(cs),
              AchievementStatItem(
                icon: Icons.menu_book_rounded,
                value: '${stats.completedLessons}',
                label: l10n.completedLessons,
                color: AchievementColors.orange,
              ),
              _divider(cs),
              AchievementStatItem(
                icon: Icons.emoji_events_rounded,
                value: '18',
                label: l10n.badges,
                color: AchievementColors.green,
              ),
              _divider(cs),
              AchievementStatItem(
                icon: Icons.local_fire_department_rounded,
                value: '${stats.streakDays}',
                label: l10n.streak,
                color: AchievementColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme cs) {
    return Container(width: 1, height: 50, color: cs.outlineVariant);
  }
}

/// Stat item with sparkline for achievement screen
class AchievementStatItem extends StatelessWidget {
  const AchievementStatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          AppSpacing.vGap8,
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
            duration: const Duration(milliseconds: 800),
            builder: (context, val, _) => Text('$val',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
          Text(label,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 2),
          AppSpacing.vGap4,
          MiniSparkline(color: color),
        ],
      ),
    );
  }
}

class MiniSparkline extends StatelessWidget {
  const MiniSparkline({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 16),
      painter: _SparklinePainter(color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final data = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75];
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final step = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height * (1 - data[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
