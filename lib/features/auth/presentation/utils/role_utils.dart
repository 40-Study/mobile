import 'package:flutter/material.dart';

/// Centralized role utilities for display purposes.
class RoleUtils {
  const RoleUtils._();

  /// Returns localized label for role name.
  static String getLabel(String roleName) {
    final name = roleName.toUpperCase();
    if (name.contains('STUDENT')) return 'Học sinh';
    if (name.contains('TEACHER')) return 'Giáo viên';
    if (name.contains('PARENT')) return 'Phụ huynh';
    if (name.contains('OWNER') || name.contains('ORG')) return 'Chủ tổ chức';
    if (name.contains('ADMIN')) return 'Quản trị viên';
    return roleName;
  }

  /// Returns description for role.
  static String getDescription(String roleName) {
    final name = roleName.toUpperCase();
    if (name.contains('STUDENT')) return 'Học tập, luyện đề và theo dõi tiến độ';
    if (name.contains('TEACHER')) return 'Tạo khóa học, quản lý học sinh';
    if (name.contains('PARENT')) return 'Theo dõi kết quả học tập của con em';
    if (name.contains('OWNER') || name.contains('ORG')) {
      return 'Quản lý tổ chức giáo dục của bạn';
    }
    if (name.contains('ADMIN')) return 'Quản trị hệ thống';
    return '';
  }

  /// Returns icon for role.
  static IconData getIcon(String roleName) {
    final name = roleName.toUpperCase();
    if (name.contains('STUDENT')) return Icons.school_outlined;
    if (name.contains('TEACHER')) return Icons.assignment_ind_outlined;
    if (name.contains('PARENT')) return Icons.supervisor_account_outlined;
    if (name.contains('OWNER') || name.contains('ORG')) {
      return Icons.domain_outlined;
    }
    if (name.contains('ADMIN')) return Icons.admin_panel_settings_outlined;
    return Icons.person_outline;
  }

  /// Checks if role name matches any of the allowed patterns.
  static bool isAllowedRole(String roleName) {
    final name = roleName.toUpperCase();
    return name.contains('STUDENT') ||
        name.contains('TEACHER') ||
        name.contains('PARENT') ||
        name.contains('OWNER') ||
        name.contains('ORG');
  }

  /// Sort order for roles (for consistent display).
  static int getSortOrder(String roleName) {
    final name = roleName.toUpperCase();
    if (name.contains('STUDENT')) return 0;
    if (name.contains('TEACHER')) return 1;
    if (name.contains('PARENT')) return 2;
    if (name.contains('OWNER') || name.contains('ORG')) return 3;
    return 99;
  }
}
