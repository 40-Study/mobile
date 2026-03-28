import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';

class AchievementTabBarDelegate extends SliverPersistentHeaderDelegate {
  const AchievementTabBarDelegate({required this.tabCtrl});
  final TabController tabCtrl;

  static const _labels = ['Danh hieu', 'Chung chi', 'Stickers'];

  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.screenMargin,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.borderXxl,
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / _labels.length;
            return AnimatedBuilder(
              animation: tabCtrl.animation!,
              builder: (context, _) {
                final animValue = tabCtrl.animation!.value;
                return Stack(
                  children: [
                    // Indicator follows animation value directly
                    Positioned(
                      left: animValue * itemWidth,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: AppRadius.borderXl,
                          boxShadow: [
                            BoxShadow(
                              color: cs.shadow.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tab items
                    Row(
                      children: List.generate(_labels.length, (i) {
                        // Calculate selection based on distance from animation
                        final distance = (animValue - i).abs();
                        final isSelected = distance < 0.5;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => tabCtrl.animateTo(i),
                            child: Center(
                              child: Text(
                                _labels[i],
                                style: (tt.bodyMedium ?? const TextStyle())
                                    .copyWith(
                                  color: isSelected
                                      ? cs.onSurface
                                      : cs.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant AchievementTabBarDelegate oldDelegate) => false;
}
