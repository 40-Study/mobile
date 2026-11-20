import 'package:study/widgets/role_app_header.dart';

/// Student defaults for the shared role header.
class StudentAppHeader extends RoleAppHeader {
  const StudentAppHeader({
    super.key,
    super.icon,
    super.leading,
    super.onLeadingTap,
    super.onDrawerTap,
    super.categoryLabel = 'HỌC VIÊN 40STUDY',
    required super.title,
    super.trailing,
    super.onNotificationTap,
    super.onAvatarTap,
    super.backgroundColor,
    super.showNotification,
    super.showAvatar,
  });
}
