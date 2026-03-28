import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_explore_data.dart';
import 'package:study/features/student/presentation/widgets/explore/explore_widgets.dart';
import 'package:study/features/weather/weather.dart';
import 'package:study/theme/app_colors.dart';

class StudentExploreScreen extends StatefulWidget {
  const StudentExploreScreen({super.key});

  @override
  State<StudentExploreScreen> createState() =>
      _StudentExploreScreenState();
}

class _StudentExploreScreenState
    extends State<StudentExploreScreen> {
  String _selectedFilter = 'Tat ca';

  static const _filters = [
    'Tat ca',
    'Bai viet',
    'Cuoc thi',
    'Khoa hoc',
    'Giang vien',
  ];

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
            _buildFilterChips(cs, tt),
            _buildArticlesSection(),
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
        child: BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
          builder: (context, state) {
            return Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: cs.gradientPrimary,
                    borderRadius: AppRadius.borderMd,
                    boxShadow: cs.shadowPrimary,
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
                      fontWeight: FontWeight.w800,
                      color: context.weatherTextColorThemed,
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
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(color: cs.outline),
                    ),
                    child: Icon(Icons.search_rounded,
                        color: cs.primary,
                        size: AppIconSize.md),
                  ),
                ),
              ],
            );
          },
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

  SliverToBoxAdapter _buildFilterChips(
    ColorScheme cs,
    TextTheme tt,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.only(top: AppSpacing.lg),
        child: SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.screenMargin,
            ),
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.sm),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected =
                  filter == _selectedFilter;
              return GestureDetector(
                onTap: () => setState(
                  () => _selectedFilter = filter,
                ),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primary
                        : cs.surfaceContainerLowest,
                    borderRadius: AppRadius.borderXxl,
                    border: isSelected
                        ? null
                        : Border.all(color: cs.outline),
                  ),
                  child: Text(
                    filter,
                    style: tt.labelMedium?.copyWith(
                      color: isSelected
                          ? cs.onPrimary
                          : cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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
            height: 240,
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
