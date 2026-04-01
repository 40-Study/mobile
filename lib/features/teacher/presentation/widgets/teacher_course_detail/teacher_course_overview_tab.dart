import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/teacher/data/models/teacher_course_detail_model.dart';
import 'package:study/theme/app_colors.dart';

class TeacherCourseOverviewTab extends StatelessWidget {
  const TeacherCourseOverviewTab({super.key, required this.detail});

  final TeacherCourseDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.xxl,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      children: [
        // Description section
        _SectionHeader(
          title: 'Giới thiệu khóa học',
          onEdit: () {
            // TODO: Edit description
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          detail.description ?? 'Chưa có mô tả',
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.6,
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // Learning outcomes
        _SectionHeader(
          title: 'Học viên sẽ học được gì',
          onEdit: () {
            // TODO: Edit learning outcomes
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (detail.learningOutcomes.isEmpty)
          _EmptyState(
            icon: Icons.lightbulb_outline,
            message: 'Chưa có nội dung học tập',
            actionLabel: 'Thêm ngay',
            onAction: () {},
          )
        else
          ...detail.learningOutcomes.map(
            (outcome) => _OutcomeItem(text: outcome),
          ),

        const SizedBox(height: AppSpacing.xxxl),

        // Recent reviews
        _SectionHeader(
          title: 'Đánh giá gần đây',
          trailing: Text(
            'Xem tất cả (${detail.reviewCount})',
            style: tt.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (detail.recentReviews.isEmpty)
          _EmptyState(
            icon: Icons.star_outline,
            message: 'Chưa có đánh giá nào',
          )
        else
          ...detail.recentReviews.map(
            (review) => _ReviewItem(review: review),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.onEdit,
    this.trailing,
  });

  final String title;
  final VoidCallback? onEdit;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onEdit,
            child: trailing,
          )
        else if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18, color: cs.primary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}

class _OutcomeItem extends StatelessWidget {
  const _OutcomeItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.15),
          ),
          boxShadow: cs.shadowCard,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: AppIconSize.sm,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.review});

  final CourseReviewModel review;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.15),
        ),
        boxShadow: cs.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  review.studentName.isNotEmpty
                      ? review.studentName[0].toUpperCase()
                      : 'U',
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.studentName,
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 14,
                            color: index < review.rating
                                ? cs.tertiary
                                : cs.outlineVariant,
                          );
                        }),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          review.createdAt ?? '',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              review.comment!,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
