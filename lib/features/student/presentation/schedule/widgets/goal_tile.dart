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

  String _deriveCategory(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('quiz') || lower.contains('bài tập') || lower.contains('kiểm tra')) {
      return 'Bài tập';
    }
    if (lower.contains('ôn') || lower.contains('review')) {
      return 'Ôn tập';
    }
    if (lower.contains('bài') || lower.contains('video') || lower.contains('học')) {
      return 'Khóa học';
    }
    return 'Học tập';
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Bài tập':
        return const Color(0xFFF59E0B);
      case 'Ôn tập':
        return const Color(0xFF8B5CF6);
      case 'Khóa học':
      default:
        return const Color(0xFF3D5FC4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDone = goal.isCompleted;
    final category = _deriveCategory(goal.title);
    final catColor = _categoryColor(category);

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Xóa mục tiêu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, size: 20, color: Colors.white),
          ],
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDone
              ? const Color(0xFFF8FAFC)
              : cs.surfaceContainerLowest,
          border: Border.all(
            color: isDone
                ? const Color(0xFFE2E8F0)
                : cs.outlineVariant.withValues(alpha: 0.6),
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // Animated Round Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? const Color(0xFF3D5FC4)
                          : Colors.transparent,
                      border: Border.all(
                        color: isDone
                            ? const Color(0xFF3D5FC4)
                            : const Color(0xFF94A3B8),
                        width: 1.8,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                        : null,
                  ),
                  AppSpacing.hGap12,

                  // Title and Category Tag
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: tt.bodyMedium?.copyWith(
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            decorationColor: const Color(0xFF94A3B8),
                            color: isDone ? const Color(0xFF94A3B8) : cs.slate900,
                            fontWeight: isDone ? FontWeight.w400 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: catColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isDone ? 'Đã hoàn thành' : 'Đang thực hiện',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDone ? const Color(0xFF059669) : cs.slate500,
                                fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (isDone)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.celebration_rounded,
                        size: 18,
                        color: Color(0xFFF59E0B),
                      ),
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
