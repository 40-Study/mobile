import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    this.onTap,
  });

  final ChildAssignmentModel assignment;
  final VoidCallback? onTap;

  Color _statusColor(ColorScheme cs) {
    switch (assignment.status) {
      case AssignmentStatus.completed:
        return Colors.green;
      case AssignmentStatus.missing:
        return Colors.red;
      case AssignmentStatus.late:
        return Colors.orange;
      case AssignmentStatus.pending:
        return cs.primary;
    }
  }

  String get _statusText {
    switch (assignment.status) {
      case AssignmentStatus.completed:
        return 'Hoàn thành';
      case AssignmentStatus.missing:
        return 'Thiếu';
      case AssignmentStatus.late:
        return 'Muộn';
      case AssignmentStatus.pending:
        return 'Đang chờ';
    }
  }

  IconData get _statusIcon {
    switch (assignment.status) {
      case AssignmentStatus.completed:
        return Icons.check_circle;
      case AssignmentStatus.missing:
        return Icons.cancel;
      case AssignmentStatus.late:
        return Icons.access_time;
      case AssignmentStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = _statusColor(cs);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (assignment.className != null) ...[
                        Text(
                          assignment.className!,
                          style: TextStyle(
                            color: cs.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '•',
                          style: TextStyle(color: cs.textSecondary),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (assignment.score != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${assignment.score}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: cs.primary,
                    ),
                  ),
                  Text(
                    '/${assignment.maxScore ?? 10}',
                    style: TextStyle(
                      color: cs.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            else
              Icon(
                Icons.chevron_right,
                color: cs.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
