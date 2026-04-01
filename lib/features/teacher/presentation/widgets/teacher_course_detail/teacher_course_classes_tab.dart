import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/data/models/class_model.dart';
import 'package:study/features/teacher/data/models/teacher_course_detail_model.dart';
import 'package:study/theme/app_colors.dart';

class TeacherCourseClassesTab extends StatelessWidget {
  const TeacherCourseClassesTab({super.key, required this.detail});

  final TeacherCourseDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final activeClasses =
        detail.classes.where((c) => c.classStatus == ClassStatus.active).toList();
    final completedClasses =
        detail.classes.where((c) => c.classStatus == ClassStatus.completed).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.lg,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      children: [
        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.play_circle_outline,
                value: '${activeClasses.length}',
                label: 'Đang diễn ra',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_outline,
                value: '${completedClasses.length}',
                label: 'Đã hoàn thành',
                color: cs.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                icon: Icons.people_outline,
                value: '${detail.studentCount}',
                label: 'Tổng học viên',
                color: cs.tertiary,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Add class button
        Row(
          children: [
            Expanded(
              child: Text(
                'Danh sách lớp học',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                // TODO: Create new class
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tạo lớp mới'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Active classes
        if (activeClasses.isNotEmpty) ...[
          _SectionLabel(label: 'Đang diễn ra (${activeClasses.length})'),
          const SizedBox(height: AppSpacing.sm),
          ...activeClasses.map((c) => _ClassCard(classModel: c)),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Completed classes
        if (completedClasses.isNotEmpty) ...[
          _SectionLabel(label: 'Đã hoàn thành (${completedClasses.length})'),
          const SizedBox(height: AppSpacing.sm),
          ...completedClasses.map((c) => _ClassCard(classModel: c)),
        ],

        // Empty state
        if (detail.classes.isEmpty)
          _EmptyClasses(),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Text(
      label,
      style: tt.labelMedium?.copyWith(
        color: cs.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classModel});

  final ClassModel classModel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: cs.shadowCard,
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to class detail
        },
        borderRadius: AppRadius.borderLg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      classModel.isOnline
                          ? Icons.videocam_outlined
                          : Icons.school_outlined,
                      color: cs.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classModel.displayName,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.people_outline,
                                size: 14, color: cs.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              '${classModel.studentCount}/${classModel.maxStudents}',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _ClassStatusBadge(status: classModel.classStatus),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),

              // Schedule info
              if (classModel.nextScheduleDate != null ||
                  classModel.nextScheduleTime != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        classModel.nextScheduleTime ?? '',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (classModel.nextScheduleRoom != null) ...[
                        const SizedBox(width: AppSpacing.md),
                        Icon(Icons.location_on_outlined,
                            size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            classModel.nextScheduleRoom!,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassStatusBadge extends StatelessWidget {
  const _ClassStatusBadge({required this.status});

  final ClassStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor) = switch (status) {
      ClassStatus.active => (
          'Đang học',
          Colors.green.withValues(alpha: 0.1),
          Colors.green
        ),
      ClassStatus.completed => (
          'Hoàn thành',
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          Theme.of(context).colorScheme.primary
        ),
      ClassStatus.inactive => (
          'Tạm dừng',
          Colors.orange.withValues(alpha: 0.1),
          Colors.orange
        ),
      ClassStatus.cancelled => (
          'Đã hủy',
          Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
          Theme.of(context).colorScheme.error
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _EmptyClasses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Chưa có lớp học nào',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tạo lớp học để bắt đầu giảng dạy khóa học này',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () {
              // TODO: Create first class
            },
            icon: const Icon(Icons.add),
            label: const Text('Tạo lớp học đầu tiên'),
          ),
        ],
      ),
    );
  }
}
