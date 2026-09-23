import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Giao diện khi phụ huynh chưa liên kết tài khoản con (No-child Onboarding State).
/// Khớp 100% với ảnh thiết kế: Hero Card minh họa + CTA liên kết + Khối 3 giá trị tính năng.
class ParentNoChildView extends StatelessWidget {
  const ParentNoChildView({
    super.key,
    required this.onLinkChild,
    this.onContactSupport,
  });

  /// Callback khi phụ huynh bấm nút "+ Liên kết hồ sơ con ngay".
  final VoidCallback onLinkChild;

  /// Callback khi bấm "Chưa có mã học viên? Liên hệ Giáo vụ hỗ trợ".
  final VoidCallback? onContactSupport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroLinkChildCard(
            onLinkChild: onLinkChild,
            onContactSupport: onContactSupport ?? () => _showSupportDialog(context),
          ),
          AppSpacing.vGap24,
          const _FeatureHighlightsSection(),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.support_agent_rounded, color: cs.blue600, size: 22),
                    ),
                    AppSpacing.hGap12,
                    Expanded(
                      child: Text(
                        'Hỗ trợ lấy mã học viên',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                AppSpacing.vGap16,
                Text(
                  'Mã học viên (Student Code) được cấp khi học sinh đăng ký khóa học tại trung tâm 40Study. '
                  'Nếu chưa có mã hoặc làm mất mã, vui lòng liên hệ trực tiếp văn phòng Giáo vụ:',
                  style: tt.bodyMedium?.copyWith(color: cs.slate600, height: 1.5),
                ),
                AppSpacing.vGap16,
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.slate50,
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: cs.slate200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone_in_talk_rounded, color: cs.blue600, size: 20),
                      AppSpacing.hGap12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hotline Giáo vụ 40Study',
                              style: tt.labelSmall?.copyWith(color: cs.slate500),
                            ),
                            Text(
                              '1900 6868 (8:00 - 21:00 hàng ngày)',
                              style: tt.titleSmall?.copyWith(
                                color: cs.slate900,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGap16,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.blue600,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderLg,
                      ),
                    ),
                    child: const Text('Đã hiểu'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Khối thẻ Hero trung tâm: Icon minh họa gia đình kèm badge +, tiêu đề, mô tả và nút CTA.
class _HeroLinkChildCard extends StatelessWidget {
  const _HeroLinkChildCard({
    required this.onLinkChild,
    required this.onContactSupport,
  });

  final VoidCallback onLinkChild;
  final VoidCallback onContactSupport;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          AppSpacing.vGap8,
          // Icon minh họa: Vòng tròn xanh pastel lớn + Badge dấu cộng
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.family_restroom_rounded,
                      color: cs.blue600,
                      size: 42,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: cs.blue600,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: cs.blue600.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vGap20,
          // Tiêu đề chính
          Text(
            'Chưa có hồ sơ con được liên kết',
            style: tt.titleMedium?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGap8,
          // Đoạn văn bản mô tả hướng dẫn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'Liên kết tài khoản của con bằng mã học viên do trung tâm cung cấp để bắt đầu theo dõi tiến độ, lịch học và kết quả.',
              style: tt.bodySmall?.copyWith(
                color: cs.slate500,
                height: 1.5,
                fontSize: 13.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          AppSpacing.vGap20,
          // Nút CTA chính "+ Liên kết hồ sơ con ngay"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: onLinkChild,
              style: FilledButton.styleFrom(
                backgroundColor: cs.blue600,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderFull,
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                'Liên kết hồ sơ con ngay',
                style: tt.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          AppSpacing.vGap12,
          // Link trợ giúp: "Chưa có mã học viên? Liên hệ Giáo vụ hỗ trợ"
          InkWell(
            onTap: onContactSupport,
            borderRadius: AppRadius.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    size: 15,
                    color: cs.slate400,
                  ),
                  AppSpacing.hGap6,
                  Text(
                    'Chưa có mã học viên? Liên hệ Giáo vụ hỗ trợ',
                    style: tt.bodySmall?.copyWith(
                      color: cs.slate600,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Khối giới thiệu 3 tính năng cốt lõi sau khi liên kết hồ sơ con.
class _FeatureHighlightsSection extends StatelessWidget {
  const _FeatureHighlightsSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dòng phân cách & Header section
        Row(
          children: [
            Expanded(child: Divider(color: cs.slate200, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'SAU KHI LIÊN KẾT BẠN SẼ THEO DÕI ĐƯỢC',
                style: tt.labelSmall?.copyWith(
                  color: cs.slate400,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
            ),
            Expanded(child: Divider(color: cs.slate200, height: 1)),
          ],
        ),
        AppSpacing.vGap16,
        // 3 Feature Cards
        const _FeatureHighlightItem(
          icon: Icons.calendar_month_rounded,
          iconBgColor: Color(0xFFEEF2FF),
          iconColor: Color(0xFF4F46E5),
          title: 'Lịch học & Điểm danh thời gian thực',
          description:
              'Nhận thông báo khi con vào lớp, ca học sắp tới, đổi phòng hoặc đổi giáo viên.',
        ),
        AppSpacing.vGap12,
        const _FeatureHighlightItem(
          icon: Icons.assignment_turned_in_rounded,
          iconBgColor: Color(0xFFFEF3C7),
          iconColor: Color(0xFFD97706),
          title: 'Bài tập về nhà, Hạn nộp & Chấm điểm',
          description:
              'Biết ngay khi có bài tập mới, bài sắp quá hạn và kết quả điểm số sau khi thầy cô chấm.',
        ),
        AppSpacing.vGap12,
        const _FeatureHighlightItem(
          icon: Icons.insights_rounded,
          iconBgColor: Color(0xFFECFDF5),
          iconColor: Color(0xFF059669),
          title: 'Live Tracking & Báo cáo phân tích học tập',
          description:
              'Theo dõi con làm bài trực tiếp theo thời gian thực và xem phân tích điểm mạnh, điểm cần cải thiện mỗi tuần.',
        ),
      ],
    );
  }
}

/// Từng hàng item giới thiệu tính năng với icon vuông bo góc 12px, tiêu đề bold và mô tả.
class _FeatureHighlightItem extends StatelessWidget {
  const _FeatureHighlightItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                    height: 1.45,
                    fontSize: 12.5,
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
