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
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: LessonContentTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? cs.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cs.shadow.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
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
      LessonContentTab.documents => 'Tai lieu',
      LessonContentTab.quiz => 'Bai tap',
      LessonContentTab.notes => 'Ghi chu',
    };
  }
}
