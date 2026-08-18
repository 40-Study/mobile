import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/theme/theme.dart';

class CourseFilterChips extends StatelessWidget {
  const CourseFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final EnrollmentFilter selectedFilter;
  final ValueChanged<EnrollmentFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Expanded(
              child: _FilterChip(
                label: 'Tất cả',
                isSelected: selectedFilter == EnrollmentFilter.all,
                onTap: () => onFilterChanged(EnrollmentFilter.all),
              ),
            ),
            Expanded(
              child: _FilterChip(
                label: 'Đang học',
                isSelected: selectedFilter == EnrollmentFilter.inProgress,
                onTap: () => onFilterChanged(EnrollmentFilter.inProgress),
              ),
            ),
            Expanded(
              child: _FilterChip(
                label: 'Hoàn thành',
                isSelected: selectedFilter == EnrollmentFilter.completed,
                onTap: () => onFilterChanged(EnrollmentFilter.completed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: isSelected ? Border.all(color: cs.outline) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.labelMedium?.copyWith(
            color: isSelected ? cs.primary : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
