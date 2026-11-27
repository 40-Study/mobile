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
    this.preview = false,
  });
  final TeacherClassData detail;
  final String workplaceLabel;
  final VoidCallback onEdit;
  final bool preview;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.md,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                detail.name,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (detail.canManage)
              IconButton(
                tooltip: 'Chỉnh sửa lớp',
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
            if (!detail.canManage && (!detail.archived || preview))
              Text(
                preview ? 'Dữ liệu mẫu · Chỉ xem' : 'Chỉ xem',
                style: Theme.of(context).textTheme.labelMedium,
              ),
          ],
        ),
        if (detail.archived) ...[
          AppSpacing.vGap4,
          const Text('Lớp đã lưu trữ và đang ở chế độ chỉ xem.'),
        ],
      ],
    ),
  );
}
