import 'package:flutter/material.dart';
import 'package:study/data/daily_goals_storage.dart';
import 'package:study/theme/theme.dart';

class GoalTile extends StatelessWidget {
  const GoalTile({
    super.key,
    required this.goal,
    required this.onToggle,
    required this.onDelete,
  });

  final DailyGoalItem goal;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.errorContainer, cs.error.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(Icons.delete_outline, size: 22, color: cs.onError),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: goal.isCompleted
              ? cs.primaryContainer.withValues(alpha: 0.3)
              : cs.surface,
          border: Border.all(
            color: goal.isCompleted
                ? cs.primary.withValues(alpha: 0.3)
                : cs.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: goal.isCompleted ? cs.primary : Colors.transparent,
                      border: Border.all(
                        color: goal.isCompleted ? cs.primary : cs.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: goal.isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Text(
                      goal.title,
                      style: tt.bodyMedium?.copyWith(
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: goal.isCompleted
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                        fontWeight: goal.isCompleted ? null : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (goal.isCompleted)
                    Icon(
                      Icons.celebration,
                      size: 16,
                      color: cs.primary.withValues(alpha: 0.6),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
