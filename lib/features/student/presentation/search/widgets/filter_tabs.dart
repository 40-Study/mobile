import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/search/search_bloc.dart';
import 'package:study/features/student/bloc/search/search_event.dart';
import 'package:study/theme/theme.dart';

/// Filter chips: Tat ca, Khoa hoc, Bai hoc, Quiz
class FilterTabs extends StatelessWidget {
  const FilterTabs({super.key, required this.currentFilter});

  final SearchFilter currentFilter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: SearchFilter.values.map((filter) {
            final isSelected = currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => context
                    .read<SearchBloc>()
                    .add(SearchFilterChanged(filter)),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _getFilterLabel(filter),
                    style: tt.labelMedium?.copyWith(
                      color: isSelected ? cs.onPrimary : cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFilterLabel(SearchFilter filter) {
    return switch (filter) {
      SearchFilter.all => 'Tat ca',
      SearchFilter.course => 'Khoa hoc',
      SearchFilter.lesson => 'Bai hoc',
      SearchFilter.quiz => 'Quiz',
    };
  }
}
