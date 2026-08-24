import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

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
          _SoftIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          _SoftIconButton(icon: Icons.bookmark_outline_rounded, onTap: () {}),
          AppSpacing.hGap8,
          _SoftIconButton(icon: Icons.more_vert_rounded, onTap: () {}),
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
                        placeholder: (_, _) => _AvatarPlaceholder(name: instructorName),
                        errorWidget: (_, _, _) => _AvatarPlaceholder(name: instructorName),
                      )
                    : _AvatarPlaceholder(name: instructorName),
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
                  _InfoTag(icon: Icons.school_outlined, label: 'Thạc sĩ Thiết kế'),
                  _InfoTag(icon: Icons.location_on_outlined, label: 'Hà Nội, Việt Nam'),
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
      child: Row(
        children: [
          const _StatItem(icon: Icons.menu_book_outlined, value: '12', label: 'Khóa học'),
          _VerticalDivider(),
          const _StatItem(icon: Icons.people_outline, value: '2.4K', label: 'Học viên'),
          _VerticalDivider(),
          const _StatItem(icon: Icons.play_circle_outline, value: '128', label: 'Bài học'),
          _VerticalDivider(),
          const _StatItem(icon: Icons.star_outline_rounded, value: '4.9', label: 'Đánh giá'),
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
    final cs = Theme.of(context).colorScheme;
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
          children: skills.map((s) => _SkillChip(icon: s.$1, label: s.$2)).toList(),
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
              const _CourseCard(
                title: 'UI/UX Design Fundamentals',
                lessonCount: 12,
                duration: '6h 40m',
                progress: 0.65,
                isEnrolled: true,
              ),
              AppSpacing.hGap12,
              const _CourseCard(
                title: 'Product Design Masterclass',
                lessonCount: 18,
                duration: '8h 20m',
                progress: 0.40,
              ),
              AppSpacing.hGap12,
              const _CourseCard(
                title: 'Design Thinking for UX',
                lessonCount: 10,
                duration: '4h 15m',
                progress: 0.20,
              ),
              AppSpacing.hGap12,
              const _CourseCard(
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
        _RatingSummaryCard(),
        AppSpacing.vGap16,

        // Review item
        const _ReviewItem(
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

// =============================================================================
// Components
// =============================================================================

class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: cs.onSurfaceVariant, size: 22),
        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      color: cs.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'T',
        style: tt.displaySmall?.copyWith(color: cs.onPrimaryContainer),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: cs.primary, size: 22),
          AppSpacing.vGap4,
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 40,
      color: cs.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.title,
    required this.lessonCount,
    required this.duration,
    required this.progress,
    this.isEnrolled = false,
  });

  final String title;
  final int lessonCount;
  final String duration;
  final double progress;
  final bool isEnrolled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                child: Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.primary.withValues(alpha: 0.8),
                        cs.primary.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Icon(
                          Icons.auto_awesome_mosaic_rounded,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isEnrolled)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Đang học',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGap4,
                Row(
                  children: [
                    Icon(Icons.play_circle_outline, size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '$lessonCount bài học',
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10),
                    ),
                    const SizedBox(width: 4),
                    Text('•', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10),
                    ),
                  ],
                ),
                if (progress > 0) ...[
                  AppSpacing.vGap8,
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: cs.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Left: big rating
          Column(
            children: [
              Text(
                '4.9',
                style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Row(
                children: List.generate(5, (i) => const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Colors.amber,
                )),
              ),
              AppSpacing.vGap4,
              Text(
                '(128 đánh giá)',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          AppSpacing.hGap24,

          // Right: breakdown bars
          const Expanded(
            child: Column(
              children: [
                _RatingBar(stars: 5, count: 110, total: 128),
                _RatingBar(stars: 4, count: 14, total: 128),
                _RatingBar(stars: 3, count: 3, total: 128),
                _RatingBar(stars: 2, count: 1, total: 128),
                _RatingBar(stars: 1, count: 0, total: 128),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.stars, required this.count, required this.total});
  final int stars;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final ratio = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$stars',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
          AppSpacing.hGap8,
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
          ),
          AppSpacing.hGap8,
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.name,
    this.avatar,
    required this.isVerified,
    required this.date,
    required this.rating,
    required this.content,
  });

  final String name;
  final String? avatar;
  final bool isVerified;
  final String date;
  final int rating;
  final String content;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CachedAvatar(
                url: avatar,
                radius: 20,
                backgroundColor: cs.primaryContainer,
                name: name,
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified_rounded, size: 14, color: cs.primary),
                        ],
                      ],
                    ),
                    Text(
                      date,
                      style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          AppSpacing.vGap8,
          Row(
            children: List.generate(5, (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 16,
              color: Colors.amber,
            )),
          ),
          AppSpacing.vGap8,
          Text(
            content,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
