import 'package:flutter/material.dart';

class StudentSectionHeader extends StatelessWidget {
  const StudentSectionHeader({
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (actionLabel != null || actionIcon != null)
          TextButton.icon(
            onPressed: onActionTap,
            icon: actionIcon != null
                ? Icon(actionIcon, size: 16)
                : const SizedBox.shrink(),
            label: Text(
              actionLabel ?? '',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.primary,
                  ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
      ],
    );
  }
}
