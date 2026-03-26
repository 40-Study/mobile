import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class CourseDiscussionTab extends StatelessWidget {
  const CourseDiscussionTab({super.key, required this.detail});
  final CourseDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              AppSpacing.xxl,
              AppLayout.screenMargin,
              AppSpacing.lg,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Thao luan cong dong',
                      style:
                          tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Icon(Icons.people_rounded,
                      size: AppIconSize.sm, color: cs.onSurfaceVariant),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '${detail.totalStudents} hoc vien',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Dat cau hoi hoac chia se cam nghi cua ban ve bai hoc. '
                'Giang vien se phan hoi trong vong 24h.',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              ...detail.discussions.map(
                (d) => DiscussionCard(discussion: d),
              ),
            ],
          ),
        ),
        CommentInput(),
      ],
    );
  }
}

class DiscussionCard extends StatelessWidget {
  const DiscussionCard({
    super.key,
    required this.discussion,
    this.isReply = false,
  });

  final DiscussionModel discussion;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isInstructor = discussion.role == DiscussionRole.instructor;

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSpacing.lg,
        left: isReply ? AppSpacing.xxl : 0,
      ),
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: isReply
              ? cs.surfaceTintedPrimary
              : cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isInstructor
                ? cs.primary.withValues(alpha: 0.15)
                : cs.outlineVariant.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isInstructor
                      ? cs.primaryContainer
                      : cs.surfaceContainerHigh,
                  child: Text(
                    discussion.authorName.isNotEmpty
                        ? discussion.authorName[0].toUpperCase()
                        : '?',
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isInstructor ? cs.primary : cs.onSurface,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              discussion.authorName,
                              style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs + 2,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isInstructor
                                  ? cs.primary
                                  : cs.surfaceContainerHighest,
                              borderRadius: AppRadius.borderXs,
                            ),
                            child: Text(
                              isInstructor ? 'GIANG VIEN' : 'HOC VIEN',
                              style: tt.labelSmall?.copyWith(
                                color: isInstructor
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (discussion.timeAgo != null)
                        Text(
                          discussion.timeAgo!,
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isReply)
                  Icon(Icons.more_horiz_rounded,
                      size: AppIconSize.md, color: cs.onSurfaceVariant),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              discussion.content,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.thumb_up_outlined,
                    size: AppIconSize.xs, color: cs.onSurfaceVariant),
                SizedBox(width: AppSpacing.xxs),
                Text(
                  '${discussion.likes}',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isReply && discussion.replyCount > 0) ...[
                  SizedBox(width: AppSpacing.lg),
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: AppIconSize.xs, color: cs.onSurfaceVariant),
                  SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${discussion.replyCount} phan hoi',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),

            if (discussion.replies.isNotEmpty) ...[
              SizedBox(height: AppSpacing.lg),
              ...discussion.replies.map(
                (reply) => DiscussionCard(
                  discussion: reply,
                  isReply: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CommentInput extends StatelessWidget {
  const CommentInput({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.md,
        AppLayout.screenMargin,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: AppRadius.borderXxl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Viet binh luan hoac cau hoi...',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Icon(Icons.attach_file_rounded,
                      size: AppIconSize.md, color: cs.onSurfaceVariant),
                  SizedBox(width: AppSpacing.md),
                  Icon(Icons.mic_none_rounded,
                      size: AppIconSize.md, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: cs.gradientPrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.send_rounded,
              size: AppIconSize.md,
              color: cs.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
