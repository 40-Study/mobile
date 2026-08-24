import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_event.dart';
import 'package:study/features/student/bloc/achievement/achievement_state.dart';
import 'package:study/features/student/data/models/badge_model.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/features/student/presentation/achievement/all_achievements_screen.dart';
import 'package:study/features/student/presentation/achievement/all_certificates_screen.dart';
import 'package:study/features/student/presentation/achievement/certificate_detail_screen.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/app_header_bar.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementBloc>().add(const AchievementStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppHeaderBar(
        title: AppLocalizations.of(context)!.achievementTitle,
        showNotification: false,
        backgroundColor: cs.surface,
      ),
      body: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            return switch (state) {
              AchievementInitial() || AchievementInProgress() => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              AchievementFailure(:final message) => Center(child: Text(message)),
              AchievementSuccess() => _buildContent(context, state),
            };
          },
        ),
    );
  }

  Widget _buildContent(BuildContext context, AchievementSuccess state) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        _OverviewStatistics(stats: state.stats),
        AppSpacing.vGap24,
        _RecentBadges(badges: state.earnedBadges),
        AppSpacing.vGap24,
        if (state.certificates.isNotEmpty) ...[
          _CertificateCarousel(certificates: state.certificates),
          AppSpacing.vGap24,
        ],
        const _ContributionGrid(),
        AppSpacing.vGap24,
        _LearningTrendChart(stats: state.stats),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ============================================================
// RECENT BADGES
// ============================================================
class _RecentBadges extends StatelessWidget {
  const _RecentBadges({required this.badges});

  final List<BadgeModel> badges;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.recentBadges,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AllAchievementsScreen()),
              ),
              child: Text(l10n.viewAll,
                  style: tt.labelLarge?.copyWith(
                      color: cs.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        AppSpacing.vGap16,
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.take(4).length,
            separatorBuilder: (_, _) => AppSpacing.hGap12,
            itemBuilder: (context, i) => _BadgeItem(
              badge: badges[i],
              isNew: i == 0,
              colorIndex: i,
            ),
          ),
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  const _BadgeItem({
    required this.badge,
    this.isNew = false,
    required this.colorIndex,
  });

  final BadgeModel badge;
  final bool isNew;
  final int colorIndex;

  static const _badgeConfigs = [
    (color: AchievementColors.purple, icon: Icons.menu_book_rounded),
    (color: AchievementColors.deepOrange, icon: Icons.star_rounded),
    (color: AchievementColors.teal, icon: Icons.track_changes_rounded),
    (color: AchievementColors.red, icon: Icons.local_fire_department_rounded),
    (color: AchievementColors.blue, icon: Icons.workspace_premium_rounded),
    (color: AchievementColors.green, icon: Icons.emoji_events_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final config = _badgeConfigs[colorIndex % _badgeConfigs.length];

    return GestureDetector(
      onTap: () => _showBadgeDetail(context, config.color, config.icon),
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: config.color, width: 2),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: config.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(config.icon, size: 28, color: Colors.white),
                  ),
                ),
                if (isNew)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: cs.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                      child:
                          const Icon(Icons.add, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            AppSpacing.vGap8,
            Text(badge.name,
                style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(badge.description ?? '',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (badge.earnedAt != null)
              Text(_formatDate(badge.earnedAt!),
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, Color color, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 44, color: Colors.white),
                ),
              ),
              AppSpacing.vGap16,
              Text(badge.name,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              AppSpacing.vGap8,
              Text(badge.description ?? 'Chưa có mô tả',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center),
              if (badge.earnedAt != null) ...[
                AppSpacing.vGap16,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text('${l10n.earned}: ${_formatDate(badge.earnedAt!)}',
                      style: tt.labelMedium?.copyWith(color: cs.primary)),
                ),
              ],
              AppSpacing.vGap24,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ============================================================
// CERTIFICATE CAROUSEL
// ============================================================
class _CertificateCarousel extends StatefulWidget {
  const _CertificateCarousel({required this.certificates});

  final List<CertificateModel> certificates;

  @override
  State<_CertificateCarousel> createState() => _CertificateCarouselState();
}

class _CertificateCarouselState extends State<_CertificateCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            Text(l10n.yourCertificates,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AllCertificatesScreen()),
              ),
              child: Text(l10n.viewAll,
                  style: tt.labelLarge
                      ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        AppSpacing.vGap16,
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.certificates.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _CertificateCard(
                certificate: widget.certificates[i],
                colorIndex: i,
              ),
            ),
          ),
        ),
        AppSpacing.vGap12,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.certificates.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == _currentPage ? 8 : 6,
              height: i == _currentPage ? 8 : 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _currentPage ? cs.primary : cs.outlineVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate, required this.colorIndex});

  final CertificateModel certificate;
  final int colorIndex;

  static const _accentColors = [
    AchievementColors.purple,
    AchievementColors.teal,
    AchievementColors.blue,
    AchievementColors.deepOrange,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = _accentColors[colorIndex % _accentColors.length];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CertificateDetailScreen(certificate: certificate),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CERTIFICATE',
                      style: tt.labelMedium?.copyWith(
                          color: accent,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700)),
                  Text('OF COMPLETION',
                      style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant, letterSpacing: 0.5)),
                ],
              ),
              const Spacer(),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
          AppSpacing.vGap12,
          Text(certificate.courseTitle ?? '',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Completed on',
                      style: tt.labelSmall?.copyWith(color: cs.outline)),
                  Text(_formatDate(certificate.issueDate),
                      style: tt.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const Spacer(),
              Text(certificate.instructorName ?? '',
                  style: tt.labelMedium?.copyWith(
                      fontStyle: FontStyle.italic, color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ============================================================
// OVERVIEW STATISTICS
// ============================================================
class _OverviewStatistics extends StatelessWidget {
  const _OverviewStatistics({required this.stats});

  final StudentStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.overview,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.vGap16,
          Row(
            children: [
              _StatItem(
                icon: Icons.access_time_rounded,
                value: '${stats.totalStudyHours.toInt()}',
                label: l10n.studyHours,
                color: cs.primary,
              ),
              _divider(cs),
              _StatItem(
                icon: Icons.menu_book_rounded,
                value: '${stats.completedLessons}',
                label: l10n.completedLessons,
                color: AchievementColors.orange,
              ),
              _divider(cs),
              _StatItem(
                icon: Icons.emoji_events_rounded,
                value: '18',
                label: l10n.badges,
                color: AchievementColors.green,
              ),
              _divider(cs),
              _StatItem(
                icon: Icons.local_fire_department_rounded,
                value: '${stats.streakDays}',
                label: l10n.streak,
                color: AchievementColors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider(ColorScheme cs) {
    return Container(width: 1, height: 50, color: cs.outlineVariant);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          AppSpacing.vGap8,
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
            duration: const Duration(milliseconds: 800),
            builder: (context, val, _) => Text('$val',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
          Text(label,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 2),
          AppSpacing.vGap4,
          _MiniSparkline(color: color),
        ],
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 16),
      painter: _SparklinePainter(color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final data = [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75];
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final step = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height * (1 - data[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// GITHUB-STYLE CONTRIBUTION GRID
// ============================================================
class _ContributionGrid extends StatelessWidget {
  const _ContributionGrid();

  static const _weeks = 12;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final contributions = _generateContributions();
    final totalDays = contributions.where((l) => l > 0).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.learningActivity,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(l10n.daysLearned(totalDays),
                    style: tt.labelMedium?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          AppSpacing.vGap16,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 2),
                          _dayLabel('', tt, cs),
                          _dayLabel('T2', tt, cs),
                          _dayLabel('', tt, cs),
                          _dayLabel('T4', tt, cs),
                          _dayLabel('', tt, cs),
                          _dayLabel('T6', tt, cs),
                          _dayLabel('', tt, cs),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellSize =
                              (constraints.maxWidth - (_weeks - 1) * 3) / _weeks;
                          final size = cellSize.clamp(12.0, 18.0);

                          return Column(
                            children: [
                              ...List.generate(7, (dayIndex) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(_weeks, (weekIndex) {
                                      final index = weekIndex * 7 + dayIndex;
                                      final level = index < contributions.length
                                          ? contributions[index]
                                          : 0;
                                      return _Cell(level: level, size: size, cs: cs);
                                    }),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.vGap12,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.less, style: tt.labelSmall?.copyWith(color: cs.onSurface)),
              AppSpacing.hGap8,
              ...List.generate(
                  5,
                  (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _Cell(level: i, size: 14, cs: cs),
                      )),
              AppSpacing.hGap8,
              Text(l10n.more, style: tt.labelSmall?.copyWith(color: cs.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayLabel(String text, TextTheme tt, ColorScheme cs) {
    return SizedBox(
      height: 17,
      child: text.isEmpty
          ? null
          : Text(text, style: tt.labelSmall?.copyWith(color: cs.onSurface)),
    );
  }

  List<int> _generateContributions() {
    final random = DateTime.now().day;
    return List.generate(_weeks * 7, (i) {
      final seed = (random * 7 + i * 13) % 100;
      if (seed < 20) return 0;
      if (seed < 40) return 1;
      if (seed < 60) return 2;
      if (seed < 80) return 3;
      return 4;
    });
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.level, required this.size, required this.cs});

  final int level;
  final double size;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final colors = [
      cs.surfaceContainerHighest,
      cs.primary.withValues(alpha: 0.2),
      cs.primary.withValues(alpha: 0.4),
      cs.primary.withValues(alpha: 0.6),
      cs.primary,
    ];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors[level.clamp(0, 4)],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ============================================================
// LEARNING TREND CHART
// ============================================================
class _LearningTrendChart extends StatelessWidget {
  const _LearningTrendChart({required this.stats});

  final StudentStatsModel stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final data = stats.weeklyStudyHours ?? [30, 45, 60, 50, 80, 105, 70];
    final maxVal = data.isEmpty ? 120.0 : data.reduce(math.max);
    final yMax = ((maxVal / 30).ceil() * 30).toDouble().clamp(60.0, 150.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.learningTrend,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.last7Days,
                        style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                    AppSpacing.hGap4,
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGap24,
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _yLabel('${yMax.toInt()} ${l10n.minutes}', tt, cs),
                    _yLabel('${(yMax * 0.5).toInt()} ${l10n.minutes}', tt, cs),
                    _yLabel('0 ${l10n.minutes}', tt, cs),
                  ],
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: CustomPaint(
                    size: const Size(double.infinity, 160),
                    painter: _LineChartPainter(
                        data: data, maxValue: yMax, color: cs.primary),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGap12,
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                  .map((d) =>
                      Text(d, style: tt.labelSmall?.copyWith(color: cs.onSurface)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _yLabel(String text, TextTheme tt, ColorScheme cs) {
    return Text(text, style: tt.labelSmall?.copyWith(color: cs.onSurface));
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.color,
  });

  final List<double> data;
  final double maxValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (data.isEmpty) return;

    final step = size.width / (data.length - 1);
    final points = <Offset>[];

    for (var i = 0; i < data.length; i++) {
      final x = i * step;
      final y = size.height * (1 - data[i] / maxValue);
      points.add(Offset(x, y.clamp(0, size.height)));
    }

    // Gradient fill
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Points
    final pointPaint = Paint()..color = color;
    final pointBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 4, pointPaint);
      canvas.drawCircle(p, 4, pointBorder);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
