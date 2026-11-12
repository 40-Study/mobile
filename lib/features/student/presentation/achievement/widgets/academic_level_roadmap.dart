import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/theme/theme.dart';

/// Dữ liệu tính toán toán học phân rã Điểm kinh nghiệm & Cấp độ học thuật
/// Chuẩn hóa 100% Client-side dựa trên quy ước 500 XP / Level của hệ thống
class LevelProgressData {
  const LevelProgressData({
    required this.currentLevel,
    required this.totalXp,
    required this.levelBaseXp,
    required this.nextLevelBaseXp,
    required this.currentLevelXp,
    required this.xpNeededForNext,
    required this.progressRatio,
    required this.progressPercent,
  });

  final int currentLevel;
  final int totalXp;
  final int levelBaseXp;
  final int nextLevelBaseXp;
  final int currentLevelXp;
  final int xpNeededForNext;
  final double progressRatio;
  final int progressPercent;

  static const int xpPerLevel = 500;

  factory LevelProgressData.fromStats(StudentStatsModel stats) {
    final totalXp = stats.currentXp.clamp(0, 9999999);
    final computedLevel = (totalXp ~/ xpPerLevel) + 1;
    final currentLevel = stats.level > 0 ? stats.level : computedLevel;

    final levelBaseXp = (currentLevel - 1) * xpPerLevel;
    final nextLevelBaseXp = currentLevel * xpPerLevel;
    final currentLevelXp = (totalXp - levelBaseXp).clamp(0, xpPerLevel);
    final xpNeededForNext = (xpPerLevel - currentLevelXp).clamp(0, xpPerLevel);
    final progressRatio = (currentLevelXp / xpPerLevel.toDouble()).clamp(0.0, 1.0);
    final progressPercent = (progressRatio * 100).toInt();

    return LevelProgressData(
      currentLevel: currentLevel,
      totalXp: totalXp,
      levelBaseXp: levelBaseXp,
      nextLevelBaseXp: nextLevelBaseXp,
      currentLevelXp: currentLevelXp,
      xpNeededForNext: xpNeededForNext,
      progressRatio: progressRatio,
      progressPercent: progressPercent,
    );
  }

  /// Danh hiệu học thuật đầy đủ
  static String resolveAcademicTitle(int level) {
    if (level <= 1) return 'Tân Khoa Nhập Môn';
    if (level <= 2) return 'Tân Khoa Tinh Thông';
    if (level <= 3) return 'Học Giả Tiến Bộ';
    if (level <= 4) return 'Học Giả Vững Vàng';
    if (level <= 5) return 'Học Giả Tinh Hoa';
    if (level <= 6) return 'Học Viện Danh Dự';
    if (level <= 7) return 'Học Sĩ Uyên Bác';
    if (level <= 8) return 'Học Sĩ Tinh Thông';
    return 'Đại Học Sĩ ForteX';
  }

  /// Danh xưng rút gọn cho Node bản đồ
  static String resolveShortTitle(int level) {
    if (level <= 1) return 'Tân Khoa';
    if (level <= 2) return 'Tinh Thông';
    if (level <= 3) return 'Tiến Bộ';
    if (level <= 4) return 'Vững Vàng';
    if (level <= 5) return 'Tinh Hoa';
    if (level <= 6) return 'Danh Dự';
    if (level <= 7) return 'Uyên Bác';
    return 'Học Sĩ';
  }
}

/// Thông tin 1 Waypoint trên Bản đồ Con đường Tiến hóa Cấp bậc
class _RoadmapWaypoint {
  const _RoadmapWaypoint({
    required this.level,
    required this.title,
    required this.isCompleted,
    required this.isActive,
    required this.isLocked,
  });

  final int level;
  final String title;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;
}

/// Bản Đồ Tiến Hóa Cấp Bậc - The RPG Level Roadmap V4.0
///
/// Bố cục 3 Tầng Tích hợp Không Card (Zero-Card Seamless Architecture):
/// - Tầng 1: The Progression Track - Dải bản đồ cấp độ ngang với sóng năng lượng chạy
/// - Tầng 2: The Hero Zenith Core - Huy chương mạ vàng 3D, hào quang thở 3 tầng, điểm XP to bản & thanh thủy dịch
/// - Tầng 3: The Satellite Metric Pods - 3 Capsule Pods xúc giác độc lập (Streak, Giờ học, Bài học)
class AcademicLevelRoadmap extends StatefulWidget {
  const AcademicLevelRoadmap({
    super.key,
    required this.stats,
    this.earnedBadgesCount,
    this.totalBadgesCount,
    this.enableAnimation = true,
  });

  final StudentStatsModel stats;
  final int? earnedBadgesCount;
  final int? totalBadgesCount;
  final bool enableAnimation;

  @override
  State<AcademicLevelRoadmap> createState() => _AcademicLevelRoadmapState();
}

class _AcademicLevelRoadmapState extends State<AcademicLevelRoadmap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _shimmerAnimation;
  late final Animation<double> _sparkleAnimation;
  late final Animation<double> _pulseLockAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Hào quang thở hình sin (Breathing Corona: 0.15 -> 0.85)
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    // Dải sáng Shimmer trôi ngang (0.0 -> 1.0)
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // Hạt sao xoay & nhấp nháy lấp lánh (Twinkle Glints)
    _sparkleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Ổ khóa hé mở mờ ảo nhịp nhàng (Pulsing Lock Aurora)
    _pulseLockAnimation = Tween<double>(begin: 0.25, end: 0.75).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enableAnimation) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final progress = LevelProgressData.fromStats(widget.stats);
    final badgesCount = widget.earnedBadgesCount ?? 0;

    // Tạo danh sách 5 mốc Waypoint quanh Level hiện tại
    final waypoints = _generateWaypoints(progress.currentLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // HEADER MỞ THOÁNG: TIÊU ĐỀ HÀNH TRÌNH (SEAMLESS SECTION HEADER)
          // ═══════════════════════════════════════════════════════════════════
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HÀNH TRÌNH HỌC THUẬT',
                      style: TextStyle(
                        color: cs.brandBlueDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bản Đồ Tiến Hóa Cấp Bậc',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: cs.slate900,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chip trạng thái hoạt động
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.3)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF059669).withValues(alpha: 0.5)
                        : const Color(0xFF6EE7B7),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF059669),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Đang diễn ra',
                      style: tt.labelSmall?.copyWith(
                        color: isDark
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFF047857),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ═══════════════════════════════════════════════════════════════════
          // KHAY NỀN DANH DỰ KHÍ QUYỂN (THE AMBIENT HONOR CANVAS)
          // Tôn vinh đẳng cấp Light Mode với Gradient hoàng kim & Đổ bóng hổ phách
          // Bảo tồn 100% vẻ đẹp huyền bí của Dark Mode
          // ═══════════════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            decoration: BoxDecoration(
              gradient: isDark
                  ? null
                  : const LinearGradient(
                      colors: [
                        Colors.white,
                        Color(0xFFFFFDF5),
                        Color(0xFFFEF3C7),
                        Color(0xFFF0FDF4),
                      ],
                      stops: [0.0, 0.40, 0.75, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              color: isDark ? cs.slate900.withValues(alpha: 0.35) : null,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? cs.slate800
                    : const Color(0xFFFDE68A).withValues(alpha: 0.70),
                width: 0.8,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFFD97706).withValues(alpha: 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              children: [
                // ─────────────────────────────────────────────────────────────
                // TẦNG 1: THE PROGRESSION TRACK (DẢI BẢN ĐỒ CẤP ĐỘ NGANG)
                // ─────────────────────────────────────────────────────────────
                _RoadmapPathBar(
                  waypoints: waypoints,
                  shimmerValue: widget.enableAnimation ? _shimmerAnimation.value : 0.5,
                  pulseLockValue: widget.enableAnimation ? _pulseLockAnimation.value : 0.5,
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // ─────────────────────────────────────────────────────────────
                // TẦNG 2: THE HERO ZENITH CORE (TRỌNG TÂM VINH DANH QUYỀN NĂNG)
                // ─────────────────────────────────────────────────────────────
                _HeroZenithEmblem(
                  progress: progress,
                  badgesCount: badgesCount,
                  glowAnimation: _glowAnimation,
                  shimmerAnimation: _shimmerAnimation,
                  sparkleAnimation: _sparkleAnimation,
                  enableAnimation: widget.enableAnimation,
                  isDark: isDark,
                ),

                const SizedBox(height: 18),

                // ─────────────────────────────────────────────────────────────
                // TẦNG 3: THE SATELLITE METRIC PODS (VÀNH ĐAI CHỈ SỐ VỆ TINH)
                // ─────────────────────────────────────────────────────────────
                _SatellitePodsRow(
                  stats: widget.stats,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sinh danh sách 5 Waypoint quanh Level hiện tại
  List<_RoadmapWaypoint> _generateWaypoints(int currentLevel) {
    // Nếu Level <= 4: Hiển thị mốc cố định từ Lv.1 đến Lv.5
    // Nếu Level > 4: Hiển thị trượt [current-3, current-2, current-1, current, current+1]
    final startLevel = currentLevel <= 4 ? 1 : (currentLevel - 3);
    final list = <_RoadmapWaypoint>[];

    for (int i = 0; i < 5; i++) {
      final lvl = startLevel + i;
      final isCompleted = lvl < currentLevel;
      final isActive = lvl == currentLevel;
      final isLocked = lvl > currentLevel;

      list.add(
        _RoadmapWaypoint(
          level: lvl,
          title: LevelProgressData.resolveShortTitle(lvl),
          isCompleted: isCompleted,
          isActive: isActive,
          isLocked: isLocked,
        ),
      );
    }

    return list;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TẦNG 1: WIDGET DẢI ĐƯỜNG RAY CẤP ĐỘ NGANG (THE PROGRESSION TRACK)
// ─────────────────────────────────────────────────────────────────────────────
class _RoadmapPathBar extends StatelessWidget {
  const _RoadmapPathBar({
    required this.waypoints,
    required this.shimmerValue,
    required this.pulseLockValue,
    required this.isDark,
  });

  final List<_RoadmapWaypoint> waypoints;
  final double shimmerValue;
  final double pulseLockValue;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Đảm bảo không gian rộng rãi (tối thiểu 420px) cho 5 trạm cấp độ thở
        // Khi màn hình hẹp, thanh bản đồ cho phép lướt ngang mượt mà chuẩn RPG map
        final totalWidth = math.max(constraints.maxWidth, 420.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: SizedBox(
            width: totalWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  for (int i = 0; i < waypoints.length; i++) ...[
                    // Node Waypoint
                    _buildWaypointNode(context, waypoints[i]),

                    // Đường nối giữa 2 Node liên tiếp (nếu chưa phải node cuối)
                    if (i < waypoints.length - 1)
                      Expanded(
                        child: _buildConnectingTrack(
                          isCompleted: waypoints[i].isCompleted &&
                                  waypoints[i + 1].isCompleted ||
                              (waypoints[i].isCompleted &&
                                  waypoints[i + 1].isActive),
                          isActiveToNext:
                              waypoints[i].isActive && waypoints[i + 1].isLocked,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaypointNode(BuildContext context, _RoadmapWaypoint wp) {
    final cs = Theme.of(context).colorScheme;

    if (wp.isActive) {
      // MỐC HIỆN TẠI: Squircle Active rực sáng
      return GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFD97706),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Lv.${wp.level}',
              style: TextStyle(
                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
            Text(
              wp.title,
              style: TextStyle(
                color: cs.slate900,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );
    }

    if (wp.isCompleted) {
      // MỐC ĐÃ QUA: Huy hiệu mạ vàng nhỏ với Checkmark
      // Color grading đạt chuẩn WCAG AAA trên nền sáng
      return GestureDetector(
        onTap: () => HapticFeedback.selectionClick(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF78350F).withValues(alpha: 0.3)
                    : const Color(0xFFFEF3C7),
                border: Border.all(
                  color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706),
                  width: 1.4,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: Color(0xFFB45309),
                  size: 15,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Lv.${wp.level}',
              style: TextStyle(
                color: isDark ? cs.slate500 : const Color(0xFF92400E),
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
            ),
            Text(
              wp.title,
              style: TextStyle(
                color: isDark ? cs.slate500 : const Color(0xFF92400E),
                fontWeight: FontWeight.w700,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      );
    }

    // MỐC TƯƠNG LAI: Ổ khóa hé mở ánh hào quang huyền bí
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(
                  alpha: 0.2 + (pulseLockValue * 0.4),
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(
                    alpha: 0.15 * pulseLockValue,
                  ),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.lock_outline_rounded,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                size: 14,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Lv.${wp.level}',
            style: TextStyle(
              color: cs.slate400,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
          Text(
            wp.title,
            style: TextStyle(
              color: cs.slate400,
              fontWeight: FontWeight.w600,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Đường nối giữa các Node
  Widget _buildConnectingTrack({
    required bool isCompleted,
    required bool isActiveToNext,
  }) {
    if (isCompleted) {
      // ĐOẠN ĐÃ QUA: Nét liền vàng óng với vệt sóng ánh sáng năng lượng chạy qua
      return Container(
        height: 2.8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1.4),
          gradient: LinearGradient(
            colors: const [
              Color(0xFFF59E0B),
              Color(0xFFFEF3C7),
              Color(0xFFF59E0B),
            ],
            stops: [
              (shimmerValue - 0.25).clamp(0.0, 1.0),
              shimmerValue.clamp(0.0, 1.0),
              (shimmerValue + 0.25).clamp(0.0, 1.0),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              blurRadius: 3,
            ),
          ],
        ),
      );
    }

    // ĐOẠN TỚI TƯƠNG LAI: Nét đứt (Dashed line) thanh lịch
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 3.5;
          const dashSpace = 2.5;
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor().clamp(1, 20);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: 1.8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TẦNG 2: WIDGET HERO VINH DANH TRUNG TÂM (THE HERO ZENITH CORE)
// ─────────────────────────────────────────────────────────────────────────────
class _HeroZenithEmblem extends StatelessWidget {
  const _HeroZenithEmblem({
    required this.progress,
    required this.badgesCount,
    required this.glowAnimation,
    required this.shimmerAnimation,
    required this.sparkleAnimation,
    required this.enableAnimation,
    required this.isDark,
  });

  final LevelProgressData progress;
  final int badgesCount;
  final Animation<double> glowAnimation;
  final Animation<double> shimmerAnimation;
  final Animation<double> sparkleAnimation;
  final bool enableAnimation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final currentTitle = LevelProgressData.resolveAcademicTitle(progress.currentLevel);
    final nextTitle = LevelProgressData.resolveAcademicTitle(progress.currentLevel + 1);

    return Column(
      children: [
        // ─────────────────────────────────────────────────────────
        // 1. HUY CHƯƠNG MẠ VÀNG 3D VỚI HÀO QUANG THỞ 3 TẦNG & SAO LẤP LÁNH
        // KHÓA CỨNG KHUNG CHỨA 96×96px & DÙNG TRANSFORM.SCALE (TRIỆT TIÊU LAYOUT JITTER)
        // ─────────────────────────────────────────────────────────
        SizedBox(
          width: 96,
          height: 96,
          child: Center(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: glowAnimation,
                builder: (context, _) {
                  final glow = glowAnimation.value;

                  return GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // TẦNG 3: Vầng hào quang ngoài cùng - Cố định 88×88px, dùng Transform.scale
                        Transform.scale(
                          scale: 0.90 + (glow * 0.18),
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFFFEF3C7).withValues(
                                      alpha: 0.08 * (1.0 - glow * 0.3),
                                    )
                                  : const Color(0xFFF59E0B).withValues(
                                      alpha: 0.16 * (1.0 - glow * 0.35),
                                    ),
                            ),
                          ),
                        ),

                        // TẦNG 2: Vầng nhật hoa vàng kim - Cố định 74×74px, dùng Transform.scale
                        Transform.scale(
                          scale: 0.92 + (glow * 0.14),
                          child: Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF59E0B).withValues(
                                alpha: 0.30 * (1.0 - glow * 0.35),
                              ),
                            ),
                          ),
                        ),

                        // TẦNG 1: Khối Squircle 64×64px mạ vàng 3D ánh kim cố định
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFDE68A),
                                Color(0xFFF59E0B),
                                Color(0xFFD97706)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFFBEB),
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD97706).withValues(alpha: 0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFFFFBEB),
                              size: 38,
                            ),
                          ),
                        ),

                        // HIỆU ỨNG 3: Hạt sao vinh danh lấp lánh (Twinkle Glint - Góc trên phải)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Transform.rotate(
                            angle: glow * math.pi * 0.5,
                            child: Opacity(
                              opacity: sparkleAnimation.value.clamp(0.0, 1.0),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFFFDE68A),
                                size: 16,
                              ),
                            ),
                          ),
                        ),

                        // HIỆU ỨNG 3: Hạt sao vinh danh lấp lánh (Twinkle Glint - Góc dưới trái)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Transform.rotate(
                            angle: -glow * math.pi * 0.5,
                            child: Opacity(
                              opacity: (1.2 - sparkleAnimation.value).clamp(0.0, 1.0),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFFF59E0B),
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ─────────────────────────────────────────────────────────
        // 2. DANH HIỆU HỌC THUẬT & CHIP CẤP ĐỘ UY PHONG (WIDGET TĨNH - KHÔNG REBUILD)
        // ─────────────────────────────────────────────────────────
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              currentTitle,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 19,
                color: cs.slate900,
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF78350F).withValues(alpha: 0.3)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                  width: 0.8,
                ),
              ),
              child: Text(
                'CẤP ĐỘ ${progress.currentLevel}',
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w900,
                  fontSize: 10.5,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // ─────────────────────────────────────────────────────────
        // 3. CON SỐ VÀNG ÁP ĐẢO: 1,850 XP TÍCH LŨY (WIDGET TĨNH)
        // ─────────────────────────────────────────────────────────
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 2,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatNumber(progress.totalXp),
                  style: TextStyle(
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                    fontWeight: FontWeight.w900,
                    fontSize: 27,
                    letterSpacing: -0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'XP',
                  style: TextStyle(
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              '•',
              style: TextStyle(
                color: cs.slate400,
                fontSize: 13,
              ),
            ),
            Text(
              '$badgesCount huy hiệu',
              style: TextStyle(
                color: cs.slate600,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ─────────────────────────────────────────────────────────
        // 4. THANH NĂNG LƯỢNG THỦY DỊCH XP (LIQUID SHIMMER GAUGE)
        // CÔ LẬP LAYER VỚI REPAINTBOUNDARY
        // ─────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Tiến độ thăng cấp Lv.${progress.currentLevel + 1} (${progress.currentLevelXp} / ${LevelProgressData.xpPerLevel} XP)',
                style: tt.labelSmall?.copyWith(
                  color: cs.slate600,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${progress.progressPercent}%',
              style: TextStyle(
                color: cs.brandBlueDark,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Đường ray thanh năng lượng lỏng với Shimmer riêng
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: shimmerAnimation,
            builder: (context, _) {
              return Container(
                height: 7,
                decoration: BoxDecoration(
                  color: isDark ? cs.slate800 : cs.slate200,
                  borderRadius: BorderRadius.circular(3.5),
                ),
                alignment: Alignment.centerLeft,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // Dòng chảy năng lượng có Shimmer
                    FractionallySizedBox(
                      widthFactor: progress.progressRatio,
                      child: Container(
                        height: 7,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: const [
                              Color(0xFF2563EB),
                              Color(0xFF4F46E5),
                              Color(0xFF38BDF8),
                            ],
                            stops: [
                              (shimmerAnimation.value - 0.25).clamp(0.0, 1.0),
                              shimmerAnimation.value.clamp(0.0, 1.0),
                              (shimmerAnimation.value + 0.25).clamp(0.0, 1.0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3.5),
                        ),
                      ),
                    ),

                    // Hạt ngọc dẫn đường (Leading Energy Orb) tại vị trí mút
                    if (progress.progressRatio > 0.03)
                      FractionallySizedBox(
                        widthFactor: progress.progressRatio,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFF67E8F9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Dòng thôi thúc hành động nổi bật
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E40AF).withValues(alpha: 0.4)
                  : const Color(0xFFBFDBFE),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  progress.xpNeededForNext > 0
                      ? 'Còn ${progress.xpNeededForNext} XP nữa để mở khóa $nextTitle (Cấp ${progress.currentLevel + 1})'
                      : 'Đã hoàn thành mốc mục tiêu của cấp độ hiện tại!',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TẦNG 3: WIDGET 3 CAPSULE CHỈ SỐ VỆ TINH (THE SATELLITE METRIC PODS)
// ─────────────────────────────────────────────────────────────────────────────
class _SatellitePodsRow extends StatelessWidget {
  const _SatellitePodsRow({
    required this.stats,
    required this.isDark,
  });

  final StudentStatsModel stats;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Pod 1: Chuỗi kỷ luật (Streak)
        Expanded(
          child: _SatellitePod(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFEA580C),
            value: '${stats.streakDays} Ngày',
            label: 'Chuỗi kỷ luật',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),

        // Pod 2: Thời lượng học (Hours)
        Expanded(
          child: _SatellitePod(
            icon: Icons.schedule_rounded,
            iconColor: const Color(0xFF2563EB),
            value: '${stats.totalStudyHours.toStringAsFixed(stats.totalStudyHours.truncateToDouble() == stats.totalStudyHours ? 0 : 1)} Giờ',
            label: 'Tích lũy học',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),

        // Pod 3: Bài học hoàn tất (Lessons)
        Expanded(
          child: _SatellitePod(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF059669),
            value: '${stats.completedLessons} Bài',
            label: 'Đã hoàn thành',
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _SatellitePod extends StatelessWidget {
  const _SatellitePod({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: isDark
              ? cs.slate800.withValues(alpha: 0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? cs.slate800 : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: cs.slate900,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: cs.slate500,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
