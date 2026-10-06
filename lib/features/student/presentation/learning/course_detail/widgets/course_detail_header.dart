import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/learning/widgets/course_detail/course_detail_widgets.dart';
import 'package:study/theme/theme.dart';

class CourseDetailHeader extends StatelessWidget {
  const CourseDetailHeader({
    super.key,
    required this.isBookmarked,
    required this.onBack,
    required this.onBookmark,
    required this.onShare,
  });

  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          SoftIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
          ),
          const Spacer(),
          SoftIconButton(
            icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            iconColor: isBookmarked ? AchievementColors.orange : null,
            onTap: onBookmark,
          ),
          AppSpacing.hGap8,
          SoftIconButton(icon: Icons.ios_share_rounded, onTap: onShare),
        ],
      ),
    );
  }
}
