import 'package:flutter/material.dart';

/// Thẻ Card điều hướng lớn tại màn hình chính tab Học tập (Learning Root Hub).
///
/// Hỗ trợ đầy đủ các dạng hiển thị:
/// - Icon vuông màu pastel tương ứng từng chủ đề
/// - Tiêu đề kèm Badge inline (VD: "3 lớp đang học", "AI đề xuất")
/// - Dòng phụ đề tóm tắt (Subtitle)
/// - Hàng thông tin chi tiết mở rộng (Pill nhận xét, Dòng môn, Thanh tiến độ %)
/// - Mũi tên chevron điều hướng sang màn hình con
class LearningHubNavigationCard extends StatelessWidget {
  const LearningHubNavigationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.inlineBadgeText,
    this.inlineBadgeBgColor,
    this.inlineBadgeTextColor,
    required this.subtitle,
    this.extraContent,
    required this.onTap,
  });

  /// Icon đại diện cho chức năng
  final IconData icon;

  /// Màu sắc của icon
  final Color iconColor;

  /// Màu nền pastel của ô chứa icon
  final Color iconBgColor;

  /// Tiêu đề chính của thẻ (VD: "Insights / Phân tích", "Lớp học")
  final String title;

  /// Tag nhãn nằm ngay cạnh tiêu đề (VD: "3 lớp đang học", "AI đề xuất")
  final String? inlineBadgeText;
  final Color? inlineBadgeBgColor;
  final Color? inlineBadgeTextColor;

  /// Phụ đề giải thích hoặc tóm tắt trạng thái
  final String subtitle;

  /// Widget nội dung bổ sung dưới phụ đề (VD: Pill nhận xét, Thanh % tiến độ)
  final Widget? extraContent;

  /// Callback khi người dùng nhấn vào thẻ
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ô Icon vuông pastel
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Nội dung text chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng Tiêu đề + Inline Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (inlineBadgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: inlineBadgeBgColor ??
                                    const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                inlineBadgeText!,
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: inlineBadgeTextColor ??
                                      const Color(0xFF0369A1),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Phụ đề
                      Text(
                        subtitle,
                        style: tt.bodySmall?.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),

                      // Khối bổ sung (nếu có)
                      if (extraContent != null) ...[
                        const SizedBox(height: 10),
                        extraContent!,
                      ],
                    ],
                  ),
                ),

                // 3. Mũi tên Chevron
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
