import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

class RoleAppHeader extends StatelessWidget {
  const RoleAppHeader({
    super.key,
    this.icon,
    this.leading,
    this.onLeadingTap,
    this.onDrawerTap,
    this.categoryLabel = '40STUDY',
    required this.title,
    this.trailing,
    this.titleSuffix,
    this.onNotificationTap,
    this.onAvatarTap,
    this.backgroundColor,
    this.showNotification = true,
    this.showNotificationBadge = true,
    this.compact = false,
    this.showAvatar = true,
    this.iconBackgroundColor,
    this.iconColor,
    this.iconBorderColor,
  });

  /// Icon tròn đại diện của role
  final IconData? icon;

  /// Widget tùy biến phần leading nếu muốn ghi đè hoàn toàn
  final Widget? leading;

  /// Callback khi ấn vào leading icon
  final VoidCallback? onLeadingTap;

  /// Callback khi ấn vào nút mở Drawer (nếu có)
  final VoidCallback? onDrawerTap;

  /// Nhãn danh mục chữ in hoa phía trên (VD: GIÁO VIÊN 40STUDY, THỜI KHÓA BIỂU)
  final String categoryLabel;

  /// Tiêu đề chính màn hình (VD: Xin chào, Nam! hoặc Học tập của tôi)
  final String title;

  /// Widget phụ trợ ở bên phải (VD: icon tìm kiếm, filter)
  final Widget? trailing;
  final Widget? titleSuffix;

  /// Callback khi bấm vào chuông thông báo
  final VoidCallback? onNotificationTap;

  /// Callback khi bấm vào avatar tài khoản
  final VoidCallback? onAvatarTap;

  /// Màu nền header (mặc định là cs.surface)
  final Color? backgroundColor;

  /// Có hiển thị chuông thông báo hay không
  final bool showNotification;
  final bool showNotificationBadge;
  final bool compact;

  /// Có hiển thị avatar hay không
  final bool showAvatar;

  /// Màu nền cho icon tròn
  final Color? iconBackgroundColor;

  /// Màu của icon
  final Color? iconColor;

  /// Màu viền của icon
  final Color? iconBorderColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuth = state is AuthAuthenticated;
        final user = isAuth ? state.user : null;
        final displayName = user?.fullName ?? user?.username ?? 'Bạn';

        final titleText = Text(
          title,
          style: tt.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: compact ? 22 : 18,
          ),
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        );
        final suffix = titleSuffix;
        final effectiveLeadingTap = onLeadingTap ?? onDrawerTap;
        final effectiveIcon =
            icon ??
            (onDrawerTap != null ? Icons.menu_rounded : Icons.school_rounded);

        return Container(
          color: backgroundColor ?? cs.surface,
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
              : const EdgeInsets.fromLTRB(
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
                      width: compact ? 32 : 44,
                      height: compact ? 32 : 44,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor ?? cs.primaryContainer,
                        shape: BoxShape.circle,
                        border: iconBorderColor != null
                            ? Border.all(color: iconBorderColor!)
                            : null,
                      ),
                      child: Icon(
                        effectiveIcon,
                        color: iconColor ?? cs.primary,
                        size: compact ? 20 : 24,
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
                    if (!compact)
                      Text(
                        categoryLabel,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (!compact) const SizedBox(height: 2),
                    if (suffix == null)
                      titleText
                    else
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: titleText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(flex: 3, child: suffix),
                        ],
                      ),
                  ],
                ),
              ),
              // Trailing action phụ (ví dụ nút Search)
              if (trailing != null) ...[trailing!, AppSpacing.hGap4],
              // Chuông thông báo
              if (showNotification) ...[
                Badge(
                  backgroundColor: AchievementColors.red,
                  smallSize: 8,
                  isLabelVisible: showNotificationBadge,
                  child: IconButton(
                    constraints: compact
                        ? const BoxConstraints(minWidth: 48, minHeight: 48)
                        : null,
                    onPressed: onNotificationTap,
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: cs.onSurfaceVariant,
                    ),
                    tooltip: 'Thông báo',
                  ),
                ),
                AppSpacing.hGap8,
              ],
              // Avatar tài khoản
              if (showAvatar && compact)
                IconButton(
                  onPressed: onAvatarTap,
                  tooltip: 'Hồ sơ',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  padding: EdgeInsets.zero,
                  icon: CachedAvatar(
                    url: user?.avatarUrl,
                    radius: 18,
                    backgroundColor: cs.primaryContainer,
                    name: displayName,
                  ),
                )
              else if (showAvatar)
                GestureDetector(
                  onTap: onAvatarTap,
                  child: CachedAvatar(
                    url: user?.avatarUrl,
                    radius: 20,
                    backgroundColor: cs.primaryContainer,
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
