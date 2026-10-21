import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_elements.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_schedules_panel.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_teachers_panel.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherClassOverview extends StatelessWidget {
  const TeacherClassOverview({
    super.key,
    required this.detail,
    required this.loadTeachers,
    required this.loadSchedules,
    required this.onAddSchedule,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
    required this.onGenerate,
  });
  final TeacherClassData detail;
  final Future<List<Map<String, dynamic>>> Function() loadTeachers;
  final Future<List<Map<String, dynamic>>> Function() loadSchedules;
  final VoidCallback onAddSchedule;
  final ValueChanged<Map<String, dynamic>> onEditSchedule;
  final ValueChanged<String> onDeleteSchedule;
  final VoidCallback onGenerate;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.lg),
    children: [
      TeacherClassPanel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Thông tin chung',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if ('${detail.json['description'] ?? ''}'.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  '${detail.json['description']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            AppSpacing.vGap16,
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.md,
              children: [
                _summary(
                  context,
                  Icons.people_outline,
                  '${detail.json['student_count'] ?? '—'}',
                  'Học viên',
                ),
                _summary(
                  context,
                  Icons.school_outlined,
                  '${detail.json['teacher_count'] ?? '—'}',
                  'Giáo viên',
                ),
              ],
            ),
            if (detail.json['start_date'] != null ||
                detail.json['end_date'] != null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(height: 1),
              ),
            if (detail.json['start_date'] != null)
              _classFact(
                context,
                Icons.event_available_outlined,
                'Bắt đầu',
                teacherClassDate(detail.json['start_date']),
              ),
            if (detail.json['end_date'] != null)
              _classFact(
                context,
                Icons.event_outlined,
                'Kết thúc',
                teacherClassDate(detail.json['end_date']),
              ),
          ],
        ),
      ),
      const TeacherSectionTitle(title: 'Giáo viên được phân công'),
      TeacherClassTeachersPanel(load: loadTeachers),
      TeacherClassSchedulesPanel(
        detail: detail,
        load: loadSchedules,
        onAdd: onAddSchedule,
        onEdit: onEditSchedule,
        onDelete: onDeleteSchedule,
        onGenerate: onGenerate,
      ),
    ],
  );
  Widget _summary(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      AppSpacing.hGap12,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ],
  );
  Widget _classFact(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: AppIconSize.md,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        AppSpacing.hGap8,
        Expanded(
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
