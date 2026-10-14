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
    final l10n = AppLocalizations.of(context)!;

    final totalBadges = _allBadges.length;
    final earnedCount =
        _allBadges.where((b) => b.status == BadgeStatus.earned).length;
    final progressVal = totalBadges > 0 ? earnedCount / totalBadges : 0.0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    AchievementBackButton(onTap: () => Navigator.pop(context)),
                    const Spacer(),
                    FilterButton(onTap: () => _showFilterSheet(context)),
                  ],
                ),
              ),
            ),

            // Hero Trophy Showcase Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF1E3A8A), Color(0xFF3D5FC4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Color(0xFFFDE047),
                              size: 28,
                            ),
                          ),
                          AppSpacing.hGap12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'PHÒNG TRUYỀN THỐNG',
                                      style: TextStyle(
                                        color: Color(0xFF93C5FD),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(AppRadius.full),
                                        border: Border.all(color: const Color(0xFFFCD34D), width: 0.8),
                                      ),
                                      child: const Text(
                                        'Hạng Vàng',
                                        style: TextStyle(
                                          color: Color(0xFFFDE047),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Bảng Vàng Danh Dự Học Viên',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Đã mở khóa $earnedCount/$totalBadges huy hiệu',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(progressVal * 100).round()}% hoàn thành',
                            style: const TextStyle(
                              color: Color(0xFF93C5FD),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          value: progressVal,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFDE047)),
                        ),
                      ),
                    ],
                  ),
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

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Earned Badges Section (Grid 3 Columns for larger glowing badges)
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
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
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
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
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
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72,
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

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
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
