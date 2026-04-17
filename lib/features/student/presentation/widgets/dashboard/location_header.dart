import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';

/// Simple header with greeting and action icons
/// Together AI Design - clean, minimal
class LocationHeader extends StatelessWidget {
  const LocationHeader({
    super.key,
    this.greeting,
    this.onNotificationTap,
    this.onCartTap,
    this.notificationCount = 0,
    this.cartCount = 0,
  });

  final String? greeting;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final int notificationCount;
  final int cartCount;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chao buoi sang';
    if (hour < 18) return 'Chao buoi chieu';
    return 'Chao buoi toi';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting ?? _getGreeting(),
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Chuc ban hoc tot!',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        // Cart icon
        GestureDetector(
          onTap: onCartTap,
          child: _IconWithBadge(
            icon: Icons.shopping_cart_outlined,
            count: cartCount,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Notification icon
        GestureDetector(
          onTap: onNotificationTap,
          child: _IconWithBadge(
            icon: Icons.notifications_none_rounded,
            count: notificationCount,
          ),
        ),
      ],
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({
    required this.icon,
    required this.count,
  });

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: AppIconSize.avatar,
          height: AppIconSize.avatar,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8), // Together AI: comfortable radius
            border: Border.all(
              color: cs.outline,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: cs.onSurface,
            size: 22,
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: TextStyle(
                  color: cs.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
