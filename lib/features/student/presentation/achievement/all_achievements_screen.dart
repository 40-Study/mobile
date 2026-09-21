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
  BadgeCategory _selectedCategory = BadgeCategory.all;

  late final List<AchievementBadgeData> _allBadges = _mapBadges(widget.badges);

  List<AchievementBadgeData> get _filteredBadges {
    if (_selectedCategory == BadgeCategory.all) return _allBadges;
    return _allBadges.where((b) => b.category == _selectedCategory).toList();
  }

  List<AchievementBadgeData> get _earnedBadges =>
      _filteredBadges.where((b) => b.status == BadgeStatus.earned).toList();

  List<AchievementBadgeData> get _inProgressBadges =>
      _filteredBadges.where((b) => b.status == BadgeStatus.inProgress).toList();

  List<AchievementBadgeData> get _lockedBadges =>
      _filteredBadges.where((b) => b.status == BadgeStatus.locked).toList();

  int _countByCategory(BadgeCategory cat) {
    if (cat == BadgeCategory.all) return _allBadges.length;
    return _allBadges.where((b) => b.category == cat).length;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final totalBadges = _allBadges.length;
    final earnedCount =
        _allBadges.where((b) => b.status == BadgeStatus.earned).length;
    final inProgressCount =
        _allBadges.where((b) => b.status == BadgeStatus.inProgress).length;
    final lockedCount =
        _allBadges.where((b) => b.status == BadgeStatus.locked).length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AchievementBackButton(onTap: () => Navigator.pop(context)),
                        const Spacer(),
                        FilterButton(onTap: () => _showFilterSheet(context)),
                      ],
                    ),
                    AppSpacing.vGap16,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: tt.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                            children: [
                              TextSpan(text: l10n.allBadges),
                              TextSpan(
                                text: '.',
                                style: TextStyle(color: cs.primary),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.vGap4,
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 14, color: cs.onSurfaceVariant),
                            AppSpacing.hGap4,
                            Text(
                              l10n.badgesEarned(earnedCount, totalBadges),
                              style: tt.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Overall Progress Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: OverallProgressCard(
                  earnedCount: earnedCount,
                  inProgressCount: inProgressCount,
                  lockedCount: lockedCount,
                  totalCount: totalBadges,
                ),
              ),
            ),

            // Category Tabs
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    CategoryChip(
                      icon: Icons.grid_view_rounded,
                      label: l10n.all,
                      count: _countByCategory(BadgeCategory.all),
                      isSelected: _selectedCategory == BadgeCategory.all,
                      onTap: () =>
                          setState(() => _selectedCategory = BadgeCategory.all),
                    ),
                    AppSpacing.hGap8,
                    CategoryChip(
                      icon: Icons.menu_book_rounded,
                      label: l10n.learning,
                      count: _countByCategory(BadgeCategory.learning),
                      isSelected: _selectedCategory == BadgeCategory.learning,
                      onTap: () => setState(
                          () => _selectedCategory = BadgeCategory.learning),
                    ),
                    AppSpacing.hGap8,
                    CategoryChip(
                      icon: Icons.loop_rounded,
                      label: l10n.habit,
                      count: _countByCategory(BadgeCategory.habit),
                      isSelected: _selectedCategory == BadgeCategory.habit,
                      onTap: () =>
                          setState(() => _selectedCategory = BadgeCategory.habit),
                    ),
                    AppSpacing.hGap8,
                    CategoryChip(
                      icon: Icons.emoji_events_rounded,
                      label: l10n.achievement,
                      count: _countByCategory(BadgeCategory.achievement),
                      isSelected: _selectedCategory == BadgeCategory.achievement,
                      onTap: () => setState(
                          () => _selectedCategory = BadgeCategory.achievement),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: AppSpacing.vGap24),

            // Earned Badges Section
            if (_earnedBadges.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.earned,
                  count: _earnedBadges.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.62,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BadgeCard(
                      badge: _earnedBadges[index],
                      onTap: () => _showBadgeDetail(context, _earnedBadges[index]),
                    ),
                    childCount: _earnedBadges.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.vGap32),
            ],

            // In Progress Badges Section
            if (_inProgressBadges.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.inProgress,
                  count: _inProgressBadges.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BadgeCard(
                      badge: _inProgressBadges[index],
                      onTap: () =>
                          _showBadgeDetail(context, _inProgressBadges[index]),
                    ),
                    childCount: _inProgressBadges.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.vGap32),
            ],

            // Locked Badges Section
            if (_lockedBadges.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.notEarned,
                  count: _lockedBadges.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BadgeCard(
                      badge: _lockedBadges[index],
                      onTap: () =>
                          _showBadgeDetail(context, _lockedBadges[index]),
                    ),
                    childCount: _lockedBadges.length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _showBadgeDetail(BuildContext context, AchievementBadgeData badge) {
    showModalBottomSheet(
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
      AchievementColors.purple,
      AchievementColors.orange,
      AchievementColors.green,
      AchievementColors.blue,
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
