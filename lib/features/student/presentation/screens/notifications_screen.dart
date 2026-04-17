import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/notifications/notifications_cubit.dart';
import 'package:study/features/student/bloc/notifications/notifications_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/index.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsCubit(
        repository: context.read<StudentRepository>(),
      )..loadNotifications(),
      child: const _NotificationsScreenContent(),
    );
  }
}

class _NotificationsScreenContent extends StatelessWidget {
  const _NotificationsScreenContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thong bao'),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () =>
                      context.read<NotificationsCubit>().markAllAsRead(),
                  child: const Text('Doc tat ca'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return switch (state) {
            NotificationsInitial() ||
            NotificationsLoading() =>
              const Center(child: CircularProgressIndicator()),
            NotificationsLoaded() => state.notifications.isEmpty
                ? _buildEmptyState(context)
                : _buildNotificationsList(context, state),
            NotificationsError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(message),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () =>
                          context.read<NotificationsCubit>().loadNotifications(),
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 80, color: cs.outline),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Khong co thong bao',
            style: tt.titleLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Cac thong bao moi se xuat hien o day',
            style: tt.bodyMedium?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, NotificationsLoaded state) {
    return Column(
      children: [
        // Filter chips
        _FilterChips(
          selectedType: state.selectedType,
          onTypeChanged: (type) {
            context.read<NotificationsCubit>().filterByType(type);
          },
        ),

        // Notifications list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<NotificationsCubit>().refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: state.filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = state.filteredNotifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () => _handleNotificationTap(context, notification),
                  onDismiss: () => context
                      .read<NotificationsCubit>()
                      .deleteNotification(notification.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationItemModel notification) {
    if (!notification.isRead) {
      context.read<NotificationsCubit>().markAsRead(notification.id);
    }

    // Navigate based on notification type
    // TODO: Implement navigation based on actionType and referenceId
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedType,
    required this.onTypeChanged,
  });

  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;

  static const _types = [
    ('course', 'Khoa hoc'),
    ('assignment', 'Bai tap'),
    ('livestream', 'Livestream'),
    ('achievement', 'Thanh tich'),
    ('promotion', 'Khuyen mai'),
    ('system', 'He thong'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Tat ca'),
            selected: selectedType == null,
            onSelected: (_) => onTypeChanged(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          ..._types.map((t) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(t.$2),
                  selected: selectedType == t.$1,
                  onSelected: (_) => onTypeChanged(t.$1),
                ),
              )),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationItemModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  IconData get _icon {
    switch (notification.type) {
      case 'course':
        return Icons.school;
      case 'assignment':
        return Icons.assignment;
      case 'livestream':
        return Icons.live_tv;
      case 'achievement':
        return Icons.emoji_events;
      case 'promotion':
        return Icons.local_offer;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _iconColor(ColorScheme cs) {
    switch (notification.type) {
      case 'course':
        return cs.primary;
      case 'assignment':
        return cs.tertiary;
      case 'livestream':
        return cs.error;
      case 'achievement':
        return cs.secondary;
      case 'promotion':
        return cs.primaryContainer;
      case 'system':
        return cs.outline;
      default:
        return cs.outline;
    }
  }

  String get _timeAgo {
    final dateStr = notification.createdAt;
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';

    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} ngay truoc';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} gio truoc';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phut truoc';
    }
    return 'Vua xong';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _iconColor(cs);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.error.withOpacity(0.8), cs.error],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              'Xoa',
              style: tt.bodySmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: notification.isRead ? cs.surface : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? cs.outline.withOpacity(0.1)
                : color.withOpacity(0.2),
            width: notification.isRead ? 1 : 2,
          ),
          boxShadow: !notification.isRead
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon with gradient background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_icon, color: color, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color, color.withOpacity(0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (notification.body != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            notification.body!,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: cs.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _timeAgo,
                              style: tt.bodySmall?.copyWith(
                                color: cs.outline,
                                fontSize: 11,
                              ),
                            ),
                            const Spacer(),
                            if (!notification.isRead)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Moi',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
