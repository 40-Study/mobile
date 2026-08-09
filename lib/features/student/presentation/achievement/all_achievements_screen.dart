import 'dart:math' as math;
import 'package:flutter/material.dart';
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
  const AllAchievementsScreen({super.key});

  @override
  State<AllAchievementsScreen> createState() => _AllAchievementsScreenState();
}

class _AllAchievementsScreenState extends State<AllAchievementsScreen> {
  BadgeCategory _selectedCategory = BadgeCategory.all;

  // Mock data
  late final List<AchievementBadgeData> _allBadges = _generateMockBadges();

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

            SliverToBoxAdapter(child: AppSpacing.vGap24),

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
              SliverToBoxAdapter(child: AppSpacing.vGap32),
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
              SliverToBoxAdapter(child: AppSpacing.vGap32),
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

  List<AchievementBadgeData> _generateMockBadges() {
    return [
      // Earned badges
      AchievementBadgeData(
        id: '1',
        title: 'Học tập chăm chỉ',
        description: 'Học 7 ngày liên tiếp',
        status: BadgeStatus.earned,
        category: BadgeCategory.habit,
        icon: Icons.menu_book_rounded,
        color: AchievementColors.purple,
        earnedAt: DateTime(2024, 5, 5),
        isNew: true,
      ),
      AchievementBadgeData(
        id: '2',
        title: 'Người chinh phục',
        description: 'Hoàn thành 10 bài học',
        status: BadgeStatus.earned,
        category: BadgeCategory.learning,
        icon: Icons.star_rounded,
        color: AchievementColors.orange,
        earnedAt: DateTime(2024, 5, 3),
      ),
      AchievementBadgeData(
        id: '3',
        title: 'Tập trung cao độ',
        description: 'Học 120 phút/ngày',
        status: BadgeStatus.earned,
        category: BadgeCategory.habit,
        icon: Icons.track_changes_rounded,
        color: AchievementColors.green,
        earnedAt: DateTime(2024, 5, 2),
      ),
      AchievementBadgeData(
        id: '4',
        title: 'Lửa đam mê',
        description: 'Học 30 ngày liên tiếp',
        status: BadgeStatus.earned,
        category: BadgeCategory.habit,
        icon: Icons.local_fire_department_rounded,
        color: AchievementColors.blue,
        earnedAt: DateTime(2024, 4, 30),
      ),
      AchievementBadgeData(
        id: '5',
        title: 'Tăng tốc',
        description: 'Hoàn thành 5 bài học trong 1 ngày',
        status: BadgeStatus.earned,
        category: BadgeCategory.achievement,
        icon: Icons.bolt_rounded,
        color: AchievementColors.violet,
        earnedAt: DateTime(2024, 4, 28),
      ),
      AchievementBadgeData(
        id: '6',
        title: 'Kiên trì bền bỉ',
        description: 'Học 15 ngày liên tiếp',
        status: BadgeStatus.earned,
        category: BadgeCategory.habit,
        icon: Icons.workspace_premium_rounded,
        color: AchievementColors.deepOrange,
        earnedAt: DateTime(2024, 4, 25),
      ),
      AchievementBadgeData(
        id: '7',
        title: 'Quản lý thời gian',
        description: 'Học đúng giờ 10 lần',
        status: BadgeStatus.earned,
        category: BadgeCategory.habit,
        icon: Icons.schedule_rounded,
        color: AchievementColors.lightBlue,
        earnedAt: DateTime(2024, 4, 22),
      ),
      AchievementBadgeData(
        id: '8',
        title: 'Giúp đỡ bạn bè',
        description: 'Trả lời 3 câu hỏi trong thảo luận',
        status: BadgeStatus.earned,
        category: BadgeCategory.achievement,
        icon: Icons.favorite_rounded,
        color: AchievementColors.pink,
        earnedAt: DateTime(2024, 4, 20),
      ),
      // More earned
      ...List.generate(10, (i) {
        final icons = [
          Icons.school_rounded,
          Icons.lightbulb_rounded,
          Icons.psychology_rounded,
          Icons.auto_awesome_rounded,
          Icons.rocket_launch_rounded,
        ];
        final colors = [
          AchievementColors.purple,
          AchievementColors.green,
          AchievementColors.blue,
          AchievementColors.orange,
          AchievementColors.pink,
        ];
        return AchievementBadgeData(
          id: 'e${i + 9}',
          title: 'Thành tích ${i + 9}',
          description: 'Mô tả thành tích ${i + 9}',
          status: BadgeStatus.earned,
          category: BadgeCategory.values[(i % 3) + 1],
          icon: icons[i % icons.length],
          color: colors[i % colors.length],
          earnedAt: DateTime(2024, 4, 15 - i),
        );
      }),

      // In progress badges
      AchievementBadgeData(
        id: 'p1',
        title: 'Thảo luận tích cực',
        description: 'Tham gia thảo luận 10 lần',
        status: BadgeStatus.inProgress,
        category: BadgeCategory.achievement,
        icon: Icons.chat_bubble_rounded,
        color: AchievementColors.purple,
        progress: 6,
        target: 10,
      ),
      AchievementBadgeData(
        id: 'p2',
        title: 'Hoàn thành bài tập',
        description: 'Nộp 5 bài tập',
        status: BadgeStatus.inProgress,
        category: BadgeCategory.learning,
        icon: Icons.edit_note_rounded,
        color: AchievementColors.deepOrange,
        progress: 2,
        target: 5,
      ),
      AchievementBadgeData(
        id: 'p3',
        title: 'Học qua video',
        description: 'Xem 20 video',
        status: BadgeStatus.inProgress,
        category: BadgeCategory.learning,
        icon: Icons.play_circle_rounded,
        color: AchievementColors.red,
        progress: 14,
        target: 20,
      ),
      AchievementBadgeData(
        id: 'p4',
        title: 'Duy trì đều đặn',
        description: 'Học 60 ngày liên tiếp',
        status: BadgeStatus.inProgress,
        category: BadgeCategory.habit,
        icon: Icons.grid_view_rounded,
        color: AchievementColors.violet,
        progress: 18,
        target: 60,
      ),
      ...List.generate(6, (i) {
        final icons = [
          Icons.quiz_rounded,
          Icons.trending_up_rounded,
          Icons.workspace_premium_rounded,
          Icons.auto_graph_rounded,
          Icons.emoji_events_rounded,
          Icons.military_tech_rounded,
        ];
        final colors = [
          AchievementColors.lightBlue,
          AchievementColors.green,
          AchievementColors.orange,
          AchievementColors.blue,
          AchievementColors.pink,
          AchievementColors.purple,
        ];
        return AchievementBadgeData(
          id: 'p${i + 5}',
          title: 'Tiến độ ${i + 5}',
          description: 'Mục tiêu ${i + 5}',
          status: BadgeStatus.inProgress,
          category: BadgeCategory.values[(i % 3) + 1],
          icon: icons[i % icons.length],
          color: colors[i % colors.length],
          progress: (i + 1) * 10,
          target: 100,
        );
      }),

      // Locked badges
      AchievementBadgeData(
        id: 'l1',
        title: 'Chuyên gia',
        description: 'Hoàn thành 50 bài học',
        status: BadgeStatus.locked,
        category: BadgeCategory.learning,
        icon: Icons.school_rounded,
        color: AchievementColors.purple,
        progress: 0,
        target: 50,
      ),
      AchievementBadgeData(
        id: 'l2',
        title: 'Xuất sắc',
        description: 'Đạt 100% trong 10 bài kiểm tra',
        status: BadgeStatus.locked,
        category: BadgeCategory.achievement,
        icon: Icons.workspace_premium_rounded,
        color: AchievementColors.orange,
        progress: 0,
        target: 10,
      ),
      AchievementBadgeData(
        id: 'l3',
        title: 'Bậc thầy',
        description: 'Hoàn thành 1 khóa học nâng cao',
        status: BadgeStatus.locked,
        category: BadgeCategory.learning,
        icon: Icons.diamond_rounded,
        color: AchievementColors.lightBlue,
        progress: 0,
        target: 1,
      ),
      AchievementBadgeData(
        id: 'l4',
        title: 'Thành tựu lớn',
        description: 'Hoàn thành 5 khóa học',
        status: BadgeStatus.locked,
        category: BadgeCategory.achievement,
        icon: Icons.key_rounded,
        color: AchievementColors.pink,
        progress: 0,
        target: 5,
      ),
      ...List.generate(4, (i) {
        final icons = [
          Icons.military_tech_rounded,
          Icons.stars_rounded,
          Icons.verified_rounded,
          Icons.shield_rounded,
        ];
        final colors = [
          AchievementColors.purple,
          AchievementColors.green,
          AchievementColors.blue,
          AchievementColors.orange,
        ];
        return AchievementBadgeData(
          id: 'l${i + 5}',
          title: 'Mục tiêu ${i + 5}',
          description: 'Yêu cầu ${i + 5}',
          status: BadgeStatus.locked,
          category: BadgeCategory.values[(i % 3) + 1],
          icon: icons[i % icons.length],
          color: colors[i % colors.length],
          progress: 0,
          target: 100,
        );
      }),
    ];
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
