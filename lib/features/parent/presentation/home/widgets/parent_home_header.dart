import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

/// Header Parent Home: icon gia đình + greeting + chuông + avatar.
class ParentHomeHeader extends StatelessWidget {
  const ParentHomeHeader({
    super.key,
    this.onNotificationTap,
    this.onAvatarTap,
  });

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

        return Padding(
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
                  color: Color(0xFFEBF3FF),
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
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chào buổi sáng, Gia đình!',
                      style: tt.titleMedium?.copyWith(
                        color: cs.slate900,
                        fontWeight: FontWeight.w700,
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
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: cs.slate700,
                  ),
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
