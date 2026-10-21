import 'package:flutter/material.dart';
import 'package:study/widgets/role_app_header.dart';

/// Parent defaults for the shared role header.
class ParentAppHeader extends RoleAppHeader {
  const ParentAppHeader({
    super.key,
    super.icon = Icons.family_restroom_rounded,
    super.categoryLabel = 'PHỤ HUYNH 40STUDY',
    required super.title,
    super.onNotificationTap,
    super.onAvatarTap,
    super.backgroundColor,
  });
}
