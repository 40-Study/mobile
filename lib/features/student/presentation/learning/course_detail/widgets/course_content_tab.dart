import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/presentation/learning/widgets/section/section_widgets.dart';
import 'package:study/theme/theme.dart';

class CourseContentTab extends StatelessWidget {
  const CourseContentTab({
    super.key,
    required this.state,
    required this.onLessonTap,
  });

  final CourseDetailSuccess state;
  final void Function(LessonModel lesson) onLessonTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final allLessons = state.sections
        .expand((s) => s.lessons ?? <LessonModel>[])
        .toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          children: [
            Text(
              '${state.sections.length} buổi • ${state.course?.totalLessons ?? allLessons.length} bài học',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                for (final section in state.sections) {
                  if (!state.expandedSections.contains(section.id)) {
                    context.read<CourseDetailBloc>().add(
                      CourseDetailSectionToggled(section.id),
                    );
                  }
                }
              },
              child: Text('Mở tất cả', style: tt.labelMedium?.copyWith(color: cs.primary)),
            ),
          ],
        ),
        AppSpacing.vGap12,

        // Sections (Buổi)
        ...() {
          int globalIndex = 0;
          return state.sections.asMap().entries.map((entry) {
            final sectionIndex = entry.key;
            final section = entry.value;
            final startIndex = globalIndex;
            globalIndex += section.lessons?.length ?? 0;
            return SectionCard(
              sectionIndex: sectionIndex,
              section: section,
              isExpanded: state.expandedSections.contains(section.id),
              allLessons: allLessons,
              globalStartIndex: startIndex,
              onToggle: () {
                context.read<CourseDetailBloc>().add(
                  CourseDetailSectionToggled(section.id),
                );
              },
              onLessonTap: onLessonTap,
            );
          });
        }(),

        AppSpacing.vGap32,
      ],
    );
  }
}
