import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/home/widgets/assignment_item.dart';
import 'package:study/theme/theme.dart';

class AssignmentList extends StatelessWidget {
  const AssignmentList({
    super.key,
    required this.assignments,
    this.onItemTap,
  });

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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green.withValues(alpha: 0.5),
              ),
              AppSpacing.vGap8,
              Text(
                'Hoan thanh tat ca bai tap!',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: assignments.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
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
