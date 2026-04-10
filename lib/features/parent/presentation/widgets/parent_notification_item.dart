import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

class ParentNotificationItem extends StatelessWidget {
  const ParentNotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  final ParentNotificationModel notification;
  final VoidCallback? onTap;

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.attendance:
        return Icons.event_busy;
      case NotificationType.performance:
        return Icons.star;
      case NotificationType.assignment:
        return Icons.assignment;
      case NotificationType.finance:
        return Icons.account_balance_wallet;
      case NotificationType.liveClass:
        return Icons.videocam;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color _getIconColor(ColorScheme cs) {
    switch (notification.type) {
      case NotificationType.attendance:
        return cs.error;
      case NotificationType.performance:
        return cs.tertiary;
      case NotificationType.assignment:
        return cs.primary;
      case NotificationType.finance:
        return Colors.green;
      case NotificationType.liveClass:
        return Colors.red;
      case NotificationType.general:
        return cs.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getIconColor(cs).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIcon(),
                  size: 20,
                  color: _getIconColor(cs),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            notification.isRead ? FontWeight.normal : FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.createdAt!,
                        style: textTheme.labelSmall?.copyWith(
                          color: cs.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
