import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_achievement_data.dart';
import 'package:study/theme/app_colors.dart';

class StickersTab extends StatelessWidget {
  const StickersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final unlockedCount =
        mockStickers.where((s) => s.unlocked).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.lg,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      children: [
        Container(
          padding: AppLayout.cardPaddingCompact,
          decoration: BoxDecoration(
            color: cs.surfaceTintedPrimary,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Text('🏅', style: tt.titleLarge),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bo suu tap: '
                      '$unlockedCount/${mockStickers.length}',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: AppRadius.borderXs,
                      child: LinearProgressIndicator(
                        value: unlockedCount /
                            mockStickers.length,
                        minHeight: 6,
                        backgroundColor: cs.primary
                            .withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(
                            cs.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            _RarityChip(
              label: 'Common',
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            const _RarityChip(
              label: 'Rare',
              color: Color(0xff2563eb),
            ),
            const SizedBox(width: AppSpacing.sm),
            const _RarityChip(
              label: 'Epic',
              color: Color(0xff8b5cf6),
            ),
            const SizedBox(width: AppSpacing.sm),
            const _RarityChip(
              label: 'Legendary',
              color: Color(0xfff59e0b),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.8,
          ),
          itemCount: mockStickers.length,
          itemBuilder: (context, index) =>
              _StickerCard(sticker: mockStickers[index]),
        ),
      ],
    );
  }
}

class _RarityChip extends StatelessWidget {
  const _RarityChip({
    required this.label,
    required this.color,
  });
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderSm,
        border:
            Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _StickerCard extends StatelessWidget {
  const _StickerCard({required this.sticker});
  final StickerItem sticker;

  Color get _rarityColor {
    switch (sticker.rarity) {
      case 'Rare':
        return const Color(0xff2563eb);
      case 'Epic':
        return const Color(0xff8b5cf6);
      case 'Legendary':
        return const Color(0xfff59e0b);
      default:
        return const Color(0xff6b7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: sticker.unlocked
              ? _rarityColor.withValues(alpha: 0.3)
              : cs.outline,
          width: sticker.unlocked ? 1.5 : 1,
        ),
        boxShadow:
            sticker.unlocked ? cs.shadowCard : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            sticker.unlocked ? sticker.emoji : '🔒',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            sticker.title,
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: sticker.unlocked
                  ? cs.onSurface
                  : cs.onSurfaceVariant
                      .withValues(alpha: 0.5),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: sticker.unlocked
                  ? _rarityColor.withValues(alpha: 0.1)
                  : cs.surfaceContainerLow,
              borderRadius: AppRadius.borderXs,
            ),
            child: Text(
              sticker.rarity,
              style: tt.labelSmall?.copyWith(
                color: sticker.unlocked
                    ? _rarityColor
                    : cs.onSurfaceVariant
                        .withValues(alpha: 0.4),
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
