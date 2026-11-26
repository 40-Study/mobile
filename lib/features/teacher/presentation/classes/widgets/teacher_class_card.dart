import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherClassCard extends StatelessWidget {
  const TeacherClassCard({
    super.key,
    required this.classData,
    required this.workplaceLabel,
    required this.onTap,
  });
  final TeacherClassData classData;
  final String workplaceLabel;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final row = classData;
    final theme = Theme.of(context), cs = theme.colorScheme;
    final code = '${row.json['class_code'] ?? row.json['code'] ?? ''}'.trim();
    final description =
        '${row.json['description'] ?? row.json['course_name'] ?? ''}'.trim();
    final startDate = DateTime.tryParse('${row.json['start_date']}');
    final status = row.json['status']?.toString() ?? '';
    final studentCount = row.json['student_count'] as int? ?? 0;

    final (statusBg, statusFg) = switch (status) {
      'active' => (AchievementColors.green.withValues(alpha: 0.15), AchievementColors.green),
      'draft' => (AchievementColors.yellow.withValues(alpha: 0.15), AchievementColors.yellow),
      _ => (cs.surfaceContainerHigh, cs.onSurfaceVariant),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF010120).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.borderLg,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row with avatar and status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TeacherClassAvatar(
                      className: row.name,
                      size: 52,
                    ),
                    AppSpacing.hGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (status.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    teacherStatus(status),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: statusFg,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              if (code.isNotEmpty) ...[
                                AppSpacing.hGap8,
                                Text(
                                  code,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          AppSpacing.vGap4,
                          Text(
                            row.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  AppSpacing.vGap12,
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
                AppSpacing.vGap16,
                // Info chips row
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (studentCount > 0)
                      _InfoChip(
                        icon: Icons.people_outline,
                        label: '$studentCount học viên',
                        color: cs.primary,
                      ),
                    if (startDate != null)
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}',
                        color: cs.onSurfaceVariant,
                      ),
                    _InfoChip(
                      icon: row.organizationId == null
                          ? Icons.person_outline
                          : Icons.business_outlined,
                      label: workplaceLabel,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
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
