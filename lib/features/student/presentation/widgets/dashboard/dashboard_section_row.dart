import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';

class DashboardSectionRow extends StatelessWidget {
  const DashboardSectionRow({
    super.key,
    required this.title,
    this.action,
    this.actionColor,
    this.onActionTap,
  });

  final String title;
  final String? action;
  final Color? actionColor;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final textColor = cs.onSurface;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              action!,
              style: tt.bodyLarge?.copyWith(
                color: actionColor ?? cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
