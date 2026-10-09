import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/home/widgets/assignment_item.dart';
import 'package:study/theme/theme.dart';

class AssignmentList extends StatelessWidget {
  const AssignmentList({super.key, required this.assignments, this.onItemTap});

  final List<AssignmentModel> assignments;
  final void Function(AssignmentModel)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (assignments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.6),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 26,
                color: Color(0xFF059669),
              ),
            ),
            AppSpacing.vGap12,
            Text(
              'Không còn bài tập tồn đọng',
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.slate900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Tuyệt vời! Bạn đã hoàn thành tất cả nhiệm vụ được giao.',
              style: tt.bodySmall?.copyWith(
                color: cs.slate500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        itemCount: assignments.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 52,
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return AssignmentItem(
            assignment: assignment,
            onTap: () => onItemTap?.call(assignment),
          );
        },
      ),
    );
  }
}
