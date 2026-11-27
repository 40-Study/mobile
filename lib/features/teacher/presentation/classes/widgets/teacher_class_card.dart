import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherClassCard extends StatelessWidget {
  const TeacherClassCard({
    super.key,
    required this.classData,
    this.workplaceLabel,
    required this.onTap,
  });
  final TeacherClassData classData;
  final String? workplaceLabel;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final row = classData;
    final theme = Theme.of(context), cs = theme.colorScheme;
    final code = '${row.json['class_code'] ?? row.json['code'] ?? ''}'.trim();
    final description =
        '${row.json['description'] ?? row.json['course_name'] ?? ''}'.trim();
    final status = row.json['status']?.toString() ?? '';
    final studentCount = row.json['student_count'];
    final title =
        code.isNotEmpty && !row.name.toLowerCase().contains(code.toLowerCase())
        ? '${row.name} · $code'
        : row.name;
    return Card(
      margin: EdgeInsets.zero,
      color: cs.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderLg,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TeacherClassIcon(className: row.name, size: 36),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (status.isNotEmpty)
                          Text(
                            teacherStatus(status),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: status == 'active'
                                  ? AchievementColors.green
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                        if (studentCount is num)
                          _InfoChip(
                            icon: Icons.people_outline,
                            label: '$studentCount học viên',
                            color: cs.onSurfaceVariant,
                          ),
                        if (workplaceLabel != null) Text(workplaceLabel!),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      AppSpacing.vGap4,
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppSpacing.hGap4,
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        AppSpacing.hGap4,
        Flexible(
          child: Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
