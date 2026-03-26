import 'package:flutter/material.dart';

class CourseTabBarDelegate extends SliverPersistentHeaderDelegate {
  CourseTabBarDelegate({required this.tabCtrl, required this.tabs});

  final TabController tabCtrl;
  final List<String> tabs;

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      child: TabBar(
        controller: tabCtrl,
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        indicatorWeight: 2.5,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        unselectedLabelStyle:
            Theme.of(context).textTheme.labelLarge,
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant CourseTabBarDelegate oldDelegate) =>
      tabCtrl != oldDelegate.tabCtrl;
}
