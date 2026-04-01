import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/data/models/teacher_course_detail_model.dart';
import 'package:study/theme/app_colors.dart';

class TeacherCourseHeroHeader extends StatelessWidget {
  const TeacherCourseHeroHeader({
    super.key,
    required this.detail,
  });

  final TeacherCourseDetailModel detail;

  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B đ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(0)}M đ';
    }
    return NumberFormat('#,###', 'vi_VN').format(amount) + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero image with stats overlay
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          height: 180,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderLg,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1a1a2e),
                cs.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: detail.thumbnail != null
                ? DecorationImage(
                    image: NetworkImage(detail.thumbnail!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.3),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          child: Stack(
            children: [
              // Badge
              if (detail.badge != null)
                Positioned(
                  left: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: AppRadius.borderXs,
                    ),
                    child: Text(
                      detail.badge!,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              // Progress ring
              Positioned(
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                child: _CourseProgressRing(
                  progress: detail.progressPercent,
                  size: 56,
                ),
              ),
              // Status badge
              Positioned(
                left: AppSpacing.lg,
                top: AppSpacing.lg,
                child: _StatusBadge(status: detail.status),
              ),
              // Content info
              Positioned(
                left: AppSpacing.lg,
                bottom: AppSpacing.massive,
                right: AppSpacing.lg,
                child: Text(
                  '${detail.publishedLessons}/${detail.totalLessons} bài học đã xuất bản',
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Quick stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Row(
            children: [
              _QuickStat(
                icon: Icons.people_outline,
                value: '${detail.studentCount}',
                label: 'Học viên',
              ),
              const SizedBox(width: AppSpacing.lg),
              _QuickStat(
                icon: Icons.class_outlined,
                value: '${detail.classCount}',
                label: 'Lớp học',
              ),
              const SizedBox(width: AppSpacing.lg),
              _QuickStat(
                icon: Icons.star_outline,
                value: detail.rating.toStringAsFixed(1),
                label: '${detail.reviewCount} đánh giá',
                iconColor: cs.tertiary,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Text(
            detail.title,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Category & Price
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Row(
            children: [
              if (detail.categoryName != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: AppRadius.borderXs,
                  ),
                  child: Text(
                    detail.categoryName!,
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Text(
                _formatCurrency(detail.price),
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
              if (detail.originalPrice != null &&
                  detail.originalPrice! > detail.price) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatCurrency(detail.originalPrice!),
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: Navigate to edit course
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Chỉnh sửa'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Preview course
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Xem trước'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _CourseProgressRing extends StatelessWidget {
  const _CourseProgressRing({required this.progress, this.size = 56});

  final int progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress / 100,
              strokeWidth: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: Colors.white,
              strokeCap: StrokeCap.round,
            ),
          ),
          Container(
            width: size - 12,
            height: size - 12,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$progress%',
              style: tt.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor) = switch (status.toLowerCase()) {
      'published' => (
          'Xuất bản',
          Colors.green.withValues(alpha: 0.9),
          Colors.white
        ),
      'draft' => (
          'Bản nháp',
          Colors.orange.withValues(alpha: 0.9),
          Colors.white
        ),
      'archived' => (
          'Lưu trữ',
          Colors.grey.withValues(alpha: 0.9),
          Colors.white
        ),
      _ => ('Bản nháp', Colors.orange.withValues(alpha: 0.9), Colors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor ?? cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          value,
          style: tt.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
