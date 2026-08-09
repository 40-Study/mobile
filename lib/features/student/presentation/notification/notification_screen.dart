import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_event.dart';
import 'package:study/features/student/bloc/notification/notification_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc()..add(const NotificationStarted()),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thong bao'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationSuccess && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () => context
                      .read<NotificationBloc>()
                      .add(const NotificationMarkedAllRead()),
                  child: Text(
                    'Doc tat ca',
                    style: TextStyle(color: cs.primary),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationInProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationFailure) {
            return Center(child: Text(state.message));
          }

          if (state is NotificationSuccess) {
            if (state.notifications.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_off_outlined,
                title: 'Khong co thong bao',
                message: 'Ban chua co thong bao nao',
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                if (state.todayList.isNotEmpty) ...[
                  _SectionHeader(title: 'Hom nay'),
                  ...state.todayList.map((n) => _NotificationItem(notification: n)),
                ],
                if (state.yesterdayList.isNotEmpty) ...[
                  _SectionHeader(title: 'Hom qua'),
                  ...state.yesterdayList.map((n) => _NotificationItem(notification: n)),
                ],
                if (state.olderList.isNotEmpty) ...[
                  _SectionHeader(title: 'Truoc do'),
                  ...state.olderList.map((n) => _NotificationItem(notification: n)),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: tt.labelLarge?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: () {
        if (!notification.isRead) {
          context
              .read<NotificationBloc>()
              .add(NotificationMarkedRead(notification.id));
        }
      },
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _getTypeColor(notification.type, cs).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getTypeIcon(notification.type),
          color: _getTypeColor(notification.type, cs),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              notification.title,
              style: tt.bodyMedium?.copyWith(
                fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
              ),
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
      subtitle: Text(
        notification.body,
        style: tt.bodySmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.course:
        return Icons.school_outlined;
      case NotificationType.assignment:
        return Icons.assignment_outlined;
      case NotificationType.livestream:
        return Icons.videocam_outlined;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.achievement:
        return Icons.emoji_events_outlined;
    }
  }

  Color _getTypeColor(NotificationType type, ColorScheme cs) {
    switch (type) {
      case NotificationType.course:
        return cs.primary;
      case NotificationType.assignment:
        return cs.tertiary;
      case NotificationType.livestream:
        return cs.secondary;
      case NotificationType.system:
        return cs.onSurfaceVariant;
      case NotificationType.achievement:
        return Colors.amber;
    }
  }
}
