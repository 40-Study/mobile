import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Hero Banner cho màn hình Tất cả Huy hiệu (AllAchievementsScreen)
/// Thiết kế phẳng, mang phong cách công nghệ học thuật tinh tế, hiện đại,
/// hỗ trợ toàn diện cả Light Mode và Dark Mode.
class AchievementsHeroBanner extends StatelessWidget {
  const AchievementsHeroBanner({
    super.key,
    required this.earnedCount,
    required this.totalBadges,
    this.learningCount,
    this.habitCount,
    this.achievementCount,
  });

  final int earnedCount;
  final int totalBadges;
  final int? learningCount;
  final int? habitCount;
  final int? achievementCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressVal = totalBadges > 0
        ? (earnedCount / totalBadges).clamp(0.0, 1.0)
        : 0.0;

    // Xác định cấp bậc học thuật (Academic Standing Tier)
    final (tierLabel, tierColor, tierBg, tierBorder) =
        _resolveTier(earnedCount, isDark);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? cs.outlineVariant.withValues(alpha: 0.3)
              : cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon Squircle + Title & Overline + Academic Tier Badge
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF78350F).withValues(alpha: 0.35)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFFD97706).withValues(alpha: 0.5)
                        : const Color(0xFFFDE68A),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: isDark
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFFD97706),
                  size: 22,
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PHÒNG TRUYỀN THỐNG',
                      style: TextStyle(
                        color: isDark ? cs.primary : cs.brandBlueDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bảng Vàng Danh Dự Học Viên',
                      style: TextStyle(
                        color: cs.slate900,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.hGap8,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: tierBg,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: tierBorder, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, size: 13, color: tierColor),
                    const SizedBox(width: 3),
                    Text(
                      tierLabel,
                      style: TextStyle(
                        color: tierColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 2: Số liệu tiến độ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã mở khóa $earnedCount/$totalBadges huy hiệu',
                style: TextStyle(
                  color: cs.slate700,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progressVal * 100).round()}% hoàn thành',
                style: TextStyle(
                  color: isDark ? cs.primary : cs.brandBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 3: Slim Minimalist Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 6,
              backgroundColor: isDark
                  ? cs.surfaceContainerHigh
                  : const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? cs.primary : cs.brandBlue,
              ),
            ),
          ),

          // Row 4: Category Breakdown Pills (nếu có số liệu)
          if (learningCount != null &&
              habitCount != null &&
              achievementCount != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatPill('📚 Học tập', learningCount!, cs, isDark),
                AppSpacing.hGap8,
                _buildStatPill('⚡ Thói quen', habitCount!, cs, isDark),
                AppSpacing.hGap8,
                _buildStatPill('⭐ Kỳ tích', achievementCount!, cs, isDark),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatPill(
    String label,
    int count,
    ColorScheme cs,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerLow : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isDark
                ? cs.outlineVariant.withValues(alpha: 0.3)
                : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        child: Text(
          '$label: $count',
          style: TextStyle(
            color: cs.slate600,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  (String, Color, Color, Color) _resolveTier(int count, bool isDark) {
    if (count >= 18) {
      return (
        'Hạng Bạch Kim',
        isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
        isDark
            ? const Color(0xFF312E81).withValues(alpha: 0.4)
            : const Color(0xFFEEF2FF),
        isDark
            ? const Color(0xFF4F46E5).withValues(alpha: 0.5)
            : const Color(0xFFC7D2FE),
      );
    } else if (count >= 12) {
      return (
        'Hạng Vàng',
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
        isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.4)
            : const Color(0xFFFEF3C7),
        isDark
            ? const Color(0xFFD97706).withValues(alpha: 0.5)
            : const Color(0xFFFDE68A),
      );
    } else if (count >= 6) {
      return (
        'Hạng Bạc',
        isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
        isDark
            ? const Color(0xFF334155).withValues(alpha: 0.5)
            : const Color(0xFFF1F5F9),
        isDark
            ? const Color(0xFF475569).withValues(alpha: 0.6)
            : const Color(0xFFCBD5E1),
      );
    } else {
      return (
        'Hạng Đồng',
        isDark ? const Color(0xFFFDBA74) : const Color(0xFFB45309),
        isDark
            ? const Color(0xFF7C2D12).withValues(alpha: 0.4)
            : const Color(0xFFFFFBEB),
        isDark
            ? const Color(0xFFC2410C).withValues(alpha: 0.5)
            : const Color(0xFFFDE68A),
      );
    }
  }
}
