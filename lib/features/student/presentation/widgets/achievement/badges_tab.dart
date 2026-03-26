import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_achievement_data.dart';
import 'package:study/theme/app_colors.dart';

class BadgesTab extends StatelessWidget {
  const BadgesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.lg,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.95,
          ),
          itemCount: mockBadges.length,
          itemBuilder: (context, index) =>
              _BadgeCard(badge: mockBadges[index]),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        _SummaryStatCard(
          label: 'TONG THOI GIAN HOC',
          value: '124h',
          icon: Icons.schedule_rounded,
          gradient: cs.gradientPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        _SummaryStatCard(
          label: 'CHUNG CHI DA NHAN',
          value: '15',
          icon: Icons.verified_rounded,
          gradient: cs.gradientWarm,
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final BadgeItem badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: badge.unlocked
              ? badge.color.withValues(alpha: 0.3)
              : cs.outline,
          width: badge.unlocked ? 1.5 : 1,
        ),
        boxShadow: badge.unlocked ? cs.shadowCard : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: badge.unlocked
                  ? badge.color.withValues(alpha: 0.1)
                  : cs.surfaceContainerLow,
              shape: BoxShape.circle,
              border: badge.unlocked
                  ? Border.all(
                      color:
                          badge.color.withValues(alpha: 0.2),
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              badge.unlocked
                  ? badge.icon
                  : Icons.lock_rounded,
              size: AppIconSize.xl,
              color: badge.unlocked
                  ? badge.color
                  : cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            badge.title,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: badge.unlocked
                  ? cs.onSurface
                  : cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            badge.description,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadius.borderXl,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first
                .withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: tt.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: AppIconSize.xl, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
