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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          _FilterChip(
            label: 'Dang hoc',
            isSelected: selectedFilter == EnrollmentFilter.inProgress,
            onTap: () => onFilterChanged(EnrollmentFilter.inProgress),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Hoan thanh',
            isSelected: selectedFilter == EnrollmentFilter.completed,
            onTap: () => onFilterChanged(EnrollmentFilter.completed),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Cho khai giang',
            isSelected: selectedFilter == EnrollmentFilter.upcoming,
            onTap: () => onFilterChanged(EnrollmentFilter.upcoming),
          ),
        ],
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

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: tt.labelMedium?.copyWith(
            color: isSelected ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
