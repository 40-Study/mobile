import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';

class TeacherCourseTabBarDelegate extends SliverPersistentHeaderDelegate {
  const TeacherCourseTabBarDelegate({
    required this.tabCtrl,
    required this.tabs,
  });

  final TabController tabCtrl;
  final List<String> tabs;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  bool shouldRebuild(covariant TeacherCourseTabBarDelegate oldDelegate) =>
      tabCtrl != oldDelegate.tabCtrl || tabs != oldDelegate.tabs;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      child: TabBar(
        controller: tabCtrl,
        tabs: tabs.map((t) => Tab(text: t)).toList(),
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
    );
  }
}
