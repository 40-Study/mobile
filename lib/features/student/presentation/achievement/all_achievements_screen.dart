import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/achievement/widgets/widgets.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

// Badge status enum
enum BadgeStatus { earned, inProgress, locked }

// Badge category enum
enum BadgeCategory { all, learning, habit, achievement }

// Extended badge data for this screen
class AchievementBadgeData {
  const AchievementBadgeData({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.icon,
    required this.color,
    this.progress = 0,
    this.target = 100,
    this.earnedAt,
    this.isNew = false,
  });

  final String id;
  final String title;
  final String description;
  final BadgeStatus status;
  final BadgeCategory category;
  final IconData icon;
  final Color color;
  final int progress;
  final int target;
  final DateTime? earnedAt;
  final bool isNew;

  double get progressPercent =>
      target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
}

class AllAchievementsScreen extends StatefulWidget {
  const AllAchievementsScreen({super.key, required this.badges});

  final List<BadgeModel> badges;

  @override
  State<AllAchievementsScreen> createState() => _AllAchievementsScreenState();
}

class _AllAchievementsScreenState extends State<AllAchievementsScreen> {
  static const _categories = [
    BadgeCategory.all,
    BadgeCategory.learning,
    BadgeCategory.habit,
    BadgeCategory.achievement,
  ];

  late final List<AchievementBadgeData> _allBadges = _mapBadges(widget.badges);
  late final PageController _pageController;
  late final ScrollController _categoryScrollController;
  final List<GlobalKey> _chipKeys = List.generate(4, (_) => GlobalKey());

  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedCategoryIndex);
    _categoryScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  int _countByCategory(BadgeCategory cat) {
    if (cat == BadgeCategory.all) return _allBadges.length;
    return _allBadges.where((b) => b.category == cat).length;
  }

  void _onCategoryTapped(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    _scrollToSelectedChip(index);
  }

  void _onPageChanged(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    _scrollToSelectedChip(index);
  }

  void _scrollToSelectedChip(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _chipKeys[index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final totalBadges = _allBadges.length;
    final earnedCount =
        _allBadges.where((b) => b.status == BadgeStatus.earned).length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar (Always visible)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
              child: Row(
                children: [
                  AchievementBackButton(onTap: () => Navigator.pop(context)),
                  const Spacer(),
                  FilterButton(onTap: () => _showFilterSheet(context)),
                ],
              ),
            ),

            // NestedScrollView: Hero Banner scrolls away, Category Tabs stay pinned, PageView swipes horizontally
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // Hero Trophy Showcase Header (Flat Light, No Gradient)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.sm,
                        bottom: AppSpacing.md,
                      ),
                      child: AchievementsHeroBanner(
                        earnedCount: earnedCount,
                        totalBadges: totalBadges,
                        learningCount: _countByCategory(
                          BadgeCategory.learning,
                        ),
                        habitCount: _countByCategory(
                          BadgeCategory.habit,
                        ),
                        achievementCount: _countByCategory(
                          BadgeCategory.achievement,
                        ),
                      ),
                    ),
                  ),

                  // Sticky Category Tabs
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: CategoryTabsHeaderDelegate(
                      height: 52,
                      child: _buildCategoryTabs(l10n),
                    ),
                  ),
                ],
                body: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryBadgeView(
                      _categories[index],
                      l10n,
                      cs,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(AppLocalizations l10n) {
    final categoryIcons = [
      Icons.grid_view_rounded,
      Icons.menu_book_rounded,
      Icons.loop_rounded,
      Icons.emoji_events_rounded,
    ];

    final categoryLabels = [
      l10n.all,
      l10n.learning,
      l10n.habit,
      l10n.achievement,
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => AppSpacing.hGap8,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          return CategoryChip(
            key: _chipKeys[i],
            icon: categoryIcons[i],
            label: categoryLabels[i],
            count: _countByCategory(cat),
            isSelected: _selectedCategoryIndex == i,
            onTap: () => _onCategoryTapped(i),
          );
        },
      ),
    );
  }

  Widget _buildCategoryBadgeView(
    BadgeCategory cat,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    final badges = cat == BadgeCategory.all
        ? _allBadges
        : _allBadges.where((b) => b.category == cat).toList();

    final earned =
        badges.where((b) => b.status == BadgeStatus.earned).toList();
    final inProgress =
        badges.where((b) => b.status == BadgeStatus.inProgress).toList();
    final locked =
        badges.where((b) => b.status == BadgeStatus.locked).toList();

    if (badges.isEmpty) {
      return _buildEmptyState(cs);
    }

    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: PageStorageKey<String>('achievements_page_${cat.name}'),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Earned Badges Section (Grid 3 Columns)
            if (earned.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.earned,
                  count: earned.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BadgeCard(
                      badge: earned[index],
                      onTap: () => _showBadgeDetail(context, earned[index]),
                    ),
                    childCount: earned.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // In Progress Badges Section
            if (inProgress.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.inProgress,
                  count: inProgress.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BadgeCard(
                      badge: inProgress[index],
                      onTap: () =>
                          _showBadgeDetail(context, inProgress[index]),
                    ),
                    childCount: inProgress.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // Locked Badges Section
            if (locked.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.notEarned,
                  count: locked.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BadgeCard(
                      badge: locked[index],
                      onTap: () => _showBadgeDetail(context, locked[index]),
                    ),
                    childCount: locked.length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          margin: const EdgeInsets.all(AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.xl),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.emoji_events_outlined, size: 48, color: cs.slate400),
              const SizedBox(height: 12),
              const Text(
                'Chưa có huy hiệu nào trong danh mục này',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showBadgeDetail(BuildContext context, AchievementBadgeData badge) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => BadgeDetailSheet(badge: badge),
    );
  }

  List<AchievementBadgeData> _mapBadges(List<BadgeModel> badges) {
    final colors = [
      AchievementColors.orange,
      AchievementColors.blue,
      AchievementColors.green,
      AchievementColors.purple,
      AchievementColors.pink,
      AchievementColors.violet,
      AchievementColors.deepOrange,
      AchievementColors.lightBlue,
    ];

    final icons = [
      Icons.emoji_events_rounded,
      Icons.star_rounded,
      Icons.menu_book_rounded,
      Icons.local_fire_department_rounded,
      Icons.bolt_rounded,
      Icons.workspace_premium_rounded,
      Icons.school_rounded,
      Icons.lightbulb_rounded,
    ];

    return badges.asMap().entries.map((entry) {
      final i = entry.key;
      final badge = entry.value;

      final status =
          badge.isEarned ? BadgeStatus.earned : BadgeStatus.locked;

      final category = _mapCategory(badge.category);

      return AchievementBadgeData(
        id: badge.id,
        title: badge.name,
        description: badge.description ?? '',
        status: status,
        category: category,
        icon: icons[i % icons.length],
        color: colors[i % colors.length],
        earnedAt: badge.earnedAt,
        isNew: badge.earnedAt != null &&
            DateTime.now().difference(badge.earnedAt!).inDays < 7,
      );
    }).toList();
  }

  BadgeCategory _mapCategory(String? category) {
    switch (category) {
      case 'learning':
        return BadgeCategory.learning;
      case 'habit':
      case 'streak':
        return BadgeCategory.habit;
      case 'achievement':
      case 'course':
      case 'quiz':
      case 'speed':
        return BadgeCategory.achievement;
      default:
        return BadgeCategory.learning;
    }
  }
}
