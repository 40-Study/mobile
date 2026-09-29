import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

/// Header chuẩn dùng chung cho các màn hình trong phân hệ Phụ huynh (Parent).
///
/// Đảm bảo tính đồng bộ 100% về kích thước, padding, font chữ, avatar và chuông
/// thông báo giữa Trang chủ và các Tab chức năng như Lịch học.
class ParentAppHeader extends StatelessWidget {
  const ParentAppHeader({
    super.key,
    this.icon = Icons.family_restroom_rounded,
    this.categoryLabel = 'PHỤ HUYNH 40STUDY',
    required this.title,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  final IconData icon;
  final String categoryLabel;
  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuth = state is AuthAuthenticated;
        final user = isAuth ? state.user : null;
        final displayName = user?.fullName ?? user?.username ?? 'PH';

        return Container(
          color: cs.surface,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              // Icon đại diện phân hệ / tính năng
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: cs.blue600,
                  size: 24,
                ),
              ),
              AppSpacing.hGap12,
              // Cột tiêu đề
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              // Chuông thông báo
              Badge(
                backgroundColor: AchievementColors.red,
                smallSize: 8,
                child: IconButton(
                  onPressed: onNotificationTap,
                  icon: Icon(Icons.notifications_outlined, color: cs.slate700),
                ),
              ),
              AppSpacing.hGap8,
              // Avatar phụ huynh
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
