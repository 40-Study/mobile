import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/presentation/widgets/dashboard/rank_avatar_frame.dart';

export 'rank_avatar_frame.dart' show StudentRank, StudentRankX, RankAvatarFrame;

class LevelHeroCard extends StatelessWidget {
  const LevelHeroCard({
    super.key,
    required this.level,
    required this.name,
    this.avatarUrl,
    this.streakDays = 7,
  });

  final int level;
  final String name;
  final String? avatarUrl;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rank = StudentRankX.fromLevel(level);

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderXxl,
        color: cs.surfaceContainerLowest,
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                // Greeting and avatar row
                Row(
                  children: [
                    // Avatar with rank frame
                    RankAvatarFrame(
                      rank: rank,
                      size: 88,
                      imageUrl: avatarUrl,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    // Greeting and level
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chao mung tro lai,',
                            style: tt.bodyLarge?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            name,
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              _RankBadge(rank: rank, level: level),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      size: 14,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '$streakDays',
                                      style: tt.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Achievement section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thanh tuu gan day',
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _AchievementBadges(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.level});

  final StudentRank rank;
  final int level;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: rank.frameColors),
        borderRadius: AppRadius.borderSm,
        boxShadow: [
          BoxShadow(
            color: rank.frameColors.first.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lv.$level',
            style: tt.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            rank.displayName.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadges extends StatelessWidget {
  const _AchievementBadges();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _AchievementChip(
          icon: Icons.code,
          label: 'Tho san thuat toan',
          color: Color(0xFF6366F1),
        ),
        _AchievementChip(
          icon: Icons.local_fire_department,
          label: '7 ngay lien tiep',
          color: Color(0xFFF59E0B),
        ),
        _AchievementChip(
          icon: Icons.star,
          label: 'Top 10 lop',
          color: Color(0xFF10B981),
        ),
      ],
    );
  }
}

class _AchievementChip extends StatelessWidget {
  const _AchievementChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: tt.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
