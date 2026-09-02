import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
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
                    // Back + Filter row
                    Row(
                      children: [
                        _BackButton(onTap: () => Navigator.pop(context)),
                        const Spacer(),
                        _FilterButton(onTap: () => _showFilterSheet(context)),
                      ],
                    ),
                    AppSpacing.vGap16,
                    // Title với dot
                    Builder(builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
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
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Overall Progress Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _OverallProgressCard(
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
                child: Builder(builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    children: [
                      _CategoryChip(
                        icon: Icons.grid_view_rounded,
                        label: l10n.all,
                        count: _countByCategory(BadgeCategory.all),
                        isSelected: _selectedCategory == BadgeCategory.all,
                        onTap: () =>
                            setState(() => _selectedCategory = BadgeCategory.all),
                      ),
                      AppSpacing.hGap8,
                      _CategoryChip(
                        icon: Icons.menu_book_rounded,
                        label: l10n.learning,
                        count: _countByCategory(BadgeCategory.learning),
                        isSelected: _selectedCategory == BadgeCategory.learning,
                        onTap: () => setState(
                            () => _selectedCategory = BadgeCategory.learning),
                      ),
                      AppSpacing.hGap8,
                      _CategoryChip(
                        icon: Icons.loop_rounded,
                        label: l10n.habit,
                        count: _countByCategory(BadgeCategory.habit),
                        isSelected: _selectedCategory == BadgeCategory.habit,
                        onTap: () => setState(
                            () => _selectedCategory = BadgeCategory.habit),
                      ),
                      AppSpacing.hGap8,
                      _CategoryChip(
                        icon: Icons.emoji_events_rounded,
                        label: l10n.achievement,
                        count: _countByCategory(BadgeCategory.achievement),
                        isSelected: _selectedCategory == BadgeCategory.achievement,
                        onTap: () => setState(
                            () => _selectedCategory = BadgeCategory.achievement),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SliverToBoxAdapter(child: AppSpacing.vGap24),

            // Earned Badges Section
            if (_earnedBadges.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: AppLocalizations.of(context)!.earned,
                  count: _earnedBadges.length,
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.62,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _BadgeCard(
                      badge: _earnedBadges[index],
                      onTap: () =>
                          _showBadgeDetail(context, _earnedBadges[index]),
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
                child: _SectionHeader(
                  title: AppLocalizations.of(context)!.inProgress,
                  count: _inProgressBadges.length,
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _BadgeCard(
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
                child: _SectionHeader(
                  title: AppLocalizations.of(context)!.notEarned,
                  count: _lockedBadges.length,
                ),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _BadgeCard(
                      badge: _lockedBadges[index],
                      onTap: () =>
                          _showBadgeDetail(context, _lockedBadges[index]),
                    ),
                    childCount: _lockedBadges.length,
                  ),
                ),
              ),
            ],

            // Bottom padding
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
      builder: (context) => const _FilterBottomSheet(),
    );
  }

  void _showBadgeDetail(BuildContext context, AchievementBadgeData badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => _BadgeDetailSheet(badge: badge),
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

      final status = badge.isEarned
          ? BadgeStatus.earned
          : BadgeStatus.locked;

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

// ============================================================
// BACK BUTTON
// ============================================================
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(Icons.arrow_back_rounded, size: 20, color: cs.onSurface),
      ),
    );
  }
}

// ============================================================
// FILTER BUTTON
// ============================================================
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, size: 16, color: cs.onSurface),
            AppSpacing.hGap4,
            Text(AppLocalizations.of(context)!.filter, style: tt.labelMedium),
            AppSpacing.hGap4,
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// OVERALL PROGRESS CARD
// ============================================================
class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({
    required this.earnedCount,
    required this.inProgressCount,
    required this.lockedCount,
    required this.totalCount,
  });

  final int earnedCount;
  final int inProgressCount;
  final int lockedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = totalCount > 0 ? (earnedCount / totalCount * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.overallProgress,
                    style:
                        tt.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
                AppSpacing.vGap8,
                Text('$percent%',
                    style: tt.displaySmall?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w700)),
                AppSpacing.vGap4,
                Text(AppLocalizations.of(context)!.badgesEarned(earnedCount, totalCount),
                    style:
                        tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          // Right side - ring + stats
          Builder(builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Column(
              children: [
                _CircularProgress(
                  percent: percent / 100,
                  size: 80,
                  strokeWidth: 6,
                ),
                AppSpacing.vGap12,
                Row(
                  children: [
                    _StatusDot(
                        color: cs.primary,
                        count: earnedCount,
                        label: l10n.earned),
                  ],
                ),
                AppSpacing.vGap4,
                Row(
                  children: [
                    _StatusDot(
                        color: AchievementColors.blue,
                        count: inProgressCount,
                        label: l10n.inProgress),
                  ],
                ),
                AppSpacing.vGap4,
                Row(
                  children: [
                    _StatusDot(
                        color: cs.outlineVariant,
                        count: lockedCount,
                        label: l10n.notEarned),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  const _CircularProgress({
    required this.percent,
    required this.size,
    required this.strokeWidth,
  });

  final double percent;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              percent: percent,
              strokeWidth: strokeWidth,
              backgroundColor: cs.surfaceContainerHighest,
              progressColor: cs.primary,
            ),
          ),
          Icon(Icons.emoji_events_rounded,
              size: 28, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.percent,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double percent;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.color,
    required this.count,
    required this.label,
  });

  final Color color;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        AppSpacing.hGap8,
        Text('$count', style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        AppSpacing.hGap4,
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// ============================================================
// CATEGORY CHIP
// ============================================================
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.1)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? cs.primary : cs.onSurfaceVariant),
            AppSpacing.hGap8,
            Text(label,
                style: tt.labelMedium?.copyWith(
                    color: isSelected ? cs.primary : cs.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
            AppSpacing.hGap4,
            Text('$count',
                style: tt.labelSmall?.copyWith(
                    color: isSelected ? cs.primary : cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Text('$title ($count)',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

// ============================================================
// BADGE CARD
// ============================================================
class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge, required this.onTap});

  final AchievementBadgeData badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isLocked = badge.status == BadgeStatus.locked;
    final isInProgress = badge.status == BadgeStatus.inProgress;
    final displayColor = isLocked ? cs.outlineVariant : badge.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            // Badge hexagon
            Stack(
              clipBehavior: Clip.none,
              children: [
                _HexagonBadge(
                  icon: badge.icon,
                  color: displayColor,
                  isLocked: isLocked,
                  isInProgress: isInProgress,
                ),
                if (badge.isNew)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(AppLocalizations.of(context)!.newBadge,
                          style: tt.labelSmall?.copyWith(
                              color: cs.onPrimary,
                              fontSize: 8,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            AppSpacing.vGap4,
            // Title
            Text(badge.title,
                style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLocked ? cs.onSurfaceVariant : cs.onSurface),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            // Description
            Text(badge.description,
                style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant, fontSize: 9),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            // Date or Progress
            if (badge.status == BadgeStatus.earned && badge.earnedAt != null)
              Text(_formatDate(badge.earnedAt!),
                  style: tt.labelSmall
                      ?.copyWith(color: cs.outline, fontSize: 9)),
            if (isInProgress || isLocked) ...[
              AppSpacing.vGap4,
              _MiniProgressBar(
                  percent: badge.progressPercent, color: displayColor),
              Text('${(badge.progressPercent * 100).round()}%',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _HexagonBadge extends StatelessWidget {
  const _HexagonBadge({
    required this.icon,
    required this.color,
    required this.isLocked,
    required this.isInProgress,
  });

  final IconData icon;
  final Color color;
  final bool isLocked;
  final bool isInProgress;

  @override
  Widget build(BuildContext context) {
    final displayColor =
        isLocked ? color : (isInProgress ? color.withValues(alpha: 0.7) : color);

    return CustomPaint(
      painter: _HexagonPainter(color: displayColor, isLocked: isLocked),
      child: SizedBox(
        width: 56,
        height: 64,
        child: Center(
          child: Icon(icon,
              size: 24, color: isLocked ? Colors.white54 : Colors.white),
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  _HexagonPainter({required this.color, required this.isLocked});

  final Color color;
  final bool isLocked;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createHexagonPath(size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = isLocked ? color : color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    // Hexagon pointing up
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniProgressBar extends StatelessWidget {
  const _MiniProgressBar({required this.percent, required this.color});

  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: percent,
          backgroundColor: cs.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}

// ============================================================
// FILTER BOTTOM SHEET
// ============================================================
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vGap16,
          Text(l10n.filter,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.vGap24,
          Text(l10n.status, style: tt.titleSmall),
          AppSpacing.vGap12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterOption(
                  label: l10n.all,
                  isSelected: _selectedStatus == 'all',
                  onTap: () => setState(() => _selectedStatus = 'all')),
              _FilterOption(
                  label: l10n.earned,
                  isSelected: _selectedStatus == 'earned',
                  onTap: () => setState(() => _selectedStatus = 'earned')),
              _FilterOption(
                  label: l10n.inProgress,
                  isSelected: _selectedStatus == 'inProgress',
                  onTap: () => setState(() => _selectedStatus = 'inProgress')),
              _FilterOption(
                  label: l10n.notEarned,
                  isSelected: _selectedStatus == 'locked',
                  onTap: () => setState(() => _selectedStatus = 'locked')),
            ],
          ),
          AppSpacing.vGap24,
          Text(l10n.category, style: tt.titleSmall),
          AppSpacing.vGap12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterOption(
                  label: l10n.all,
                  isSelected: _selectedCategory == 'all',
                  onTap: () => setState(() => _selectedCategory = 'all')),
              _FilterOption(
                  label: l10n.learning,
                  isSelected: _selectedCategory == 'learning',
                  onTap: () => setState(() => _selectedCategory = 'learning')),
              _FilterOption(
                  label: l10n.habit,
                  isSelected: _selectedCategory == 'habit',
                  onTap: () => setState(() => _selectedCategory = 'habit')),
              _FilterOption(
                  label: l10n.achievement,
                  isSelected: _selectedCategory == 'achievement',
                  onTap: () =>
                      setState(() => _selectedCategory = 'achievement')),
            ],
          ),
          AppSpacing.vGap32,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.apply),
            ),
          ),
          AppSpacing.vGap16,
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, size: 16, color: cs.onPrimary),
              AppSpacing.hGap4,
            ],
            Text(label,
                style: tt.labelMedium?.copyWith(
                    color: isSelected ? cs.onPrimary : cs.onSurface)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BADGE DETAIL BOTTOM SHEET
// ============================================================
class _BadgeDetailSheet extends StatelessWidget {
  const _BadgeDetailSheet({required this.badge});

  final AchievementBadgeData badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isLocked = badge.status == BadgeStatus.locked;
    final isInProgress = badge.status == BadgeStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vGap24,
          _HexagonBadge(
            icon: badge.icon,
            color: isLocked ? cs.outlineVariant : badge.color,
            isLocked: isLocked,
            isInProgress: isInProgress,
          ),
          AppSpacing.vGap16,
          Text(badge.title,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          AppSpacing.vGap8,
          Text(badge.description,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center),
          AppSpacing.vGap16,
          if (badge.status == BadgeStatus.earned && badge.earnedAt != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                  '${l10n.earned}: ${badge.earnedAt!.day}/${badge.earnedAt!.month}/${badge.earnedAt!.year}',
                  style: tt.labelMedium?.copyWith(color: cs.primary)),
            ),
          if (isInProgress) ...[
            AppSpacing.vGap8,
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: badge.progressPercent,
                      minHeight: 8,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(badge.color),
                    ),
                  ),
                  AppSpacing.vGap8,
                  Text(
                      '${badge.progress} / ${badge.target} (${(badge.progressPercent * 100).round()}%)',
                      style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
          if (isLocked) ...[
            AppSpacing.vGap8,
            Text('${badge.target - badge.progress} ${l10n.inProgress}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
          AppSpacing.vGap24,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ),
          AppSpacing.vGap16,
        ],
      ),
    );
  }
}
