// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:study/theme/app_spacing.dart';
import 'package:study/widgets/cached_avatar.dart';

/// Drawer menu chính của app — hiển thị user info và các menu items
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
    this.notificationCount = 0,
    required this.onNotificationsTap,
    required this.onBookmarksTap,
    required this.onSearchTap,
    required this.onSettingsTap,
    required this.onHelpTap,
    required this.onLogoutTap,
  });

  final String userName;
  final String userEmail;
  final String? userAvatar;
  final int notificationCount;
  final VoidCallback onNotificationsTap;
  final VoidCallback onBookmarksTap;
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onHelpTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  Text(
                    '40Study',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: 'Đóng menu',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CachedAvatar(
                    url: userAvatar,
                    radius: 24,
                    backgroundColor: cs.primary.withValues(alpha: 0.1),
                    placeholder: Icon(Icons.person, color: cs.primary),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userEmail,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Thông báo',
                    badge: notificationCount > 0 ? notificationCount : null,
                    onTap: onNotificationsTap,
                  ),
                  _DrawerItem(
                    icon: Icons.bookmark_outline,
                    label: 'Đã lưu',
                    onTap: onBookmarksTap,
                  ),
                  _DrawerItem(
                    icon: Icons.search,
                    label: 'Tìm kiếm',
                    onTap: onSearchTap,
                  ),
                  const Divider(height: 16, indent: 16, endIndent: 16),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Cài đặt',
                    onTap: onSettingsTap,
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    label: 'Trợ giúp',
                    onTap: onHelpTap,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Đăng xuất',
              iconColor: cs.error,
              labelColor: cs.error,
              onTap: onLogoutTap,
            ),
            AppSpacing.vGap8,
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badge;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: iconColor ?? cs.onSurfaceVariant),
      title: Text(label, style: tt.bodyLarge?.copyWith(color: labelColor)),
      // Badge cho notification count
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.toString(),
                style: tt.labelSmall?.copyWith(color: cs.onError),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
