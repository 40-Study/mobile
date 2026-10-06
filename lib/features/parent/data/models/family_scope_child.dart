import 'package:flutter/material.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Model hiển thị cho chip chọn con trong Family Scope selector.
class FamilyScopeChild {
  const FamilyScopeChild({
    required this.id,
    required this.name,
    this.className,
    this.avatarUrl,
    required this.initialLetter,
    required this.badgeColor,
  });

  factory FamilyScopeChild.fromUserModel(
    UserModel user, {
    Color? badgeColor,
    int index = 0,
  }) {
    final name = user.fullName ?? user.username ?? 'Con';
    return FamilyScopeChild(
      id: user.id,
      name: name,
      avatarUrl: user.avatarUrl,
      initialLetter: name.isNotEmpty ? name[0].toUpperCase() : '?',
      badgeColor: badgeColor ?? AchievementColors.getBadgeColor(index),
    );
  }

  /// Tạo child mẫu cho smart fallback khi API trống.
  factory FamilyScopeChild.sample({
    required String id,
    required String name,
    String? className,
  }) {
    return FamilyScopeChild(
      id: id,
      name: name,
      className: className,
      initialLetter: name.isNotEmpty ? name[0].toUpperCase() : '?',
      badgeColor: AchievementColors.getBadgeColor(id.hashCode),
    );
  }

  final String id;
  final String name;
  final String? className;
  final String? avatarUrl;
  final String initialLetter;
  final Color badgeColor;
}
