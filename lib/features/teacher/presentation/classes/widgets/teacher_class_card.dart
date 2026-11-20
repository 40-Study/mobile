import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/theme/app_spacing.dart';

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
    final (statusBg, statusFg) = switch (status) {
      'active' => (cs.primaryContainer, cs.onPrimaryContainer),
      'draft' => (cs.tertiaryContainer, cs.onTertiaryContainer),
      _ => (cs.surfaceContainerHigh, cs.onSurfaceVariant),
    };
    return Material(
      color: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (status.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        teacherStatus(status),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusFg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (code.isNotEmpty)
                    Text(
                      code,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              AppSpacing.vGap16,
              Text(
                row.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  height: 1.25,
                ),
              ),
              if (description.isNotEmpty) ...[
                AppSpacing.vGap8,
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              AppSpacing.vGap16,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    row.organizationId == null
                        ? Icons.person_outline
                        : Icons.business_outlined,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                  AppSpacing.hGap8,
                  Expanded(
                    child: Text(
                      workplaceLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (row.json['student_count'] != null || startDate != null) ...[
                AppSpacing.vGap12,
                Wrap(
                  spacing: 18,
                  runSpacing: 10,
                  children: [
                    if (row.json['student_count'] != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 19,
                            color: cs.primary,
                          ),
                          AppSpacing.hGap8,
                          Text(
                            '${row.json['student_count']} học viên',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    if (startDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 17,
                            color: cs.primary,
                          ),
                          AppSpacing.hGap8,
                          Text(
                            '${startDate.day.toString().padLeft(2, '0')}/${startDate.month.toString().padLeft(2, '0')}/${startDate.year}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
              AppSpacing.vGap16,
              Divider(height: 1, color: cs.outlineVariant),
              AppSpacing.vGap12,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Xem lớp',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: cs.primary,
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
