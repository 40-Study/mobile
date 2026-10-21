import 'package:flutter/material.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/theme/theme.dart';

class CourseManagementActions extends StatelessWidget {
  const CourseManagementActions({
    super.key,
    required this.writable,
    required this.onEdit,
    required this.onEnrollments,
  });
  final bool writable;
  final VoidCallback onEdit;
  final VoidCallback onEnrollments;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quản lý khóa học',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        AppSpacing.vGap12,
        TeacherSurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                contentPadding: AppSpacing.paddingLg,
                leading: _CourseActionIcon(icon: Icons.edit_note_outlined),
                title: Text(
                  'Thông tin và giá',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    writable
                        ? 'Tên khóa, mục tiêu, ảnh bìa và học phí'
                        : 'Chỉ đọc theo trạng thái hiện tại của khóa',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                trailing: Icon(
                  writable ? Icons.chevron_right_rounded : Icons.lock_outline,
                  color: cs.onSurfaceVariant,
                ),
                onTap: writable ? onEdit : null,
              ),
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
              ),
              TeacherActionTile(
                icon: Icons.people_outline,
                title: 'Học viên đã đăng ký khóa',
                subtitle: 'Theo dõi học viên và tiến độ học tập',
                onTap: onEnrollments,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CourseActionIcon extends StatelessWidget {
  const _CourseActionIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: AppRadius.borderMd,
    ),
    child: Icon(
      icon,
      color: Theme.of(context).colorScheme.onPrimaryContainer,
      size: 22,
    ),
  );
}
