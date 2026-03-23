import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        if (actionLabel != null || actionIcon != null)
          TextButton.icon(
            onPressed: onActionTap,
            icon: actionIcon != null
                ? Icon(actionIcon, size: 18)
                : const SizedBox.shrink(),
            label: Text(actionLabel ?? ''),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }
}
