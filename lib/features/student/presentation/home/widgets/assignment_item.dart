import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';

class AssignmentItem extends StatelessWidget {
  const AssignmentItem({
    super.key,
    required this.assignment,
    this.onTap,
  });

  final AssignmentModel assignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final daysLeft = assignment.dueDate != null
        ? assignment.dueDate!.difference(DateTime.now()).inDays
        : null;
    final isUrgent = daysLeft != null && daysLeft < 3;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isUrgent ? cs.error : cs.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          assignment.type == 'quiz' ? Icons.quiz : Icons.assignment,
          color: isUrgent ? cs.error : cs.primary,
          size: 20,
        ),
      ),
      title: Text(
        assignment.title,
        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${assignment.courseName ?? "Khoa hoc"} • ${assignment.questionCount} cau hoi',
        style: tt.bodySmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (daysLeft != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isUrgent ? cs.error : cs.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Con $daysLeft ngay',
                style: tt.labelSmall?.copyWith(
                  color: isUrgent ? cs.error : cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          AppSpacing.hGap8,
          TextButton(onPressed: onTap, child: const Text('Lam')),
        ],
      ),
    );
  }
}
