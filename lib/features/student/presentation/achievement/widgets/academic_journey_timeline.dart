import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/theme/theme.dart';

/// Dòng Thời Gian Hành Trình Học Tập - The Academic Learning Journey Timeline V3.0
///
/// Bố cục phẳng liền mạch (Zero-Card Seamless Canvas) - Triệt tiêu hoàn toàn Card Fatigue.
/// Tái hiện toàn bộ quá trình học tập theo trục thời gian sống động:
/// - Trạm 1: Khởi Nguyên Tri Thức (Genesis) - Giờ học & Bài học tích lũy.
/// - Trạm 2: Kỷ Luật Bền Bỉ (Momentum) - Chuỗi học tập Streak rực lửa.
/// - Trạm 3: Đỉnh Cao Hiện Tại (Active Zenith) - Cấp độ, Danh hiệu học thuật & Hào quang thở.
/// - Trạm 4: Chân Trời Kế Tiếp (Next Horizon) - Đường ray nét đứt dẫn tới mục tiêu tương lai.
class AcademicJourneyTimeline extends StatefulWidget {
  const AcademicJourneyTimeline({
    super.key,
    required this.stats,
    this.earnedBadgesCount,
    this.totalBadgesCount,
    this.joinedDateText,
    this.enableAnimation = true,
  });

  final StudentStatsModel stats;
  final int? earnedBadgesCount;
  final int? totalBadgesCount;
  final String? joinedDateText;
  final bool enableAnimation;

  /// Ánh xạ Danh hiệu học thuật động theo Cấp độ (Academic Standing Engine)
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

  @override
  State<AcademicJourneyTimeline> createState() =>
      _AcademicJourneyTimelineState();
}

class _AcademicJourneyTimelineState extends State<AcademicJourneyTimeline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.85).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enableAnimation) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stats = widget.stats;
    final displayLevel = stats.level > 0 ? stats.level : 1;
    final currentTitle = AcademicJourneyTimeline.resolveAcademicTitle(displayLevel);
    final nextTitle = AcademicJourneyTimeline.resolveAcademicTitle(displayLevel + 1);

    // Tính toán tiến trình XP
    final currentXp = stats.currentXp;
    final nextLevelXp = stats.nextLevelXp > 0 ? stats.nextLevelXp : 1000;
    final xpProgress = (nextLevelXp > 0)
        ? (currentXp / nextLevelXp).clamp(0.0, 1.0)
        : 1.0;
    final remainingXp = (nextLevelXp - currentXp).clamp(0, 999999);
    final percentVal = (xpProgress * 100).toInt();

    final badgesCount = widget.earnedBadgesCount ?? 0;
    final joinedText = widget.joinedDateText ?? 'Khởi đầu hành trình học thuật';

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
                      'Tiến Trình & Cột Mốc Năng Lực',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
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

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════════
          // TRỤC THỜI GIAN SỐNG (THE LIVING CHRONICLE TIMELINE)
          // ═══════════════════════════════════════════════════════════════════

          // ─────────────────────────────────────────────────────────────────
          // TRẠM 1: KHỞI NGUYÊN TRI THỨC (THE GENESIS WAYPOINT)
          // ─────────────────────────────────────────────────────────────────
          _TimelineRow(
            isFirst: true,
            isLast: false,
            trackColor: cs.brandBlue,
            isDashed: false,
            node: _CircleNode(
              icon: Icons.flag_rounded,
              iconColor: const Color(0xFF059669),
              bgColor: isDark
                  ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                  : const Color(0xFFECFDF5),
              borderColor: const Color(0xFF6EE7B7),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khởi Nguyên Tri Thức',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: cs.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  joinedText,
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),

                // Inline Metric Chips (Không bọc Card hộp)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InlineMetricBadge(
                      icon: Icons.schedule_rounded,
                      iconColor: const Color(0xFF2563EB),
                      label: '${stats.totalStudyHours.toInt()} giờ tích lũy',
                    ),
                    _InlineMetricBadge(
                      icon: Icons.menu_book_rounded,
                      iconColor: const Color(0xFF059669),
                      label: '${stats.completedLessons} bài hoàn tất',
                    ),
                  ],
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),

          // ─────────────────────────────────────────────────────────────────
          // TRẠM 2: KỶ LUẬT BỀN BỈ (THE MOMENTUM WAYPOINT)
          // ─────────────────────────────────────────────────────────────────
          _TimelineRow(
            isFirst: false,
            isLast: false,
            trackColor: const Color(0xFFEA580C),
            isDashed: false,
            node: _CircleNode(
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFEA580C),
              bgColor: isDark
                  ? const Color(0xFF431407).withValues(alpha: 0.4)
                  : const Color(0xFFFFF7ED),
              borderColor: const Color(0xFFFDBA74),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Chuỗi Kỷ Luật',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: cs.slate900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${stats.streakDays} ngày liên tục',
                        style: const TextStyle(
                          color: Color(0xFFEA580C),
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  stats.streakDays > 0
                      ? 'Duy trì học tập bền bỉ, thắp sáng động lực mỗi ngày.'
                      : 'Bắt đầu bài học hôm nay để kích hoạt ngọn lửa kỷ luật.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ─────────────────────────────────────────────────────────────────
          // TRẠM 3: ĐỈNH CAO HIỆN TẠI (THE ACTIVE ZENITH - HERO NODE)
          // ─────────────────────────────────────────────────────────────────
          _TimelineRow(
            isFirst: false,
            isLast: false,
            trackColor: cs.brandBlue,
            isDashed: false,
            node: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                final glow = _glowAnimation.value;
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Breathing Beacon Aura Glow
                    Container(
                      width: 44 + (glow * 10),
                      height: 44 + (glow * 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD97706).withValues(
                          alpha: 0.15 * (1.0 - glow * 0.5),
                        ),
                      ),
                    ),
                    // Squircle Emblem
                    child!,
                  ],
                );
              },
              child: GestureDetector(
                onTap: HapticFeedback.selectionClick,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF78350F).withValues(alpha: 0.4)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: const Color(0xFFD97706),
                      width: 1.6,
                    ),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFD97706),
                    size: 24,
                  ),
                ),
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(
                                currentTitle,
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.5,
                                  color: cs.slate900,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B),
                                    width: 0.6,
                                  ),
                                ),
                                child: Text(
                                  'CẤP ĐỘ $displayLevel',
                                  style: const TextStyle(
                                    color: Color(0xFFB45309),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.5,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$currentXp XP tích lũy • $badgesCount huy hiệu vinh danh',
                            style: tt.bodySmall?.copyWith(
                              color: cs.brandBlueDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Slim Tech Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Tiến trình thăng cấp',
                        style: tt.labelSmall?.copyWith(
                          color: cs.slate500,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$percentVal%',
                      style: tt.labelSmall?.copyWith(
                        color: cs.brandBlueDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? cs.slate800 : cs.slate200,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: xpProgress,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.brandBlue,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),

          // ─────────────────────────────────────────────────────────────────
          // TRẠM 4: CHÂN TRỜI KẾ TIẾP (THE NEXT HORIZON - FUTURE WAYPOINT)
          // ─────────────────────────────────────────────────────────────────
          _TimelineRow(
            isFirst: false,
            isLast: true,
            trackColor: isDark ? cs.slate700 : cs.slate300,
            isDashed: true,
            node: _CircleNode(
              icon: Icons.auto_awesome_rounded,
              iconColor: cs.slate400,
              bgColor: isDark ? cs.slate800 : cs.slate100,
              borderColor: cs.slate300,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Mục Tiêu Kế Tiếp: $nextTitle',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: cs.slate700,
                      ),
                    ),
                    Text(
                      '(Cấp ${displayLevel + 1})',
                      style: tt.labelSmall?.copyWith(
                        color: cs.slate400,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  remainingXp > 0
                      ? 'Còn $remainingXp XP nữa để vinh danh danh xưng tiếp theo.'
                      : 'Đã hoàn thành mốc mục tiêu của cấp độ hiện tại!',
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dòng chứa Node bên trái và Nội dung bên phải nối bằng trục ray
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.isFirst,
    required this.isLast,
    required this.trackColor,
    required this.isDashed,
    required this.node,
    required this.content,
  });

  final bool isFirst;
  final bool isLast;
  final Color trackColor;
  final bool isDashed;
  final Widget node;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trục đường ray bên trái
          SizedBox(
            width: 44,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Đường ray vẽ bằng CustomPaint
                if (!isLast)
                  Positioned.fill(
                    top: 24,
                    child: CustomPaint(
                      painter: _TrackPainter(
                        color: trackColor,
                        isDashed: isDashed,
                      ),
                    ),
                  ),

                // Nút trạm cột mốc
                Align(
                  alignment: Alignment.topCenter,
                  child: node,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Nội dung bên phải
          Expanded(child: content),
        ],
      ),
    );
  }
}

/// Node tròn cho các trạm phụ (28x28px)
class _CircleNode extends StatelessWidget {
  const _CircleNode({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: Icon(
        icon,
        size: 15,
        color: iconColor,
      ),
    );
  }
}

/// Chip nhãn chỉ số phẳng không dùng Card hộp (Inline Metric Badge)
class _InlineMetricBadge extends StatelessWidget {
  const _InlineMetricBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isDark
            ? cs.slate800.withValues(alpha: 0.6)
            : cs.slate100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark
              ? cs.slate700.withValues(alpha: 0.5)
              : cs.slate200.withValues(alpha: 0.8),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4.5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: cs.slate800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Vẽ đường ray liên kết giữa các Node
class _TrackPainter extends CustomPainter {
  const _TrackPainter({
    required this.color,
    required this.isDashed,
  });

  final Color color;
  final bool isDashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final x = size.width / 2;
    const startY = 10.0;
    final endY = size.height;

    if (!isDashed) {
      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    } else {
      // Nét đứt (Dashed line: 4px vạch, 4px khoảng trống)
      const dashHeight = 4.0;
      const dashSpace = 4.0;
      var currentY = startY;

      while (currentY < endY) {
        final drawLength = (currentY + dashHeight > endY)
            ? endY - currentY
            : dashHeight;
        canvas.drawLine(
          Offset(x, currentY),
          Offset(x, currentY + drawLength),
          paint,
        );
        currentY += dashHeight + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrackPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDashed != isDashed;
  }
}
