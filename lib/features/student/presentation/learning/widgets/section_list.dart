import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/student/presentation/learning/widgets/section_item.dart';

class SectionList extends StatelessWidget {
  const SectionList({
    super.key,
    required this.sections,
    required this.expandedSections,
    this.onSectionToggle,
    this.onLessonTap,
  });

  final List<SectionModel> sections;
  final Set<String> expandedSections;
  final void Function(String sectionId)? onSectionToggle;
  final void Function(LessonModel lesson)? onLessonTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sections.map((section) {
        final completedCount = _countCompleted(section);
        return SectionItem(
          section: section,
          isExpanded: expandedSections.contains(section.id),
          completedCount: completedCount,
          onToggle: () => onSectionToggle?.call(section.id),
          onLessonTap: onLessonTap,
        );
      }).toList(),
    );
  }

  int _countCompleted(SectionModel section) {
    final lessons = section.lessons ?? [];
    return lessons.where((l) => l.progress?.status == 'completed').length;
  }
}
