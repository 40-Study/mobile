import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Swipe action configuration
class TeacherSwipeAction {
  const TeacherSwipeAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onAction,
    this.confirmMessage,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Future<bool> Function() onAction;
  final String? confirmMessage; // Nếu có, hiện confirm dialog
}

/// Wrapper widget cho swipe-to-action pattern.
/// Hỗ trợ swipe trái (primary action) và swipe phải (secondary action).
class TeacherSwipeActionWrapper extends StatelessWidget {
  const TeacherSwipeActionWrapper({
    super.key,
    required this.child,
    required this.itemKey,
    this.leftAction,
    this.rightAction,
    this.enabled = true,
    this.onDismissed,
  });

  final Widget child;
  final Key itemKey;
  final TeacherSwipeAction? leftAction; // Swipe right reveals left action
  final TeacherSwipeAction? rightAction; // Swipe left reveals right action
  final bool enabled;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    if (!enabled || (leftAction == null && rightAction == null)) {
      return child;
    }

    return Dismissible(
      key: itemKey,
      direction: _direction,
      confirmDismiss: (direction) => _handleSwipe(context, direction),
      onDismissed: (_) => onDismissed?.call(),
      background: leftAction != null
          ? _buildBackground(context, leftAction!, Alignment.centerLeft)
          : null,
      secondaryBackground: rightAction != null
          ? _buildBackground(context, rightAction!, Alignment.centerRight)
          : null,
      child: child,
    );
  }

  DismissDirection get _direction {
    if (leftAction != null && rightAction != null) {
      return DismissDirection.horizontal;
    } else if (leftAction != null) {
      return DismissDirection.startToEnd;
    } else {
      return DismissDirection.endToStart;
    }
  }

  Future<bool> _handleSwipe(BuildContext context, DismissDirection direction) async {
    final action = direction == DismissDirection.startToEnd
        ? leftAction
        : rightAction;

    if (action == null) return false;

    // Nếu có confirm message, hiện dialog
    if (action.confirmMessage != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(action.label),
          content: Text(action.confirmMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: action.color,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
      if (confirmed != true) return false;
    }

    // Execute action
    final success = await action.onAction();
    return success;
  }

  Widget _buildBackground(
    BuildContext context,
    TeacherSwipeAction action,
    Alignment alignment,
  ) {
    final isLeft = alignment == Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(
        left: isLeft ? 24 : 0,
        right: isLeft ? 0 : 24,
      ),
      decoration: BoxDecoration(
        color: action.color,
        borderRadius: AppRadius.borderLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                Icon(action.icon, color: Colors.white),
                AppSpacing.hGap8,
                Text(
                  action.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            : [
                Text(
                  action.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.hGap8,
                Icon(action.icon, color: Colors.white),
              ],
      ),
    );
  }
}

/// Simplified swipe action - chỉ swipe một hướng
class TeacherSwipeToAction extends StatelessWidget {
  const TeacherSwipeToAction({
    super.key,
    required this.child,
    required this.itemKey,
    required this.icon,
    required this.label,
    required this.color,
    required this.onAction,
    this.direction = DismissDirection.endToStart,
    this.enabled = true,
    this.confirmMessage,
  });

  final Widget child;
  final Key itemKey;
  final IconData icon;
  final String label;
  final Color color;
  final Future<bool> Function() onAction;
  final DismissDirection direction;
  final bool enabled;
  final String? confirmMessage;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Dismissible(
      key: itemKey,
      direction: direction,
      confirmDismiss: (_) => _handleSwipe(context),
      background: direction == DismissDirection.startToEnd
          ? _buildBackground(context, Alignment.centerLeft)
          : null,
      secondaryBackground: direction == DismissDirection.endToStart
          ? _buildBackground(context, Alignment.centerRight)
          : null,
      child: child,
    );
  }

  Future<bool> _handleSwipe(BuildContext context) async {
    if (confirmMessage != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(label),
          content: Text(confirmMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: color),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
      if (confirmed != true) return false;
    }

    return onAction();
  }

  Widget _buildBackground(BuildContext context, Alignment alignment) {
    final isLeft = alignment == Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: EdgeInsets.only(
        left: isLeft ? 24 : 0,
        right: isLeft ? 0 : 24,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.borderLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isLeft
            ? [
                Icon(icon, color: Colors.white),
                AppSpacing.hGap8,
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.hGap8,
                Icon(icon, color: Colors.white),
              ],
      ),
    );
  }
}
