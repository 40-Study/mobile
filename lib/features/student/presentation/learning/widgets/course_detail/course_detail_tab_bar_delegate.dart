import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class CourseDetailTabBarDelegate extends SliverPersistentHeaderDelegate {
  CourseDetailTabBarDelegate({required this.tabController, required this.cs});
  final TabController tabController;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: cs.surface,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        indicatorWeight: 2,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        tabs: const [
          Tab(text: 'Tổng quan'),
          Tab(text: 'Nội dung khóa học'),
          Tab(text: 'Giảng viên'),
          Tab(text: 'Đánh giá'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
