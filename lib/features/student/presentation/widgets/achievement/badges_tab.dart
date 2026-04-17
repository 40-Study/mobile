import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/achievement/achievement_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class BadgesTab extends StatelessWidget {
  const BadgesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementCubit, AchievementState>(
      builder: (context, state) {
        if (state is AchievementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AchievementFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Khong the tai thanh tich'),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () =>
                      context.read<AchievementCubit>().loadAchievements(),
                  child: const Text('Thu lai'),
                ),
              ],
            ),
          );
        }

        if (state is AchievementLoaded) {
          final achievements = state.allAchievements;
          final myAchievementIds =
              state.myAchievements.map((a) => a.id).toSet();

          if (achievements.isEmpty) {
            return const Center(
              child: Text('Chua co thanh tich nao'),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              AppSpacing.lg,
              AppLayout.screenMargin,
              AppSpacing.massive,
            ),
            children: [
              _AchievementSummary(
                unlocked: state.unlockedCount,
                total: state.totalCount,
              ),
              const SizedBox(height: AppSpacing.lg),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.95,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  final isUnlocked = myAchievementIds.contains(achievement.id);
                  return _BadgeCard(
                    achievement: achievement,
                    isUnlocked: isUnlocked,
                  );
                },
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _AchievementSummary extends StatelessWidget {
  const _AchievementSummary({
    required this.unlocked,
    required this.total,
  });

  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: AppLayout.cardPaddingCompact,
      decoration: BoxDecoration(
        color: cs.surfaceTintedPrimary,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, size: AppIconSize.lg, color: cs.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Ban da mo khoa $unlocked/$total thanh tich',
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.achievement,
    required this.isUnlocked,
  });

  final AchievementModel achievement;
  final bool isUnlocked;

  Color get _categoryColor {
    switch (achievement.category?.toLowerCase()) {
      case 'learning':
        return const Color(0xff2563eb);
      case 'streak':
        return const Color(0xfff97316);
      case 'coding':
        return const Color(0xff8b5cf6);
      case 'social':
        return const Color(0xff06b6d4);
      case 'completion':
        return const Color(0xff10b981);
      default:
        return const Color(0xff6366f1);
    }
  }

  IconData get _categoryIcon {
    switch (achievement.category?.toLowerCase()) {
      case 'learning':
        return Icons.school_rounded;
      case 'streak':
        return Icons.local_fire_department_rounded;
      case 'coding':
        return Icons.code_rounded;
      case 'social':
        return Icons.groups_rounded;
      case 'completion':
        return Icons.check_circle_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _categoryColor;

    return Container(
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderXl,
        border: Border.all(
          color: isUnlocked ? color.withValues(alpha: 0.3) : cs.outline,
          width: isUnlocked ? 1.5 : 1,
        ),
        boxShadow: isUnlocked ? cs.shadowCard : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? color.withValues(alpha: 0.1)
                  : cs.surfaceContainerLow,
              shape: BoxShape.circle,
              border: isUnlocked
                  ? Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              isUnlocked ? _categoryIcon : Icons.lock_rounded,
              size: AppIconSize.xl,
              color: isUnlocked
                  ? color
                  : cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            achievement.name,
            style: tt.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isUnlocked
                  ? cs.onSurface
                  : cs.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            achievement.description ?? '',
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isUnlocked && achievement.progress != null) ...[
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: achievement.progress,
              backgroundColor: cs.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${((achievement.progress ?? 0) * 100).toInt()}%',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
