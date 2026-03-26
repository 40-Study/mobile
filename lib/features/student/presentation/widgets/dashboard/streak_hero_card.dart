import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class StreakHeroCard extends StatelessWidget {
  const StreakHeroCard({
    super.key,
    required this.streakDays,
    required this.totalClasses,
  });

  final int streakDays;
  final int totalClasses;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderXxxl,
        gradient: cs.gradientRich,
        boxShadow: cs.shadowPrimary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        color: cs.tertiary, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'HOC TAP MOI NGAY',
                      style: TextStyle(
                        color: cs.onPrimary.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$streakDays',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      TextSpan(
                        text: ' Ngay',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Dung bo lo! Ban chi can 1 bai hoc\n'
                  'nua de dat moc ${streakDays + 1} ngay.',
                  style: TextStyle(
                    color: cs.onPrimary.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppLayout.gutter),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.onPrimary.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderLg,
              border: Border.all(
                color: cs.onPrimary.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.scrim.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: cs.onPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
