import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class BadgeGrid extends StatelessWidget {
  const BadgeGrid({super.key, required this.badges});

  final List<BadgeModel> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return _buildEmpty(context);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) => _BadgeItem(badge: badges[index]),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(Icons.emoji_events_outlined, size: 48, color: cs.outline),
            AppSpacing.vGap12,
            Text(
              'Chua co huy hieu',
              style: tt.bodyMedium?.copyWith(color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  const _BadgeItem({required this.badge});

  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _showBadgeDetail(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: badge.isEarned
              ? Border.all(color: cs.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badge.isEarned
                    ? cs.primary.withValues(alpha: 0.1)
                    : cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(badge.category),
                size: 20,
                color: badge.isEarned ? cs.primary : cs.outline,
              ),
            ),
            AppSpacing.vGap4,
            Text(
              badge.name,
              style: tt.labelSmall?.copyWith(
                color: badge.isEarned ? cs.onSurface : cs.outline,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!badge.isEarned)
              Icon(Icons.lock, size: 12, color: cs.outline),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String? category) {
    return switch (category) {
      'learning' => Icons.school,
      'streak' => Icons.local_fire_department,
      'course' => Icons.menu_book,
      'quiz' => Icons.quiz,
      'speed' => Icons.bolt,
      _ => Icons.emoji_events,
    };
  }

  void _showBadgeDetail(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: badge.isEarned
                    ? cs.primary.withValues(alpha: 0.1)
                    : cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(badge.category),
                size: 32,
                color: badge.isEarned ? cs.primary : cs.outline,
              ),
            ),
            AppSpacing.vGap16,
            Text(
              badge.name,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGap8,
            Text(
              badge.description ?? '',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            if (badge.isEarned && badge.earnedAt != null)
              Text(
                'Dat duoc: ${_formatDate(badge.earnedAt!)}',
                style: tt.bodySmall?.copyWith(color: cs.outline),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Chua mo khoa',
                  style: tt.labelMedium?.copyWith(color: cs.outline),
                ),
              ),
            AppSpacing.vGap24,
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
