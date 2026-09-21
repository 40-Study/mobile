import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/achievement/all_achievements_screen.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key, required this.badge, required this.onTap});

  final AchievementBadgeData badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isLocked = badge.status == BadgeStatus.locked;
    final isInProgress = badge.status == BadgeStatus.inProgress;
    final displayColor = isLocked ? cs.outlineVariant : badge.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                HexagonBadge(
                  icon: badge.icon,
                  color: displayColor,
                  isLocked: isLocked,
                  isInProgress: isInProgress,
                ),
                if (badge.isNew)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(AppLocalizations.of(context)!.newBadge,
                          style: tt.labelSmall?.copyWith(
                              color: cs.onPrimary,
                              fontSize: 8,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            AppSpacing.vGap4,
            Text(badge.title,
                style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLocked ? cs.onSurfaceVariant : cs.onSurface),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(badge.description,
                style: tt.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant, fontSize: 9),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            if (badge.status == BadgeStatus.earned && badge.earnedAt != null)
              Text(_formatDate(badge.earnedAt!),
                  style: tt.labelSmall?.copyWith(color: cs.outline, fontSize: 9)),
            if (isInProgress || isLocked) ...[
              AppSpacing.vGap4,
              MiniProgressBar(percent: badge.progressPercent, color: displayColor),
              Text('${(badge.progressPercent * 100).round()}%',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class HexagonBadge extends StatelessWidget {
  const HexagonBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.isLocked,
    required this.isInProgress,
  });

  final IconData icon;
  final Color color;
  final bool isLocked;
  final bool isInProgress;

  @override
  Widget build(BuildContext context) {
    final displayColor =
        isLocked ? color : (isInProgress ? color.withValues(alpha: 0.7) : color);

    return CustomPaint(
      painter: HexagonPainter(color: displayColor, isLocked: isLocked),
      child: SizedBox(
        width: 56,
        height: 64,
        child: Center(
          child:
              Icon(icon, size: 24, color: isLocked ? Colors.white54 : Colors.white),
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  HexagonPainter({required this.color, required this.isLocked});

  final Color color;
  final bool isLocked;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createHexagonPath(size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = isLocked ? color : color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniProgressBar extends StatelessWidget {
  const MiniProgressBar({super.key, required this.percent, required this.color});

  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: percent,
          backgroundColor: cs.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}

class CircularProgress extends StatelessWidget {
  const CircularProgress({
    super.key,
    required this.percent,
    required this.size,
    required this.strokeWidth,
  });

  final double percent;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: CircularProgressPainter(
              percent: percent,
              strokeWidth: strokeWidth,
              backgroundColor: cs.surfaceContainerHighest,
              progressColor: cs.primary,
            ),
          ),
          Icon(Icons.emoji_events_rounded, size: 28, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  CircularProgressPainter({
    required this.percent,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double percent;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
