import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

/// Header chuẩn dùng chung cho các màn hình trong phân hệ Học sinh (Student).
///
/// Thiết kế đồng bộ 100% với chuẩn ParentAppHeader:
/// - Leading tròn 44x44 nền pastel xanh nhạt (Color(0xFFEFF6FF)),
///   icon xanh dương (blue600)
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
  });

  /// Icon tròn đại diện (mặc định Icons.school_rounded)
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

  /// Màu nền header (mặc định là cs.surface)
  final Color? backgroundColor;

  /// Có hiển thị chuông thông báo hay không
  final bool showNotification;

  /// Có hiển thị avatar hay không
  final bool showAvatar;

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

        return Container(
          color: backgroundColor ?? cs.surface,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              // Icon đại diện phân hệ / menu dẫn hướng
              if (leading != null)
                leading!
              else
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: effectiveLeadingTap,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        effectiveIcon,
                        color: cs.blue600,
                        size: 24,
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
                        letterSpacing: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        color: cs.slate900,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
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
