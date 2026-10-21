import 'package:flutter/material.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/theme/theme.dart';

class CourseSectionCard extends StatelessWidget {
  const CourseSectionCard({
    super.key,
    required this.section,
    required this.index,
    required this.lessonCount,
    required this.lessonRows,
    required this.writable,
    required this.busy,
    required this.onAddLesson,
    this.controls,
  });
  final Map<String, dynamic> section;
  final int index;
  final int lessonCount;
  final List<Widget> lessonRows;
  final bool writable;
  final bool busy;
  final VoidCallback onAddLesson;
  final Widget? controls;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme, tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TeacherSurface(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          key: ValueKey(section['id']),
          initiallyExpanded: true,
          tilePadding: AppSpacing.paddingLg,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: AppRadius.borderMd,
            ),
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          title: Text(
            '${index + 1}. ${section['title']}',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              '${lessonCount} bài học',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          trailing: controls,
          children: [
            Divider(height: 1, color: cs.outlineVariant),
            ...lessonRows,
            if (writable)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: busy ? null : onAddLesson,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm bài vào chương'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
