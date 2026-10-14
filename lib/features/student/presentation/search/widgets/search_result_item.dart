import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/search/search_event.dart';
import 'package:study/features/student/bloc/search/search_state.dart';
import 'package:study/features/student/presentation/learning/course_detail/course_detail_screen.dart';
import 'package:study/theme/theme.dart';

/// Single search result card
class SearchResultItem extends StatelessWidget {
  const SearchResultItem({super.key, required this.result});

  final SearchResult result;

  void _onTap(BuildContext context) {
    if (result.type == SearchFilter.course) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => diContainer<CourseDetailBloc>()
              ..add(CourseDetailStarted(result.id, isEnrollment: false)),
            child: const CourseDetailScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final typeColor = _getTypeColor(result.type, cs);
    final hasImage =
        result.imageUrl != null && result.imageUrl!.trim().isNotEmpty;

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: result.imageUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 120,
                          memCacheHeight: 120,
                          placeholder: (_, _) => _buildFallbackIcon(typeColor),
                          errorWidget: (_, _, _) =>
                              _buildFallbackIcon(typeColor),
                        )
                      : _buildFallbackIcon(typeColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style:
                          tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
                            borderRadius: AppRadius.borderXs,
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

  Widget _buildFallbackIcon(Color typeColor) {
    return Container(
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
      SearchFilter.course => 'Khóa học',
      SearchFilter.lesson => 'Bài học',
      SearchFilter.quiz => 'Trắc nghiệm',
    };
  }
}
