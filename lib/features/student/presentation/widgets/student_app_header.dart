import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

/// Header chuẩn dùng chung cho các màn hình trong phân hệ Học sinh (Student).
///
/// Thiết kế đồng bộ 100% với chuẩn ParentAppHeader:
/// - Leading tròn 44x44 nền pastel xanh nhạt (cs.primaryContainer),
///   icon xanh học thuật (cs.primary)
/// - Cột tiêu đề: Phân mục uppercase tracking rộng + Tiêu đề chính đậm nét 18sp
/// - Actions: Trailing tùy chọn + Chuông thông báo đỏ +
///   Avatar người dùng lấy từ AuthBloc
class StudentAppHeader extends StatelessWidget {
  const StudentAppHeader({
    super.key,
    this.icon,
    this.leading,
    this.onLeadingTap,
    this.onDrawerTap,
    this.categoryLabel = 'HỌC VIÊN 40STUDY',
    required this.title,
    this.trailing,
    this.onNotificationTap,
    this.onAvatarTap,
    this.backgroundColor,
    this.showNotification = true,
    this.showAvatar = true,
    this.iconBackgroundColor,
    this.iconColor,
    this.iconBorderColor,
    this.borderRadius,
    this.enableBottomCurve = false,
    this.enableShadow = false,
    this.isSeamless = true,
  });

  /// Icon đại diện (mặc định Icons.school_rounded)
  final IconData? icon;

  /// Widget tùy biến phần leading nếu muốn ghi đè hoàn toàn
  final Widget? leading;

  /// Callback khi ấn vào leading icon
  final VoidCallback? onLeadingTap;

  /// Callback khi ấn vào nút mở Drawer (nếu có)
  final VoidCallback? onDrawerTap;

  /// Nhãn danh mục chữ in hoa phía trên (VD: HỌC VIÊN 40STUDY, THỜI KHÓA BIỂU)
  final String categoryLabel;

  /// Tiêu đề chính màn hình (VD: Xin chào, Nam! hoặc Học tập của tôi)
  final String title;

  /// Widget phụ trợ ở bên phải (VD: icon tìm kiếm, filter)
  final Widget? trailing;

  /// Callback khi bấm vào chuông thông báo
  final VoidCallback? onNotificationTap;

  /// Callback khi bấm vào avatar học sinh
  final VoidCallback? onAvatarTap;

  /// Màu nền header (mặc định là Colors.transparent trong chế độ isSeamless)
  final Color? backgroundColor;

  /// Có hiển thị chuông thông báo hay không
  final bool showNotification;

  /// Có hiển thị avatar hay không
  final bool showAvatar;

  /// Màu nền cho Squircle leading icon
  final Color? iconBackgroundColor;

  /// Màu biểu tượng cho leading icon
  final Color? iconColor;

  /// Màu đường viền cho Squircle leading icon
  final Color? iconBorderColor;

  /// Bo góc tùy biến cho container Header
  final BorderRadiusGeometry? borderRadius;

  /// Bật/tắt bo cong cạnh đáy Header (chỉ dùng khi isSeamless = false)
  final bool enableBottomCurve;

  /// Bật/tắt đổ bóng dưới đáy Header (chỉ dùng khi isSeamless = false)
  final bool enableShadow;

  /// Chế độ Seamless Open Header: hòa tan tự nhiên vào nền trang,
  /// không viền, không bóng đổ, typography to bản dạng Large Title.
  final bool isSeamless;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuth = state is AuthAuthenticated;
        final user = isAuth ? state.user : null;
        final displayName = user?.fullName ?? user?.username ?? 'HS';

        final effectiveLeadingTap = onLeadingTap ?? onDrawerTap;
        final effectiveIcon = icon ??
            (onDrawerTap != null ? Icons.menu_rounded : Icons.school_rounded);

        final effectiveDecoration = isSeamless
            ? BoxDecoration(
                color: backgroundColor ?? Colors.transparent,
              )
            : BoxDecoration(
                color: backgroundColor ?? cs.surface,
                borderRadius: borderRadius ??
                    (enableBottomCurve
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(22),
                          )
                        : BorderRadius.zero),
                border: enableBottomCurve
                    ? Border(
                        bottom: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      )
                    : null,
                boxShadow: enableShadow
                    ? [
                        BoxShadow(
                          color: cs.shadow.withValues(alpha: 0.035),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              );

        final effectivePadding = isSeamless
            ? const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.xs,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              )
            : const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              );

        return Container(
          decoration: effectiveDecoration,
          padding: effectivePadding,
          child: Row(
            children: [
              // Icon đại diện phân hệ dạng Squircle 40x40
              if (leading != null)
                leading!
              else
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: effectiveLeadingTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor ?? cs.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: iconBorderColor ??
                              cs.outlineVariant.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        effectiveIcon,
                        color: iconColor ?? cs.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              AppSpacing.hGap12,
              // Cột tiêu đề
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      categoryLabel,
                      style: tt.labelSmall?.copyWith(
                        color: cs.slate500,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: tt.titleLarge?.copyWith(
                        color: cs.slate900,
                        fontWeight: FontWeight.w800,
                        fontSize: isSeamless ? 24 : 19,
                        letterSpacing: isSeamless ? -0.5 : -0.4,
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Trailing action phụ (ví dụ nút Search)
              if (trailing != null) ...[
                trailing!,
                AppSpacing.hGap4,
              ],
              // Chuông thông báo
              if (showNotification) ...[
                Badge(
                  backgroundColor: AchievementColors.red,
                  smallSize: 8,
                  child: IconButton(
                    onPressed: onNotificationTap,
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: cs.slate700,
                    ),
                    tooltip: 'Thông báo',
                  ),
                ),
                AppSpacing.hGap8,
              ],
              // Avatar học sinh
              if (showAvatar)
                GestureDetector(
                  onTap: onAvatarTap,
                  child: CachedAvatar(
                    url: user?.avatarUrl,
                    radius: 20,
                    backgroundColor: cs.slate900,
                    name: displayName,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
