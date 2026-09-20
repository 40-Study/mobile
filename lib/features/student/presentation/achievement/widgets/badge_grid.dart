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
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
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
              'Chưa có huy hiệu',
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

    return InkWell(
      onTap: () => _showBadgeDetail(context),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: badge.isEarned ? cs.outline : cs.outlineVariant,
          ),
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
                    ? cs.primaryContainer
                    : cs.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(badge.category),
                size: 20,
                color: badge.isEarned ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
            AppSpacing.vGap4,
            Text(
              badge.name,
              style: tt.labelSmall?.copyWith(
                color: badge.isEarned ? cs.onSurface : cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!badge.isEarned)
              Icon(Icons.lock_outline, size: 12, color: cs.onSurfaceVariant),
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Badge Detail',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim, secondAnim, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (context, anim, secondAnim) {
        return _BadgeDetailDialog(badge: badge);
      },
    );
  }
}

class _BadgeDetailDialog extends StatelessWidget {
  const _BadgeDetailDialog({required this.badge});

  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final size = MediaQuery.sizeOf(context);

    return Center(
      child: Container(
        width: size.width * 0.85,
        constraints: BoxConstraints(maxHeight: size.height * 0.75),
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header với gradient
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: badge.isEarned
                          ? [cs.primaryContainer, cs.secondaryContainer]
                          : [cs.surfaceContainer, cs.surfaceContainerHigh],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Badge icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: cs.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          _categoryIcon(badge.category),
                          size: 48,
                          color: badge.isEarned ? cs.primary : cs.outline,
                        ),
                      ),
                      // Earned badge decoration
                      if (badge.isEarned)
                        Positioned(
                          bottom: 20,
                          right: size.width * 0.2,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 24,
                            color: cs.tertiary.withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Category tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          _categoryName(badge.category),
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppSpacing.vGap16,

                      // Badge name
                      Text(
                        badge.name,
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.vGap12,

                      // Description
                      Text(
                        badge.description ?? 'Hoàn thành thử thách để mở khóa huy hiệu này.',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.vGap24,

                      // Status
                      if (badge.isEarned && badge.earnedAt != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.celebration_rounded,
                                size: 32,
                                color: cs.primary,
                              ),
                              AppSpacing.vGap8,
                              Text(
                                'Đã mở khóa!',
                                style: tt.titleSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              AppSpacing.vGap4,
                              Text(
                                'Đạt được ngày ${_formatDate(badge.earnedAt!)}',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 32,
                                color: cs.outline,
                              ),
                              AppSpacing.vGap8,
                              Text(
                                'Chưa mở khóa',
                                style: tt.titleSmall?.copyWith(
                                  color: cs.outline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AppSpacing.vGap4,
                              Text(
                                'Hoàn thành thử thách để nhận huy hiệu',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.outline,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _categoryName(String? category) {
    return switch (category) {
      'learning' => 'Học tập',
      'streak' => 'Chuỗi ngày',
      'course' => 'Khóa học',
      'quiz' => 'Bài kiểm tra',
      'speed' => 'Tốc độ',
      _ => 'Thành tích',
    };
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
