import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/models/models.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({
    super.key,
    required this.student,
    this.onTap,
    this.onMoreTap,
  });

  final StudentModel student;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  Color _getProgressColor(BuildContext context, double progress) {
    if (progress >= 100) return Colors.green;
    if (progress >= 70) return Theme.of(context).colorScheme.primary;
    if (progress >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progressColor = _getProgressColor(context, student.progress);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header row
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: student.avatarUrl != null
                        ? NetworkImage(student.avatarUrl!)
                        : null,
                    child: student.avatarUrl == null
                        ? Text(
                            student.displayName.isNotEmpty
                                ? student.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.displayName,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          'ID: #${student.displayCode}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onMoreTap,
                    icon: const Icon(Icons.more_vert),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TIẾN ĐỘ',
                          style: tt.labelSmall?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '${student.progress.toInt()}%',
                          style: tt.titleSmall?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      student.enrolledCourse ?? 'Chưa đăng ký khóa học',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: student.progress / 100,
                        backgroundColor: progressColor.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(progressColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hoạt động cuối',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    student.displayLastActivity ?? 'Chưa có',
                    style: tt.bodySmall?.copyWith(
                      color: student.isCompleted
                          ? Colors.green
                          : cs.onSurfaceVariant,
                      fontWeight:
                          student.isCompleted ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
