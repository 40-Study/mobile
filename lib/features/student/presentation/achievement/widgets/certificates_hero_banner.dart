import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Hero Banner cho màn hình Tất cả Chứng chỉ (AllCertificatesScreen)
/// Thiết kế phẳng sáng (Flat Light Surface), không sử dụng gradient,
/// mang phong cách công nghệ học thuật và chứng nhận năng lực số.
class CertificatesHeroBanner extends StatelessWidget {
  const CertificatesHeroBanner({
    super.key,
    required this.completedCount,
    required this.inProgressCount,
  });

  final int completedCount;
  final int inProgressCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.6),
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
          // Row 1: Squircle Icon + Title & Overline + Verified Digital Chip
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? cs.primary.withValues(alpha: 0.15) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? cs.primary.withValues(alpha: 0.3) : const Color(0xFFDBEAFE),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: isDark ? cs.primary : const Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HỒ SƠ NĂNG LỰC HỌC THUẬT',
                      style: TextStyle(
                        color: isDark ? cs.primary : cs.brandBlueDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chứng Chỉ & Văn Bằng ForteX',
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
                  color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isDark ? const Color(0xFF059669).withValues(alpha: 0.5) : const Color(0xFFA7F3D0),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Đã xác thực',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
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

          // Row 2: Metrics & Security Assurance Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? cs.surfaceContainerLow : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isDark ? cs.outlineVariant.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 16,
                      color: isDark ? cs.primary : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$completedCount đã cấp • $inProgressCount đang học',
                      style: TextStyle(
                        color: cs.slate800,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Mã định danh bảo mật điện tử tích hợp trên hệ thống ForteX',
                  style: TextStyle(
                    color: cs.slate500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
