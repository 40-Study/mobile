import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/search/search_event.dart';
import 'package:study/features/student/bloc/search/search_state.dart';
import 'package:study/theme/theme.dart';

/// Single search result card
class SearchResultItem extends StatelessWidget {
  const SearchResultItem({super.key, required this.result});

  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final typeColor = _getTypeColor(result.type, cs);

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to result
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _getTypeIcon(result.type),
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getTypeLabel(result.type),
                            style: tt.labelSmall?.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.subtitle,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(SearchFilter type) {
    return switch (type) {
      SearchFilter.all => Icons.search,
      SearchFilter.course => Icons.school_rounded,
      SearchFilter.lesson => Icons.play_circle_rounded,
      SearchFilter.quiz => Icons.quiz_rounded,
    };
  }

  Color _getTypeColor(SearchFilter type, ColorScheme cs) {
    return switch (type) {
      SearchFilter.all => cs.primary,
      SearchFilter.course => cs.primary,
      SearchFilter.lesson => cs.secondary,
      SearchFilter.quiz => cs.tertiary,
    };
  }

  String _getTypeLabel(SearchFilter type) {
    return switch (type) {
      SearchFilter.all => '',
      SearchFilter.course => 'Khoa hoc',
      SearchFilter.lesson => 'Bai hoc',
      SearchFilter.quiz => 'Quiz',
    };
  }
}
