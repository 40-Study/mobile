import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/leave/teacher_leave_list_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherNotificationsScreen extends StatefulWidget {
  const TeacherNotificationsScreen({super.key, required this.api});
  final TeacherApi api;

  @override
  State<TeacherNotificationsScreen> createState() =>
      _TeacherNotificationsScreenState();
}

class _TeacherNotificationsScreenState
    extends State<TeacherNotificationsScreen> {
  late Future<List<TeacherNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<TeacherNotification>> _load() async {
    final raw = await widget.api.get('/me/notifications');
    final list = teacherList(teacherMap(raw), keys: const ['notifications']);
    return list.map((e) => TeacherNotification.fromJson(e)).toList();
  }

  void _reload() => setState(() => _future = _load());

  /// Mark notification as read via swipe
  Future<bool> _markAsRead(TeacherNotification notif) async {
    try {
      await widget.api.post('/me/notifications/${notif.id}/read');
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu đã đọc'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false; // Không dismiss item, chỉ reload
    } catch (_) {
      // Mock API không hỗ trợ - vẫn reload UI
      _reload();
      return false;
    }
  }

  Future<void> _onTap(TeacherNotification notif) async {
    // Mark as read (nếu API hỗ trợ)
    try {
      await widget.api.post('/me/notifications/${notif.id}/read');
    } catch (_) {
      // Mock API không hỗ trợ write
    }

    if (!mounted) return;

    // Deep link theo type
    switch (notif.type) {
      case 'upcoming_session':
      case 'needs_completion':
      case 'schedule_changed':
      case 'confirmation_feedback':
        final sessionId = notif.payload?['session_id']?.toString();
        final classId = notif.payload?['class_id']?.toString() ?? '';
        if (sessionId != null) {
          await teacherPush<void>(
            context,
            TeacherSessionScreen(
              api: widget.api,
              sessionId: sessionId,
              classId: classId,
              workplaceLabel: '',
            ),
          );
          _reload();
        }
        break;
      case 'leave_result':
        // Navigate to leave list (user có thể tìm đơn trong đó)
        await teacherPush<void>(
          context,
          TeacherLeaveListScreen(api: widget.api),
        );
        _reload();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: FutureBuilder<List<TeacherNotification>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TeacherErrorView(
              error: snapshot.error!,
              onRetry: _reload,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;
          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          // Group by date
          final grouped = _groupByDate(notifications);

          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _future;
            },
            child: ListView.builder(
              padding: AppSpacing.paddingScreenAll,
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final group = grouped[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 0) const SizedBox(height: 16),
                    Text(
                      group.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    for (final notif in group.notifications)
                      TeacherSwipeToAction(
                        itemKey: Key('notif_${notif.id}'),
                        icon: Icons.mark_email_read_outlined,
                        label: 'Đã đọc',
                        color: AchievementColors.green,
                        enabled: !notif.isRead,
                        onAction: () => _markAsRead(notif),
                        child: _NotificationItem(
                          notification: notif,
                          onTap: () => _onTap(notif),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const TeacherEmptyState(
      icon: Icons.notifications_none_outlined,
      title: 'Chưa có thông báo',
      subtitle: 'Thông báo về lịch dạy và cập nhật sẽ hiện ở đây.',
    );
  }

  List<_NotificationGroup> _groupByDate(List<TeacherNotification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayList = <TeacherNotification>[];
    final yesterdayList = <TeacherNotification>[];
    final olderList = <TeacherNotification>[];

    for (final notif in notifications) {
      final notifDate = DateTime(
        notif.createdAt.year,
        notif.createdAt.month,
        notif.createdAt.day,
      );
      if (notifDate == today) {
        todayList.add(notif);
      } else if (notifDate == yesterday) {
        yesterdayList.add(notif);
      } else {
        olderList.add(notif);
      }
    }

    return [
      if (todayList.isNotEmpty)
        _NotificationGroup(label: 'Hôm nay', notifications: todayList),
      if (yesterdayList.isNotEmpty)
        _NotificationGroup(label: 'Hôm qua', notifications: yesterdayList),
      if (olderList.isNotEmpty)
        _NotificationGroup(label: 'Trước đó', notifications: olderList),
    ];
  }
}

class _NotificationGroup {
  const _NotificationGroup({required this.label, required this.notifications});
  final String label;
  final List<TeacherNotification> notifications;
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.notification, required this.onTap});
  final TeacherNotification notification;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.type) {
      case 'upcoming_session':
        return Icons.calendar_today_outlined;
      case 'needs_completion':
        return Icons.warning_amber_outlined;
      case 'schedule_changed':
        return Icons.swap_horiz_outlined;
      case 'leave_result':
        return Icons.event_busy_outlined;
      case 'confirmation_feedback':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (notification.type) {
      case 'needs_completion':
        return AchievementColors.red;
      case 'confirmation_feedback':
        return AchievementColors.green;
      case 'leave_result':
        return AchievementColors.yellow;
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isUnread = !notification.isRead;
    final iconColor = _iconColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isUnread
              ? cs.primaryContainer.withValues(alpha: 0.15)
              : cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isUnread
                ? cs.primary.withValues(alpha: 0.3)
                : cs.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF010120).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.borderMd,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Icon(_icon, size: 20, color: iconColor),
                  ),
                  AppSpacing.hGap12,
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
                                  fontWeight:
                                      isUnread ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.primary.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        AppSpacing.vGap4,
                        Text(
                          notification.body,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGap4,
                        Text(
                          DateFormat('HH:mm').format(notification.createdAt),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: cs.onSurfaceVariant,
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

/// Model for notification
class TeacherNotification {
  const TeacherNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.payload,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? payload;

  factory TeacherNotification.fromJson(Map<String, dynamic> json) {
    return TeacherNotification(
      id: '${json['id']}',
      type: '${json['type']}',
      title: '${json['title']}',
      body: '${json['body']}',
      createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      isRead: json['is_read'] == true,
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : null,
    );
  }
}
