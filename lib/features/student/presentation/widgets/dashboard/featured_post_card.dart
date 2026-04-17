import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/discussion_model.dart';

class _PostColors {
  static const programming = Color(0xFF6366F1);
  static const design = Color(0xFFEC4899);
  static const tips = Color(0xFFF59E0B);
  static const project = Color(0xFF10B981);
  static const upvote = Color(0xFF3B82F6);
  static const comment = Color(0xFF8B5CF6);
  static const featured = Color(0xFFFF6B35);
}

class FeaturedPostCard extends StatelessWidget {
  const FeaturedPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  final ForumPostModel post;
  final VoidCallback? onTap;

  Color get _categoryColor {
    switch (post.category) {
      case DiscussionCategory.programming:
        return _PostColors.programming;
      case DiscussionCategory.design:
        return _PostColors.design;
      case DiscussionCategory.learningTips:
        return _PostColors.tips;
      case DiscussionCategory.project:
        return _PostColors.project;
      case DiscussionCategory.other:
        return _PostColors.programming;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderLg,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _categoryColor,
                          _categoryColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        post.authorName?.isNotEmpty == true
                            ? post.authorName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName ?? 'Anonymous',
                          style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          post.category.displayName,
                          style: tt.bodySmall?.copyWith(
                            color: _categoryColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _PostColors.featured.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: _PostColors.featured,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Noi bat',
                          style: TextStyle(
                            color: _PostColors.featured,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                post.title,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 14,
                    color: _PostColors.upvote,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.upvoteCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _PostColors.upvote,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: _PostColors.comment,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.replyCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _PostColors.comment,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    post.timeAgo,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
