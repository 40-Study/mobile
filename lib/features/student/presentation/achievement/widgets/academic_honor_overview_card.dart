import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/student_stats_model.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

/// Card Tổng quan Bảng Vàng Thành Tích - The Academic Honor Deck V2.0
///
/// Thiết kế phẳng sáng học thuật (Flat Light Academic Luxury),
/// loại bỏ gradient tối nặng nề, cấu trúc 2 tầng tương phản:
/// - Tầng 1: Tôn vinh Vị thế & Cấp bậc (Huân chương, Title, Chip Level, XP Bar).
/// - Tầng 2: Cụm 4 Thẻ chỉ số vi mô (Streak, Giờ học, Bài học, Huy hiệu).
class AcademicHonorOverviewCard extends StatelessWidget {
  const AcademicHonorOverviewCard({
    super.key,
    required this.stats,
    this.earnedBadgesCount,
    this.totalBadgesCount,
  });

  final StudentStatsModel stats;
  final int? earnedBadgesCount;
  final int? totalBadgesCount;

  /// Ánh xạ Danh hiệu học thuật động theo Cấp độ (Academic Standing Engine)
  static String resolveAcademicTitle(int level) {
    if (level <= 2) return 'Tân Khoa Nhập Môn';
    if (level <= 4) return 'Học Giả Tiến Bộ';
    if (level <= 6) return 'Học Giả Tinh Hoa';
    if (level <= 8) return 'Học Viện Danh Dự';
    return 'Đại Học Sĩ ForteX';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayLevel = stats.level > 0 ? stats.level : 1;
    final academicTitle = resolveAcademicTitle(displayLevel);

    // Tính toán tiến trình XP
    final currentXp = stats.currentXp;
    final nextLevelXp = stats.nextLevelXp > 0 ? stats.nextLevelXp : 1000;
    final xpProgress = (nextLevelXp > 0)
        ? (currentXp / nextLevelXp).clamp(0.0, 1.0)
        : 1.0;
    final remainingXp = (nextLevelXp - currentXp).clamp(0, 999999);
    final percentVal = (xpProgress * 100).toInt();

    // Dữ liệu huy hiệu thực tế (fallback về 0 nếu chưa mở)
    final badgesCount = earnedBadgesCount ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? cs.slate700 : cs.blue100,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(
              alpha: isDark ? 0.25 : 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════════
          // TẦNG 1: TÔN VINH VỊ THẾ & TIẾN TRÌNH CẤP BẬC (UPPER DECK)
          // ═══════════════════════════════════════════════════════════════════
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Squircle Huân chương Hoàng gia (Royal Emblem Squircle 46x46px)
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF78350F).withValues(alpha: 0.35)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFB45309).withValues(alpha: 0.6)
                        : const Color(0xFFFDE68A),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFD97706),
                  size: 25,
                ),
              ),
              AppSpacing.hGap12,

              // Tiêu đề Danh hiệu & Điểm XP tích lũy
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      academicTitle,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: cs.slate900,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tín chỉ tích lũy: $currentXp XP',
                      style: tt.bodySmall?.copyWith(
                        color: cs.slate500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Chip Cấp độ danh dự (Prestige Tier Badge)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF78350F).withValues(alpha: 0.3)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFD97706).withValues(alpha: 0.5)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 3.5),
                    Text(
                      'CẤP ĐỘ $displayLevel',
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFFB45309),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Thanh tiến trình kinh nghiệm Slim Tech XP Bar (6px)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tiến trình lên Cấp ${displayLevel + 1}',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: cs.slate600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                remainingXp > 0
                    ? '$remainingXp XP nữa • $percentVal%'
                    : 'Đã hoàn thành • 100%',
                style: tt.labelSmall?.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: cs.brandBlueDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              return Container(
                width: trackWidth,
                height: 6,
                decoration: BoxDecoration(
                  color: isDark ? cs.slate800 : cs.slate100,
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: xpProgress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) {
                    return Container(
                      width: trackWidth * val,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.brandBlue,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Hairline Divider phân tách 2 tầng
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(
              height: 0.8,
              color: isDark
                  ? cs.slate700.withValues(alpha: 0.6)
                  : cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),

          // ═══════════════════════════════════════════════════════════════════
          // TẦNG 2: CỤM 4 THẺ CHỈ SỐ VI MÔ (LOWER DECK - QUAD MICRO-STAT PODS)
          // ═══════════════════════════════════════════════════════════════════
          Row(
            children: [
              // Pod 1: Chuỗi học tập (Streak)
              Expanded(
                child: _MicroStatPod(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFEA580C),
                  bgColor: isDark
                      ? const Color(0xFF431407).withValues(alpha: 0.35)
                      : const Color(0xFFFFF7ED),
                  borderColor: const Color(0xFFFDBA74).withValues(alpha: 0.45),
                  value: stats.streakDays,
                  label: l10n?.streak ?? 'Chuỗi ngày',
                ),
              ),
              const SizedBox(width: 8),

              // Pod 2: Thời lượng học (Study Hours)
              Expanded(
                child: _MicroStatPod(
                  icon: Icons.schedule_rounded,
                  iconColor: const Color(0xFF2563EB),
                  bgColor: isDark
                      ? const Color(0xFF172554).withValues(alpha: 0.35)
                      : const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFF93C5FD).withValues(alpha: 0.45),
                  value: stats.totalStudyHours.toInt(),
                  label: l10n?.studyHours ?? 'Giờ học',
                ),
              ),
              const SizedBox(width: 8),

              // Pod 3: Bài học hoàn tất (Lessons Completed)
              Expanded(
                child: _MicroStatPod(
                  icon: Icons.menu_book_rounded,
                  iconColor: const Color(0xFF059669),
                  bgColor: isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                      : const Color(0xFFECFDF5),
                  borderColor: const Color(0xFF6EE7B7).withValues(alpha: 0.45),
                  value: stats.completedLessons,
                  label: l10n?.completedLessons ?? 'Bài học',
                ),
              ),
              const SizedBox(width: 8),

              // Pod 4: Huy hiệu đạt được (Badges Earned - Không hardcode)
              Expanded(
                child: _MicroStatPod(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  bgColor: isDark
                      ? const Color(0xFF3B0764).withValues(alpha: 0.35)
                      : const Color(0xFFFAF5FF),
                  borderColor: const Color(0xFFD8B4FE).withValues(alpha: 0.45),
                  value: badgesCount,
                  label: l10n?.badges ?? 'Huy hiệu',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Thẻ chỉ số vi mô độc lập (Micro Stat Pod)
class _MicroStatPod extends StatelessWidget {
  const _MicroStatPod({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 0.7,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon tròn nhỏ 22x22px
          Icon(
            icon,
            size: 19,
            color: iconColor,
          ),
          const SizedBox(height: 4),

          // Con số nổi bật có Rolling Animation
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$val',
                  style: tt.titleMedium?.copyWith(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: cs.slate900,
                    letterSpacing: -0.3,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 2),

          // Nhãn mô tả gọn gàng
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: cs.slate500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
