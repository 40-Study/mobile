import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/widgets/role_app_header.dart';

/// Teacher-specific header with branding colors.
/// Uses RoleColors.teacherPrimary (#1E40AF) for icon styling.
class TeacherAppHeader extends StatelessWidget {
  const TeacherAppHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.titleSuffix,
    this.onAvatarTap,
    this.onNotificationTap,
    this.hasUnreadNotifications = false,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final Widget? titleSuffix;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) => RoleAppHeader(
    icon: icon,
    categoryLabel: 'GIÁO VIÊN 40STUDY',
    title: title,
    iconBackgroundColor: RoleColors.teacherPrimary.withValues(alpha: 0.1),
    iconColor: RoleColors.teacherPrimary,
    trailing: trailing,
    titleSuffix: titleSuffix,
    onAvatarTap: onAvatarTap,
    onNotificationTap: onNotificationTap,
    compact: true,
    showNotification: true,
    showNotificationBadge: hasUnreadNotifications,
  );
}
