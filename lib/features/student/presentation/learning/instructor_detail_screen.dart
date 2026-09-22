import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

import 'widgets/instructor_avatar_placeholder.dart';
import 'widgets/instructor_course_card.dart';
import 'widgets/instructor_info_tag.dart';
import 'widgets/instructor_rating_summary_card.dart';
import 'widgets/instructor_review_item.dart';
import 'widgets/instructor_skill_chip.dart';
import 'widgets/instructor_soft_icon_button.dart';
import 'widgets/instructor_stat_item.dart';
import 'widgets/instructor_vertical_divider.dart';

class InstructorDetailScreen extends StatelessWidget {
  const InstructorDetailScreen({
    super.key,
    required this.instructorId,
    required this.instructorName,
    this.instructorAvatar,
    this.instructorTitle,
  });

  final String instructorId;
  final String instructorName;
  final String? instructorAvatar;
  final String? instructorTitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Hero section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                    ),
                    child: _buildHeroSection(context),
                  ),

                  // Content with layered background
                  Container(
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        cs.primary.withValues(
                          alpha: Theme.of(context).brightness == Brightness.light
                              ? 0.045
                              : 0.065,
                        ),
                        cs.surfaceContainer,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xl),
                      ),
                      border: Border(
                        top: BorderSide(color: cs.primary.withValues(alpha: 0.1)),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.045),
                          blurRadius: 32,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.xl,
                      AppSpacing.screenPadding,
                      AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCard(context),
                        AppSpacing.vGap24,
                        _buildAboutSection(context),
                        AppSpacing.vGap24,
                        _buildExpertiseSection(context),
                        AppSpacing.vGap24,
                        _buildCoursesSection(context),
                        AppSpacing.vGap24,
                        _buildReviewsSection(context),
                        AppSpacing.vGap16,
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom bar
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          InstructorSoftIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          InstructorSoftIconButton(icon: Icons.bookmark_outline_rounded, onTap: () {}),
          AppSpacing.hGap8,
          InstructorSoftIconButton(icon: Icons.more_vert_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with verified badge
        Stack(
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.2),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: instructorAvatar != null
                    ? CachedNetworkImage(
                        imageUrl: instructorAvatar!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            InstructorAvatarPlaceholder(name: instructorName),
                        errorWidget: (_, _, _) =>
                            InstructorAvatarPlaceholder(name: instructorName),
                      )
                    : InstructorAvatarPlaceholder(name: instructorName),
              ),
            ),
            // Verified badge
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(Icons.check_rounded, size: 18, color: cs.onPrimary),
              ),
            ),
          ],
        ),
        AppSpacing.hGap16,

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.vGap8,
              // Name
              Text(
                instructorName,
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Title
              Text(
                instructorTitle ?? 'UI/UX Design Instructor',
                style: tt.bodyMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.vGap8,

              // Short bio
              Text(
                'Chuyên gia thiết kế sản phẩm số với hơn 8 năm kinh nghiệm trong lĩnh vực UI/UX và Product Design.',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.vGap12,

              // Tags
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InstructorInfoTag(icon: Icons.school_outlined, label: 'Thạc sĩ Thiết kế'),
                  InstructorInfoTag(icon: Icons.location_on_outlined, label: 'Hà Nội, Việt Nam'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: const Row(
        children: [
          InstructorStatItem(icon: Icons.menu_book_outlined, value: '12', label: 'Khóa học'),
          InstructorVerticalDivider(),
          InstructorStatItem(icon: Icons.people_outline, value: '2.4K', label: 'Học viên'),
          InstructorVerticalDivider(),
          InstructorStatItem(icon: Icons.play_circle_outline, value: '128', label: 'Bài học'),
          InstructorVerticalDivider(),
          InstructorStatItem(icon: Icons.star_outline_rounded, value: '4.9', label: 'Đánh giá'),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới thiệu',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        AppSpacing.vGap12,
        Text(
          'Cô Minh Anh hiện là Product Designer tại một công ty công nghệ hàng đầu. '
          'Cô tập trung vào thiết kế trải nghiệm người dùng, nghiên cứu người dùng '
          'và xây dựng sản phẩm số có giá trị thực tiễn.',
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        AppSpacing.vGap8,
        InkWell(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem thêm',
                style: tt.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.expand_more_rounded, size: 18, color: cs.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpertiseSection(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final skills = [
      (Icons.devices_rounded, 'UI/UX Design'),
      (Icons.widgets_outlined, 'Product Design'),
      (Icons.people_outline, 'User Research'),
      (Icons.touch_app_outlined, 'Interaction Design'),
      (Icons.lightbulb_outline, 'Design Thinking'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chuyên môn',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        AppSpacing.vGap12,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map((s) => InstructorSkillChip(icon: s.$1, label: s.$2))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCoursesSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Khóa học của cô',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Xem tất cả', style: tt.labelMedium?.copyWith(color: cs.primary)),
                  Icon(Icons.chevron_right_rounded, size: 18, color: cs.primary),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vGap12,

        // Horizontal course list
        SizedBox(
          height: 210,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              const InstructorCourseCard(
                title: 'UI/UX Design Fundamentals',
                lessonCount: 12,
                duration: '6h 40m',
                progress: 0.65,
                isEnrolled: true,
              ),
              AppSpacing.hGap12,
              const InstructorCourseCard(
                title: 'Product Design Masterclass',
                lessonCount: 18,
                duration: '8h 20m',
                progress: 0.40,
              ),
              AppSpacing.hGap12,
              const InstructorCourseCard(
                title: 'Design Thinking for UX',
                lessonCount: 10,
                duration: '4h 15m',
                progress: 0.20,
              ),
              AppSpacing.hGap12,
              const InstructorCourseCard(
                title: 'User Research Methods',
                lessonCount: 14,
                duration: '5h 30m',
                progress: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Đánh giá từ học viên',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Xem tất cả', style: tt.labelMedium?.copyWith(color: cs.primary)),
                  Icon(Icons.chevron_right_rounded, size: 18, color: cs.primary),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vGap12,

        // Rating summary card
        const InstructorRatingSummaryCard(),
        AppSpacing.vGap16,

        // Review item
        const InstructorReviewItem(
          name: 'Nguyễn Hoàng Nam',
          avatar: null,
          isVerified: false,
          date: '2 tuần trước',
          rating: 5,
          content: 'Giảng viên giải thích rất dễ hiểu, ví dụ thực tế và bài tập sát với thực tế. '
              'Mình học được rất nhiều từ cô Minh Anh!',
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('Nhắn tin cho cô'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}
