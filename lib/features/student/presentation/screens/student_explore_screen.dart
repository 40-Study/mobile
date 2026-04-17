import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_explore_data.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/forum_screen.dart';
import 'package:study/features/student/presentation/screens/leaderboard_screen.dart';
import 'package:study/features/student/presentation/screens/livestream_list_screen.dart';
import 'package:study/features/student/presentation/screens/vouchers_screen.dart';
import 'package:study/features/student/presentation/widgets/explore/explore_widgets.dart';
import 'package:study/theme/app_colors.dart';

class StudentExploreScreen extends StatefulWidget {
  const StudentExploreScreen({super.key});

  @override
  State<StudentExploreScreen> createState() =>
      _StudentExploreScreenState();
}

class _StudentExploreScreenState
    extends State<StudentExploreScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeader(cs, tt),
            _buildSearchBar(cs, tt),
            _buildQuickActions(cs),
            _buildArticlesSection(),
            _buildLivestreamSection(),
            _buildForumSection(),
            _buildContestsSection(),
            _buildTrendingCoursesSection(),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.massive),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(
    ColorScheme cs,
    TextTheme tt,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.screenMargin,
          AppSpacing.lg,
          AppLayout.screenMargin,
          0,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: cs.shadowCard,
              ),
              child: Icon(Icons.explore_rounded,
                  color: cs.onPrimary,
                  size: AppIconSize.lg),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Explore',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outline),
                ),
                child: Icon(Icons.search_rounded,
                    color: cs.primary,
                    size: AppIconSize.md),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar(
    ColorScheme cs,
    TextTheme tt,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.screenMargin,
          AppSpacing.lg,
          AppLayout.screenMargin,
          0,
        ),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderXl,
            border: Border.all(color: cs.outline),
            boxShadow: cs.shadowCard,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.lg),
              Icon(Icons.search_rounded,
                  size: AppIconSize.md,
                  color: cs.onSurfaceVariant),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Tim kiem khoa hoc, bai viet...',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildQuickActions(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.screenMargin,
          AppSpacing.xl,
          AppLayout.screenMargin,
          0,
        ),
        child: Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.live_tv_rounded,
                label: 'Livestream',
                color: Colors.red,
                onTap: () => _openLivestream(context),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.forum_rounded,
                label: 'Dien dan',
                color: Colors.blue,
                onTap: () => _openForum(context),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.leaderboard_rounded,
                label: 'Xep hang',
                color: Colors.amber,
                onTap: () => _openLeaderboard(context),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.local_offer_rounded,
                label: 'Voucher',
                color: Colors.green,
                onTap: () => _openVouchers(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLivestream(BuildContext context) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: const LivestreamListScreen(),
        ),
      ),
    );
  }

  void _openForum(BuildContext context) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: const ForumScreen(),
        ),
      ),
    );
  }

  void _openLeaderboard(BuildContext context) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: const LeaderboardScreen(),
        ),
      ),
    );
  }

  void _openVouchers(BuildContext context) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: const VouchersScreen(),
        ),
      ),
    );
  }

  Widget _buildLivestreamSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              AppSpacing.xxxl,
              AppLayout.screenMargin,
              AppSpacing.lg,
            ),
            child: ExploreSectionHeader(
              title: 'Livestream sap dien ra',
              icon: Icons.sensors,
              iconColor: Colors.red,
              onViewAll: () => _openLivestream(context),
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenMargin,
              ),
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemCount: 3,
              itemBuilder: (context, index) => _LivestreamPreviewCard(
                index: index,
                onTap: () => _openLivestream(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              AppSpacing.xxxl,
              AppLayout.screenMargin,
              AppSpacing.lg,
            ),
            child: ExploreSectionHeader(
              title: 'Thao luan noi bat',
              icon: Icons.forum_outlined,
              onViewAll: () => _openForum(context),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenMargin,
              ),
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemCount: 3,
              itemBuilder: (context, index) => _ForumPreviewCard(
                index: index,
                onTap: () => _openForum(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              AppSpacing.xxxl,
              AppLayout.screenMargin,
              AppSpacing.lg,
            ),
            child: ExploreSectionHeader(
              title: 'Bai viet noi bat',
              onViewAll: () {},
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenMargin,
              ),
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemCount: mockArticles.length,
              itemBuilder: (context, index) =>
                  ExploreArticleCard(
                article: mockArticles[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContestsSection() {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              AppSpacing.xxxl,
              AppLayout.screenMargin,
              AppSpacing.lg,
            ),
            child: ExploreSectionHeader(
              title: 'Cuoc thi dang dien ra',
              onViewAll: () {},
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenMargin,
          ),
          sliver: SliverList.separated(
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemCount: mockContests.length,
            itemBuilder: (context, index) =>
                ExploreContestCard(
              contest: mockContests[index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingCoursesSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenMargin,
              AppSpacing.xxxl,
              AppLayout.screenMargin,
              AppSpacing.lg,
            ),
            child: ExploreSectionHeader(
              title: 'Khoa hoc xu huong',
              onViewAll: () {},
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.screenMargin,
              ),
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.md),
              itemCount: mockTrendingCourses.length,
              itemBuilder: (context, index) =>
                  ExploreTrendingCourseCard(
                course: mockTrendingCourses[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LivestreamPreviewCard extends StatelessWidget {
  const _LivestreamPreviewCard({
    required this.index,
    required this.onTap,
  });

  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final titles = [
      'Chia se kinh nghiem lam bai thi',
      'Q&A ve khoa hoc lap trinh',
      'Huong dan lam do an tot nghiep',
    ];

    final times = ['15:00 hom nay', '19:30 hom nay', '20:00 ngay mai'];
    final isLive = index == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sensors, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: cs.outline),
                      const SizedBox(width: 4),
                      Text(
                        times[index],
                        style: tt.bodySmall?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              titles[index],
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.person, size: 14, color: cs.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Giang vien ${index + 1}',
                  style: tt.bodySmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ForumPreviewCard extends StatelessWidget {
  const _ForumPreviewCard({
    required this.index,
    required this.onTap,
  });

  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final titles = [
      'Lam sao de hoc hieu qua?',
      'Kinh nghiem on thi IELTS',
      'Review khoa hoc Python',
    ];

    final categories = ['Hoi dap', 'Chia se', 'Review'];
    final votes = [42, 28, 15];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.outline.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                categories[index],
                style: tt.labelSmall?.copyWith(
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Text(
                titles[index],
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Icon(Icons.thumb_up_outlined, size: 14, color: cs.outline),
                const SizedBox(width: 4),
                Text(
                  '${votes[index]}',
                  style: tt.bodySmall?.copyWith(color: cs.outline),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.chat_bubble_outline, size: 14, color: cs.outline),
                const SizedBox(width: 4),
                Text(
                  '${votes[index] ~/ 3}',
                  style: tt.bodySmall?.copyWith(color: cs.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
