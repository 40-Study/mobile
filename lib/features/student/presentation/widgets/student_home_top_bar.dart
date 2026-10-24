import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

/// Top Bar phẳng thanh thoát cho Trang chủ phân hệ Học sinh.
///
/// Thiết kế chuẩn mực theo phong cách Brand Anchor:
/// - Leading: Nút hamburger drawer để trần, không viền, không nền màu
/// - Center: Tên thương hiệu "ForteX" đậm nét định vị ứng dụng
/// - Actions: Chuông thông báo đỏ + Avatar người dùng nhỏ gọn
class StudentHomeTopBar extends StatelessWidget {
  const StudentHomeTopBar({
    super.key,
    this.onDrawerTap,
    this.onNotificationTap,
    this.onAvatarTap,
    this.hasUnreadNotifications = true,
    this.backgroundColor,
  });

  final VoidCallback? onDrawerTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final bool hasUnreadNotifications;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuth = state is AuthAuthenticated;
        final user = isAuth ? state.user : null;
        final displayName = user?.fullName ?? user?.username ?? 'HS';

        return Container(
          color: backgroundColor ?? cs.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              // Nút Drawer để trần, touch target chuẩn 40x40
              IconButton(
                onPressed: onDrawerTap,
                icon: Icon(
                  Icons.menu_rounded,
                  color: cs.slate800,
                  size: 26,
                ),
                tooltip: 'Menu',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              // Brand Anchor ở trung tâm
              Expanded(
                child: Center(
                  child: Text(
                    'ForteX',
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                      letterSpacing: -0.5,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              // Trailing: Chuông thông báo + Avatar
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Badge(
                    isLabelVisible: hasUnreadNotifications,
                    backgroundColor: AchievementColors.red,
                    smallSize: 8,
                    child: IconButton(
                      onPressed: onNotificationTap,
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: cs.slate700,
                        size: 24,
                      ),
                      tooltip: 'Thông báo',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 38,
                        minHeight: 38,
                      ),
                    ),
                  ),
                  AppSpacing.hGap8,
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: CachedAvatar(
                      url: user?.avatarUrl,
                      radius: 17,
                      backgroundColor: cs.slate900,
                      name: displayName,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
