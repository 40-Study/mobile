import 'package:flutter/material.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/theme/theme.dart';

class TeacherQuickActions extends StatelessWidget {
  const TeacherQuickActions({
    super.key,
    required this.onClasses,
    required this.onCourses,
  });
  final VoidCallback onClasses;
  final VoidCallback onCourses;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final classes = _Shortcut(
        icon: Icons.groups_rounded,
        title: 'Lớp của tôi',
        subtitle: 'Học viên & bài tập',
        onTap: onClasses,
      );
      final courses = _Shortcut(
        icon: Icons.auto_stories_rounded,
        title: 'Soạn khóa học',
        subtitle: 'Nội dung của bạn',
        onTap: onCourses,
      );
      if (MediaQuery.textScalerOf(context).scale(14) > 20 ||
          constraints.maxWidth < 300) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [classes, AppSpacing.vGap12, courses],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: classes),
          AppSpacing.hGap12,
          Expanded(child: courses),
        ],
      );
    },
  );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme, tt = Theme.of(context).textTheme;
    return TeacherSurface(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(icon, color: cs.onPrimaryContainer, size: 22),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
              AppSpacing.vGap12,
              Text(
                title,
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              AppSpacing.vGap4,
              Text(
                subtitle,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
