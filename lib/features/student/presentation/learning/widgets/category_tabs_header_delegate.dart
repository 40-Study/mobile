import 'package:flutter/material.dart';

/// Delegate cho SliverPersistentHeader giúp ghim thanh Category/Filter Chips
/// mượt mà khi người dùng cuộn nội dung màn hình.
class CategoryTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const CategoryTabsHeaderDelegate({
    required this.child,
    this.height = 52.0,
  });

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      color: cs.surface,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant CategoryTabsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
