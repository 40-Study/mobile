import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class AssignmentItem extends StatelessWidget {
  const AssignmentItem({super.key, required this.assignment, this.onTap});

  final AssignmentModel assignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final daysLeft = assignment.dueDate?.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft != null && daysLeft >= 0 && daysLeft < 3;
    final isOverdue = daysLeft != null && daysLeft < 0;
    final statusColor = isUrgent || isOverdue ? cs.error : cs.tertiary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isUrgent || isOverdue
              ? cs.errorContainer
              : cs.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          assignment.type == 'quiz' ? Icons.quiz : Icons.assignment,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(
        assignment.title,
        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Text(
              '${assignment.courseName ?? "Khóa học"} • '
              '${assignment.questionCount} câu hỏi',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (daysLeft != null)
              Text(
                isOverdue
                    ? 'Đã quá hạn'
                    : daysLeft == 0
                    ? 'Hạn hôm nay'
                    : 'Còn $daysLeft ngày',
                style: tt.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
