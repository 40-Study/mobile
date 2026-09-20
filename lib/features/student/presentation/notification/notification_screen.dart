import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/notification/notification_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_event.dart';
import 'package:study/features/student/bloc/notification/notification_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/theme/theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(diContainer<StudentRepository>())
        ..add(const NotificationStarted()),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Thông báo'),
        centerTitle: false,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationSuccess && state.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () => context
                      .read<NotificationBloc>()
                      .add(const NotificationMarkedAllRead()),
                  icon: Icon(Icons.done_all, size: 18, color: cs.primary),
                  label: Text(
                    'Đọc tất cả',
                    style: tt.labelMedium?.copyWith(color: cs.primary),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationInProgress) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          if (state is NotificationFailure) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<NotificationBloc>()
                  .add(const NotificationStarted()),
            );
          }

          if (state is NotificationSuccess) {
            if (state.notifications.isEmpty) {
              return const _EmptyView();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const NotificationStarted());
                await Future<void>.delayed(const Duration(milliseconds: 500));
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  if (state.todayList.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Hôm nay',
                      count: state.todayList.where((n) => !n.isRead).length,
                    ),
                    ...state.todayList.map((n) => _NotificationTile(notification: n)),
                  ],
                  if (state.yesterdayList.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Hôm qua',
                      count: state.yesterdayList.where((n) => !n.isRead).length,
                    ),
                    ...state.yesterdayList.map((n) => _NotificationTile(notification: n)),
                  ],
                  if (state.olderList.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Trước đó',
                      count: state.olderList.where((n) => !n.isRead).length,
                    ),
                    ...state.olderList.map((n) => _NotificationTile(notification: n)),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 40,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Không có thông báo',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn sẽ nhận được thông báo khi có cập nhật mới về khóa học, bài tập hoặc sự kiện.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_problem, color: cs.onErrorContainer),
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải thông báo',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.count = 0});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: tt.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: tt.labelSmall?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final typeColor = _getTypeColor(notification.type, cs);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: cs.error,
        child: Icon(Icons.delete_outline, color: cs.onError),
      ),
      onDismissed: (_) {
        // TODO: Add delete notification event
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            context
                .read<NotificationBloc>()
                .add(NotificationMarkedRead(notification.id));
          }
          // TODO: Navigate based on actionUrl
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: notification.isRead ? null : cs.primaryContainer.withValues(alpha: 0.15),
            border: Border(
              bottom: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _getTypeIcon(notification.type),
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(notification.createdAt),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return '${time.day}/${time.month}';
  }

  IconData _getTypeIcon(NotificationType type) {
    return switch (type) {
      NotificationType.course => Icons.school_rounded,
      NotificationType.assignment => Icons.assignment_rounded,
      NotificationType.livestream => Icons.videocam_rounded,
      NotificationType.system => Icons.info_rounded,
      NotificationType.achievement => Icons.emoji_events_rounded,
    };
  }

  Color _getTypeColor(NotificationType type, ColorScheme cs) {
    return switch (type) {
      NotificationType.course => cs.primary,
      NotificationType.assignment => cs.tertiary,
      NotificationType.livestream => cs.secondary,
      NotificationType.system => cs.onSurfaceVariant,
      NotificationType.achievement => Colors.amber.shade700,
    };
  }
}
