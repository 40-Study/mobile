import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/models/models.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  final TeacherNotificationModel notification;
  final VoidCallback? onTap;

  Color _getIndicatorColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (notification.type.toLowerCase()) {
      case 'assignment':
        return cs.primary;
      case 'finance':
        return Colors.green;
      case 'system':
        return cs.tertiary;
      default:
        return cs.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: _getIndicatorColor(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${notification.createdAt ?? ''} • ${notification.subtitle ?? ''}',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
