import 'package:flutter/material.dart';

/// Delegate cho SliverPersistentHeader để ghim thanh chọn con (Pinned / Sticky)
/// ở đỉnh màn hình khi cuộn trang, giúp phụ huynh đổi con tức thì mà không cần
/// cuộn ngược lên đầu.
class PinnedFamilyScopeHeaderDelegate extends SliverPersistentHeaderDelegate {
  PinnedFamilyScopeHeaderDelegate({
    required this.child,
    required this.backgroundColor,
    this.height = 56.0,
  });

  final Widget child;
  final Color backgroundColor;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isPinned = shrinkOffset > 0 || overlapsContent;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant PinnedFamilyScopeHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        backgroundColor != oldDelegate.backgroundColor ||
        height != oldDelegate.height;
  }
}
