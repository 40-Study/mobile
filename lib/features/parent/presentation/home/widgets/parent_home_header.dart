import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

/// Header Parent Home: icon gia đình + greeting + chuông + avatar.
class ParentHomeHeader extends StatelessWidget {
  const ParentHomeHeader({
    super.key,
    this.titleOverride,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  /// Tiêu đề ghi đè (ví dụ "Trang chủ Phụ huynh" khi chưa có con).
  final String? titleOverride;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  static String getDynamicGreeting(String? fullName) {
    final hour = DateTime.now().hour;
    final String timeGreeting;
    if (hour < 11) {
      timeGreeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      timeGreeting = 'Chào buổi chiều';
    } else {
      timeGreeting = 'Chào buổi tối';
    }

    if (fullName == null || fullName.trim().isEmpty) {
      return '$timeGreeting, Gia đình!';
    }
    return '$timeGreeting, ${fullName.trim()}!';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuth = state is AuthAuthenticated;
        final user = isAuth ? state.user : null;
        final displayName = user?.fullName ?? user?.username ?? 'PH';
        final greetingText = titleOverride ??
            getDynamicGreeting(user?.fullName ?? user?.username);

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
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.family_restroom_rounded,
                  color: cs.blue600,
                  size: 24,
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PHỤ HUYNH 40STUDY',
                      style: tt.labelSmall?.copyWith(
                        color: cs.slate500,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      greetingText,
                      style: tt.titleMedium?.copyWith(
                        color: cs.slate900,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Badge(
                backgroundColor: AchievementColors.red,
                smallSize: 8,
                child: IconButton(
                  onPressed: onNotificationTap,
                  icon: Icon(Icons.notifications_outlined, color: cs.slate700),
                ),
              ),
              AppSpacing.hGap8,
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
