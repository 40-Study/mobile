import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/theme/theme.dart';

class LessonContentTabs extends StatelessWidget {
  const LessonContentTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final LessonContentTab selectedTab;
  final ValueChanged<LessonContentTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: LessonContentTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: InkWell(
              onTap: () => onTabChanged(tab),
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: isSelected ? Border.all(color: cs.outline) : null,
                ),
                child: Text(
                  _tabLabel(tab),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _tabLabel(LessonContentTab tab) {
    return switch (tab) {
      LessonContentTab.video => 'Video',
      LessonContentTab.documents => 'Tài liệu',
      LessonContentTab.quiz => 'Bài tập',
      LessonContentTab.notes => 'Ghi chú',
    };
  }
}
