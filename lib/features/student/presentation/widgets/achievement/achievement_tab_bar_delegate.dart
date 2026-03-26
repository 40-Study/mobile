import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';

class AchievementTabBarDelegate
    extends SliverPersistentHeaderDelegate {
  const AchievementTabBarDelegate({required this.tabCtrl});
  final TabController tabCtrl;

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.screenMargin,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.borderXxl,
          border: Border.all(color: cs.outline),
        ),
        child: TabBar(
          controller: tabCtrl,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderXxl,
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Danh hieu'),
            Tab(text: 'Chung chi'),
            Tab(text: 'Stickers'),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(
    covariant AchievementTabBarDelegate oldDelegate,
  ) =>
      false;
}
