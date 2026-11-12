import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/recommended_course_item.dart';
import 'package:study/features/student/presentation/search/widgets/recommended_course_tile.dart';
import 'package:study/theme/theme.dart';

class SearchRecommendationsSection extends StatelessWidget {
  const SearchRecommendationsSection({
    super.key,
    required this.items,
    this.isLoading = false,
  });

  final List<RecommendedCourseItem> items;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 17,
                color: isDark ? cs.primary : const Color(0xFF2563EB),
              ),
              const SizedBox(width: 6),
              Text(
                'Gợi ý riêng cho bạn',
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.slate900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'Cá nhân hóa',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          if (isLoading)
            ...List.generate(3, (index) => _buildSkeletonTile(cs, isDark))
          else if (items.isNotEmpty)
            ...items.map((item) => RecommendedCourseTile(item: item))
          else
            _buildEmptyPlaceholder(cs, tt),
        ],
      ),
    );
  }

  Widget _buildSkeletonTile(ColorScheme cs, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceContainerHigh : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark ? cs.surfaceContainerHigh : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDark ? cs.surfaceContainerHigh : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(ColorScheme cs, TextTheme tt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          'Đang cập nhật các gợi ý khóa học phù hợp...',
          style: tt.bodySmall?.copyWith(color: cs.slate500),
        ),
      ),
    );
  }
}
