import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/presentation/widgets/dashboard/rank_avatar_frame.dart';

class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({
    super.key,
    this.name = 'Tran Minh Quan',
    this.level = 50,
    this.avatarUrl,
    this.totalXP = 12500,
    this.completedCourses = 8,
    this.totalHours = 156,
    this.rankPosition = 5,
    this.totalStudents = 234,
  });

  final String name;
  final int level;
  final String? avatarUrl;
  final int totalXP;
  final int completedCourses;
  final int totalHours;
  final int rankPosition;
  final int totalStudents;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rank = StudentRankX.fromLevel(level);

    return Column(
      children: [
        // Main profile card
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderXxl,
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
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
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    // Avatar
                    RankAvatarFrame(
                      rank: rank,
                      size: 100,
                      imageUrl: avatarUrl,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Name
                    Text(
                      name,
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Rank badge
                    _RankBadge(rank: rank, level: level),
                    const SizedBox(height: AppSpacing.sm),
                    // XP info
                    Text(
                      '$totalXP XP',
                      style: tt.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Stats section
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.school_rounded,
                        value: '$completedCourses',
                        label: 'Khoa hoc',
                        color: cs.primary,
                      ),
                    ),
                    _VerticalDivider(color: cs.outline),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.schedule_rounded,
                        value: '${totalHours}h',
                        label: 'Gio hoc',
                        color: cs.secondary,
                      ),
                    ),
                    _VerticalDivider(color: cs.outline),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.leaderboard_rounded,
                        value: '#$rankPosition',
                        label: 'Top $totalStudents',
                        color: cs.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 50,
      color: color.withValues(alpha: 0.3),
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
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: rank.frameColors),
        borderRadius: AppRadius.borderLg,
        boxShadow: [
          BoxShadow(
            color: rank.frameColors.first.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Level $level',
            style: tt.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            width: 1,
            height: 16,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          Text(
            rank.displayName.toUpperCase(),
            style: tt.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
