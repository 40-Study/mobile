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
    final isEarned = badge.status == BadgeStatus.earned;
    final displayColor = isLocked ? cs.slate400 : badge.color;

    return RepaintBoundary(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge Icon with Ambient Colored Glow
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (isEarned) ...[
                    // Multi-layer ambient colored glow behind the badge
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: badge.color.withValues(alpha: 0.5),
                            blurRadius: 22,
                            spreadRadius: 3,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: badge.color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ] else if (isInProgress) ...[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: badge.color.withValues(alpha: 0.25),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.newBadge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (isLocked)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: cs.slate700,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Badge Title
              Text(
                badge.title,
                style: tt.bodySmall?.copyWith(
                  fontWeight: isEarned ? FontWeight.w700 : FontWeight.w600,
                  color: isLocked ? cs.slate400 : cs.slate900,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),

              // Description / Status
              if (isEarned) ...[
                if (badge.earnedAt != null)
                  Text(
                    _formatDate(badge.earnedAt!),
                    style: TextStyle(
                      color: badge.color,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars_rounded, size: 12, color: badge.color),
                      const SizedBox(width: 2),
                      Text(
                        'Đã đạt',
                        style: TextStyle(
                          color: badge.color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ] else if (isInProgress) ...[
                const SizedBox(height: 4),
                MiniProgressBar(
                  percent: badge.progressPercent,
                  color: displayColor,
                ),
                const SizedBox(height: 2),
                Text(
                  '${(badge.progressPercent * 100).round()}%',
                  style: TextStyle(
                    color: badge.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ] else ...[
                Text(
                  'Chưa mở khóa',
                  style: TextStyle(color: cs.slate400, fontSize: 10),
                ),
              ],
            ],
          ),
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
    final displayColor = isLocked
        ? const Color(0xFF94A3B8)
        : (isInProgress ? color.withValues(alpha: 0.75) : color);

    return CustomPaint(
      painter: HexagonPainter(color: displayColor, isLocked: isLocked),
      child: SizedBox(
        width: 52,
        height: 60,
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: isLocked ? Colors.white60 : Colors.white,
          ),
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
      ..color = isLocked ? Colors.white24 : Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

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
  const MiniProgressBar({
    super.key,
    required this.percent,
    required this.color,
  });

  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: percent,
          backgroundColor: const Color(0xFFE2E8F0),
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
    this.color,
    this.size = 32,
    this.strokeWidth = 3,
  });

  final double percent;
  final Color? color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: percent,
        strokeWidth: strokeWidth,
        backgroundColor: const Color(0xFFE2E8F0),
        valueColor: AlwaysStoppedAnimation(progressColor),
      ),
    );
  }
}
