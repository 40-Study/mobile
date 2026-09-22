import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/theme/theme.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
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
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tất cả',
            isSelected: selectedFilter == EnrollmentFilter.all,
            onTap: () => onFilterChanged(EnrollmentFilter.all),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Đang học',
            isSelected: selectedFilter == EnrollmentFilter.inProgress,
            onTap: () => onFilterChanged(EnrollmentFilter.inProgress),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Chưa bắt đầu',
            isSelected: selectedFilter == EnrollmentFilter.upcoming,
            onTap: () => onFilterChanged(EnrollmentFilter.upcoming),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Đã hoàn thành',
            isSelected: selectedFilter == EnrollmentFilter.completed,
            onTap: () => onFilterChanged(EnrollmentFilter.completed),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? cs.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 10,
            ),
            child: Text(
              label,
              style: tt.labelMedium?.copyWith(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
