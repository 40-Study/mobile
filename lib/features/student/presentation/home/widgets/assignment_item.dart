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
    final isOverdue = daysLeft != null && daysLeft < 0;
    final isUrgent = daysLeft != null && daysLeft >= 0 && daysLeft < 3;
    final statusColor = isUrgent || isOverdue ? cs.error : cs.tertiary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: AppSpacing.md,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          assignment.type == 'quiz'
              ? Icons.quiz_outlined
              : Icons.assignment_outlined,
          color: statusColor,
          size: 21,
        ),
      ),
      title: Text(
        assignment.title,
        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          '${assignment.courseName ?? "Khóa học"} • '
          '${assignment.questionCount} câu hỏi',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: daysLeft == null
          ? Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant)
          : SizedBox(
              width: 64,
              child: Text.rich(
                TextSpan(
                  text: '${isOverdue ? "Trạng thái" : "Còn lại"}\n',
                  children: [
                    TextSpan(
                      text: isOverdue
                          ? 'Quá hạn'
                          : daysLeft == 0
                          ? 'Hôm nay'
                          : '$daysLeft ngày',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
                textAlign: TextAlign.end,
                maxLines: 2,
              ),
            ),
      onTap: onTap,
    );
  }
}
