import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Hero Banner cho màn hình Tất cả Huy hiệu (AllAchievementsScreen)
/// Thiết kế phẳng sáng (Flat Light Surface), không sử dụng gradient,
/// mang phong cách công nghệ học thuật tinh tế, hiện đại.
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
    final progressVal = totalBadges > 0
        ? (earnedCount / totalBadges).clamp(0.0, 1.0)
        : 0.0;

    // Xác định cấp bậc học thuật (Academic Standing Tier)
    final (tierLabel, tierColor, tierBg, tierBorder) =
        _resolveTier(earnedCount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.035),
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
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFD97706),
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
                        color: cs.brandBlueDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Bảng Vàng Danh Dự Học Viên',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
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
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progressVal * 100).round()}% hoàn thành',
                style: TextStyle(
                  color: cs.brandBlue,
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
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(cs.brandBlue),
            ),
          ),

          // Row 4: Category Breakdown Pills (nếu có số liệu)
          if (learningCount != null &&
              habitCount != null &&
              achievementCount != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatPill('📚 Học tập', learningCount!),
                AppSpacing.hGap8,
                _buildStatPill('⚡ Thói quen', habitCount!),
                AppSpacing.hGap8,
                _buildStatPill('⭐ Kỳ tích', achievementCount!),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        child: Text(
          '$label: $count',
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  (String, Color, Color, Color) _resolveTier(int count) {
    if (count >= 18) {
      return (
        'Hạng Bạch Kim',
        const Color(0xFF6366F1),
        const Color(0xFFEEF2FF),
        const Color(0xFFC7D2FE),
      );
    } else if (count >= 12) {
      return (
        'Hạng Vàng',
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
        const Color(0xFFFDE68A),
      );
    } else if (count >= 6) {
      return (
        'Hạng Bạc',
        const Color(0xFF475569),
        const Color(0xFFF1F5F9),
        const Color(0xFFCBD5E1),
      );
    } else {
      return (
        'Hạng Đồng',
        const Color(0xFFB45309),
        const Color(0xFFFFFBEB),
        const Color(0xFFFDE68A),
      );
    }
  }
}
