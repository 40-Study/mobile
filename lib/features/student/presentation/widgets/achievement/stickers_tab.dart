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
    final allStickers = mockStickers;
    final unlockedCount = allStickers.where((s) => s.unlocked).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.lg,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      children: [
        // Overall progress
        Container(
          padding: AppLayout.cardPaddingCompact,
          decoration: BoxDecoration(
            color: cs.surfaceTintedPrimary,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Text('🎨', style: tt.titleLarge),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bo suu tap: $unlockedCount/${allStickers.length}',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: AppRadius.borderXs,
                      child: LinearProgressIndicator(
                        value: unlockedCount / allStickers.length,
                        minHeight: 6,
                        backgroundColor: cs.primary.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(cs.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Collection cards
        ...mockStickerCollections.map((collection) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _CollectionCard(collection: collection),
          );
        }),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection});

  final StickerCollection collection;

  void _showCollectionPopup(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => _CollectionPopup(collection: collection),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = collection.unlockedCount / collection.stickers.length;

    return GestureDetector(
      onTap: () => _showCollectionPopup(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: collection.isCompleted
                ? collection.color.withValues(alpha: 0.5)
                : cs.outline.withValues(alpha: 0.3),
            width: collection.isCompleted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Cover emoji
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: collection.color.withValues(alpha: 0.15),
                borderRadius: AppRadius.borderMd,
              ),
              child: Center(
                child: Text(
                  collection.coverEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        collection.name,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      if (collection.isCompleted) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: collection.color,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    collection.description,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: AppRadius.borderXs,
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor:
                                collection.color.withValues(alpha: 0.15),
                            valueColor:
                                AlwaysStoppedAnimation(collection.color),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${collection.unlockedCount}/${collection.stickers.length}',
                        style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: collection.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionPopup extends StatelessWidget {
  const _CollectionPopup({required this.collection});

  final StickerCollection collection;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        width: screenWidth * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderXxl,
          border: Border.all(
            color: collection.color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: collection.color.withValues(alpha: 0.15),
                borderRadius: AppRadius.borderXl,
                border: Border.all(
                  color: collection.color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  collection.coverEmoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              collection.name,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              collection.description,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            // Progress
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: collection.color.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderMd,
              ),
              child: Text(
                '${collection.unlockedCount}/${collection.stickers.length} da mo khoa',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: collection.color,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Stickers grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.9,
              ),
              itemCount: collection.stickers.length,
              itemBuilder: (context, index) {
                final sticker = collection.stickers[index];
                return _StickerGridItem(
                  sticker: sticker,
                  color: collection.color,
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: cs.surfaceContainerLow,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
                child: Text(
                  'Dong',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerGridItem extends StatelessWidget {
  const _StickerGridItem({required this.sticker, required this.color});

  final StickerItem sticker;
  final Color color;

  void _showStickerDetail(BuildContext context) {
    if (!sticker.unlocked) return;

    showDialog<void>(
      context: context,
      builder: (context) => _StickerDetailPopup(sticker: sticker, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _showStickerDetail(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: sticker.unlocked
              ? color.withValues(alpha: 0.1)
              : cs.surfaceContainerLow,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: sticker.unlocked
                ? color.withValues(alpha: 0.3)
                : cs.outline.withValues(alpha: 0.2),
            width: sticker.unlocked ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              sticker.unlocked ? sticker.emoji : '🔒',
              style: TextStyle(fontSize: sticker.unlocked ? 32 : 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              sticker.title,
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: sticker.unlocked
                    ? cs.onSurface
                    : cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerDetailPopup extends StatelessWidget {
  const _StickerDetailPopup({required this.sticker, required this.color});

  final StickerItem sticker;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderXxl,
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Big sticker
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderXxl,
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  sticker.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              sticker.title,
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            // Download button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  // TODO: Implement download
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Da tai sticker "${sticker.title}"'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Tai ve'),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text(
                  'Dong',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

