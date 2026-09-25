import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/presentation/learning/widgets/course_detail/course_detail_widgets.dart';
import 'package:study/theme/theme.dart';

class CourseOverviewTab extends StatelessWidget {
  const CourseOverviewTab({
    super.key,
    required this.state,
    required this.onViewAllContent,
    required this.onLessonTap,
  });

  final CourseDetailSuccess state;
  final VoidCallback onViewAllContent;
  final void Function(LessonModel lesson) onLessonTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = state.course;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Text(
          'Giới thiệu khóa học',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        AppSpacing.vGap8,
        Text(
          course?.description ?? course?.shortDescription ??
          'Khóa học giúp bạn nắm vững kiến thức và kỹ năng cần thiết.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
        AppSpacing.vGap24,

        // Stats row
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatCard(
                icon: Icons.play_circle_outline,
                value: '${course?.totalLessons ?? 0}',
                label: 'Bài học',
              ),
              AppSpacing.hGap8,
              StatCard(
                icon: Icons.access_time_rounded,
                value: _formatDuration(course?.totalDurationMins ?? 0),
                label: 'Thời lượng',
              ),
              AppSpacing.hGap8,
              StatCard(
                icon: Icons.signal_cellular_alt_rounded,
                value: course?.level ?? 'Cơ bản',
                label: 'Cấp độ',
              ),
              AppSpacing.hGap8,
              const StatCard(
                icon: Icons.workspace_premium_outlined,
                value: 'Có',
                label: 'Chứng chỉ',
              ),
            ],
          ),
        ),
        AppSpacing.vGap24,

        // Objectives
        if (course?.objectives != null && course!.objectives!.isNotEmpty) ...[
          Text(
            'Bạn sẽ học được',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          AppSpacing.vGap12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: course.objectives!.map((obj) => ObjectiveItem(text: obj)).toList(),
          ),
          AppSpacing.vGap24,
        ],

        // Course content preview
        Row(
          children: [
            Expanded(
              child: Text(
                'Nội dung khóa học',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: onViewAllContent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Xem tất cả', style: tt.labelMedium?.copyWith(color: cs.primary)),
                  Icon(Icons.chevron_right_rounded, size: 18, color: cs.primary),
                ],
              ),
            ),
          ],
        ),
        Text(
          '${course?.totalLessons ?? 0} bài học',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        AppSpacing.vGap12,

        // Preview lessons
        ...() {
          final allLessons = state.sections
              .expand((s) => s.lessons ?? <LessonModel>[])
              .toList();
          return allLessons.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final lesson = entry.value;
            final isLocked = index > 0 &&
                allLessons[index - 1].progress?.status != 'completed';
            return LessonPreviewItem(
              index: index,
              lesson: lesson,
              isLocked: isLocked,
              onTap: () => onLessonTap(lesson),
            );
          });
        }(),

        AppSpacing.vGap32,
      ],
    );
  }

  String _formatDuration(int mins) {
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${mins}m';
  }
}
