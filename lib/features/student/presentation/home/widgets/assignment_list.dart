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

    if (assignments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: cs.outline),
          boxShadow: AppShadows.layeredCard,
        ),
        clipBehavior: Clip.antiAlias,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 48, color: cs.secondary),
              AppSpacing.vGap8,
              Text(
                'Bạn đã hoàn thành tất cả bài tập',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outline),
        boxShadow: AppShadows.layeredCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: assignments.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, indent: 56, color: cs.outlineVariant),
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
