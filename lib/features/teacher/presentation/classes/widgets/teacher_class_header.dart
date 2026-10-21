import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/classes/widgets/teacher_class_elements.dart';
import 'package:study/theme/theme.dart';

class TeacherClassHeader extends StatelessWidget {
  const TeacherClassHeader({
    super.key,
    required this.detail,
    required this.workplaceLabel,
    required this.onEdit,
    required this.onTeachers,
  });
  final TeacherClassData detail;
  final String workplaceLabel;
  final VoidCallback onEdit;
  final VoidCallback onTeachers;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.md,
    ),
    child: TeacherClassPanel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  detail.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (detail.canManage)
                IconButton(
                  tooltip: 'Chỉnh sửa',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          AppSpacing.vGap8,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TeacherClassStatus(
                teacherStatus(detail.json['status']),
                muted: detail.archived,
              ),
              Text(
                workplaceLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (detail.archived)
                Text('Chỉ xem', style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
          if (detail.archived)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Lớp đã lưu trữ. Bạn có thể tra cứu thông tin, không thể thay đổi.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          AppSpacing.vGap8,
          TextButton.icon(
            onPressed: onTeachers,
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Giáo viên trong lớp'),
          ),
        ],
      ),
    ),
  );
}
