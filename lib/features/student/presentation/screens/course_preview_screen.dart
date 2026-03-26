import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_course_preview_data.dart';
import 'package:study/features/student/data/models/teacher_course_item.dart';
import 'package:study/features/student/presentation/screens/teacher_profile_screen.dart';
import 'package:study/theme/app_colors.dart';

class CoursePreviewScreen extends StatelessWidget {
  const CoursePreviewScreen({
    super.key,
    required this.title,
    required this.price,
    required this.rating,
    this.gradient,
    this.icon,
    this.instructorName,
  });

  final String title;
  final String price;
  final double rating;
  final List<Color>? gradient;
  final IconData? icon;
  final String? instructorName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final grad =
        gradient ?? [cs.primary, cs.inversePrimary];
    final ic = icon ?? Icons.school_rounded;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, cs, tt, grad, ic),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(
                  AppLayout.screenMargin),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _QuickStatsRow(
                      rating: rating, cs: cs),
                  const SizedBox(
                      height: AppSpacing.xxxl),
                  _InstructorRow(
                    name: instructorName ??
                        'Thay Mai Hoang Tung',
                  ),
                  const SizedBox(
                      height: AppSpacing.xxxl),
                  _DescriptionSection(cs: cs, tt: tt),
                  const SizedBox(
                      height: AppSpacing.xxxl),
                  _OutcomesSection(cs: cs, tt: tt),
                  const SizedBox(
                      height: AppSpacing.xxxl),
                  _CurriculumSection(cs: cs, tt: tt),
                  const SizedBox(
                      height: AppSpacing.huge),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          _BottomBar(price: price, cs: cs, tt: tt),
    );
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
    List<Color> grad,
    IconData ic,
  ) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: cs.surface,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
                Icons.bookmark_border_rounded,
                color: Colors.white,
                size: 20),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_outlined,
                color: Colors.white, size: 20),
          ),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: grad,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -30,
                right: -30,
                child: Icon(ic,
                    size: 180,
                    color: Colors.white
                        .withValues(alpha: 0.08)),
              ),
              Positioned(
                bottom: 40,
                left: AppLayout.screenMargin,
                right: AppLayout.screenMargin,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.2),
                        borderRadius:
                            AppRadius.borderSm,
                      ),
                      child: Text(
                        'KHOA HOC',
                        style:
                            tt.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: AppSpacing.sm),
                    Text(
                      title.replaceAll('\n', ' '),
                      style:
                          tt.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({
    required this.rating,
    required this.cs,
  });
  final double rating;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickStat(
          icon: Icons.star_rounded,
          value: '$rating',
          label: 'Danh gia',
          color: cs.tertiary,
        ),
        const SizedBox(width: AppSpacing.lg),
        _QuickStat(
          icon: Icons.people_outline_rounded,
          value: '1.2k+',
          label: 'Hoc vien',
          color: cs.primary,
        ),
        const SizedBox(width: AppSpacing.lg),
        _QuickStat(
          icon: Icons.access_time_rounded,
          value: '24h',
          label: 'Tong thoi gian',
          color: cs.secondary,
        ),
        const SizedBox(width: AppSpacing.lg),
        _QuickStat(
          icon: Icons.menu_book_rounded,
          value: '36',
          label: 'Bai hoc',
          color: cs.primary,
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: AppIconSize.md, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InstructorRow extends StatelessWidget {
  const _InstructorRow({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TeacherProfileScreen(
            instructorName: name,
            instructorTitle:
                'Senior Specialist & Tech Lead',
            instructorBio:
                'Voi hon 12 nam kinh nghiem trong '
                'linh vuc dao tao va phat trien cong '
                'nghe tai cac tap doan da quoc gia, '
                'da giup hon 5.000 hoc vien thay doi '
                'tu duy va dat duoc nhung buoc tien '
                'lon trong su nghiep.',
            instructorStudentCount: 5200,
            instructorRating: 4.8,
            instructorCourseCount: 14,
            skills: const [
              'Product Design',
              'Figma Pro',
              'User Research',
            ],
            featuredCourses: const [
              TeacherCourseItem(
                id: 'tc1',
                title: 'Mastering Figma: '
                    'From Beginner to Pro 2024',
                duration: '12h 45m',
                price: '\$49.99',
                rating: 4.9,
              ),
              TeacherCourseItem(
                id: 'tc2',
                title: 'User Research Methods '
                    'for Fast-Paced Startups',
                duration: '8h 20m',
                price: '\$34.00',
                rating: 4.8,
              ),
            ],
          ),
        ),
      ),
      child: Container(
        padding: AppLayout.cardPaddingCompact,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.outline),
          boxShadow: cs.shadowCard,
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: cs.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor:
                    cs.surfaceTintedPrimary,
                child: Icon(Icons.person_rounded,
                    size: AppIconSize.lg,
                    color: cs.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700)),
                  const SizedBox(
                      height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          size: AppIconSize.xs,
                          color: cs.primary),
                      const SizedBox(
                          width: AppSpacing.xs),
                      Text('Giang vien',
                          style: tt.labelSmall
                              ?.copyWith(
                                  color: cs
                                      .onSurfaceVariant)),
                      const SizedBox(
                          width: AppSpacing.md),
                      Icon(Icons.star_rounded,
                          size: AppIconSize.xs,
                          color: cs.tertiary),
                      const SizedBox(
                          width: AppSpacing.xxs),
                      Text('4.8',
                          style:
                              tt.labelSmall?.copyWith(
                            color:
                                cs.onSurfaceVariant,
                            fontWeight:
                                FontWeight.w600,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceTintedPrimary,
                borderRadius: AppRadius.borderXxl,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Xem',
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(
                      width: AppSpacing.xxs),
                  Icon(Icons.arrow_forward_rounded,
                      size: AppIconSize.xs,
                      color: cs.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gioi thieu khoa hoc',
            style: tt.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Khoa hoc nay duoc thiet ke de giup ban lam chu '
          'cac ky nang can thiet trong ky nguyen so. '
          'Chung toi tap trung vao viec thuc hanh thuc te, '
          'giai quyet cac bai toan thuc te ma mot chuyen gia '
          'thuong gap phai.\n\n'
          'Voi lo trinh bai ban tu co ban den nang cao, ban '
          'se khong chi hoc ly thuyet ma con duoc tham gia '
          'vao cac du an thuc te de cung co kien thuc.',
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _OutcomesSection extends StatelessWidget {
  const _OutcomesSection({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ban se hoc duoc gi',
            style: tt.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.lg),
        ...mockOutcomes.map((o) => Padding(
              padding: const EdgeInsets.only(
                  bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: cs.surfaceTintedPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        size: AppIconSize.sm,
                        color: cs.primary),
                  ),
                  const SizedBox(
                      width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      o,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _CurriculumSection extends StatelessWidget {
  const _CurriculumSection({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Noi dung khoa hoc',
            style: tt.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.md),
        Text(
          '4 chuong • 36 bai hoc • 24 gio',
          style: tt.labelMedium
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...mockChapters.asMap().entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(
                    bottom: AppSpacing.sm),
                padding: AppLayout.cardPaddingCompact,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: AppRadius.borderMd,
                  border:
                      Border.all(color: cs.outline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.surfaceTintedPrimary,
                        borderRadius:
                            AppRadius.borderSm,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style:
                              tt.labelLarge?.copyWith(
                            fontWeight:
                                FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value['title']!,
                            style: tt.bodyMedium
                                ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          Text(
                            entry.value['meta']!,
                            style: tt.labelSmall
                                ?.copyWith(
                              color: cs
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.lock_outline_rounded,
                      size: AppIconSize.sm,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.price,
    required this.cs,
    required this.tt,
  });
  final String price;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.md,
        AppLayout.screenMargin,
        MediaQuery.of(context).padding.bottom +
            AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border:
            Border(top: BorderSide(color: cs.outline)),
        boxShadow: cs.shadowElevated,
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text('Gia khoa hoc',
                  style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant)),
              Text(
                price,
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: cs.gradientPrimary,
                  borderRadius: AppRadius.borderLg,
                  boxShadow: cs.shadowPrimary,
                ),
                child: Center(
                  child: Text(
                    'Dang ky ngay',
                    style: tt.titleSmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
