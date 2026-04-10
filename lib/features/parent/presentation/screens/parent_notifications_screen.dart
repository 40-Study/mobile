import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/screens/parent_main_screen.dart';
import 'package:study/theme/app_colors.dart';

class ParentNotificationsScreen extends StatefulWidget {
  const ParentNotificationsScreen({super.key});

  @override
  State<ParentNotificationsScreen> createState() =>
      _ParentNotificationsScreenState();
}

class _ParentNotificationsScreenState extends State<ParentNotificationsScreen> {
  String _selectedFilter = 'all';

  // Mock notifications - replace with actual data from repository
  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      id: '1',
      title: 'Nguyễn Văn B vắng buổi học',
      message: 'Con bạn đã vắng buổi học Toán ngày 23/03/2024',
      type: NotificationType.attendance,
      createdAt: '2 giờ trước',
      childName: 'Nguyễn Văn B',
      isRead: false,
    ),
    _NotificationItem(
      id: '2',
      title: 'Điểm bài kiểm tra Toán',
      message: 'Nguyễn Thị C đạt điểm 10 bài kiểm tra Toán',
      type: NotificationType.performance,
      createdAt: 'Hôm qua',
      childName: 'Nguyễn Thị C',
      isRead: false,
    ),
    _NotificationItem(
      id: '3',
      title: 'Học phí tháng 4 sắp đến hạn',
      message: 'Học phí tháng 4/2024 sẽ đến hạn vào ngày 15/04',
      type: NotificationType.finance,
      createdAt: '2 ngày trước',
      isRead: true,
    ),
    _NotificationItem(
      id: '4',
      title: 'Bài tập mới được giao',
      message: 'Nguyễn Văn B có bài tập Toán mới cần hoàn thành',
      type: NotificationType.assignment,
      createdAt: '3 ngày trước',
      childName: 'Nguyễn Văn B',
      isRead: true,
    ),
    _NotificationItem(
      id: '5',
      title: 'Lớp học trực tuyến sắp bắt đầu',
      message: 'Lớp Anh Văn sẽ bắt đầu lúc 14:00 hôm nay',
      type: NotificationType.liveClass,
      createdAt: '1 tuần trước',
      childName: 'Nguyễn Thị C',
      isRead: true,
    ),
  ];

  List<_NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'all') return _notifications;
    if (_selectedFilter == 'unread') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications
        .where((n) => n.type.name == _selectedFilter)
        .toList();
  }

  void _handleNotificationTap(_NotificationItem notification) {
    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.attendance:
        ParentMainScreen.switchToTab(context, ParentMainScreen.tabTracking);
        break;
      case NotificationType.finance:
        ParentMainScreen.switchToTab(context, ParentMainScreen.tabFinance);
        break;
      case NotificationType.assignment:
      case NotificationType.performance:
        ParentMainScreen.switchToTab(context, ParentMainScreen.tabTracking);
        break;
      case NotificationType.liveClass:
        // TODO: Navigate to live class
        break;
      case NotificationType.general:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppLayout.screenMargin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông báo',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                      ),
                      if (unreadCount > 0)
                        Text(
                          '$unreadCount thông báo chưa đọc',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (var n in _notifications) {
                          n.isRead = true;
                        }
                      });
                    },
                    child: const Text('Đọc tất cả'),
                  ),
                ],
              ),
            ),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
                children: [
                  _FilterChip(
                    label: 'Tất cả',
                    isSelected: _selectedFilter == 'all',
                    onTap: () => setState(() => _selectedFilter = 'all'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: 'Chưa đọc',
                    isSelected: _selectedFilter == 'unread',
                    onTap: () => setState(() => _selectedFilter = 'unread'),
                    badge: unreadCount > 0 ? unreadCount : null,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: 'Bài tập',
                    isSelected: _selectedFilter == 'assignment',
                    onTap: () => setState(() => _selectedFilter = 'assignment'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: 'Điểm danh',
                    isSelected: _selectedFilter == 'attendance',
                    onTap: () => setState(() => _selectedFilter = 'attendance'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: 'Tài chính',
                    isSelected: _selectedFilter == 'finance',
                    onTap: () => setState(() => _selectedFilter = 'finance'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Notifications list
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: cs.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Không có thông báo nào',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: cs.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppLayout.screenMargin,
                      ),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _NotificationCard(
                            notification: notification,
                            onTap: () => _handleNotificationTap(notification),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.childName,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String createdAt;
  final String? childName;
  bool isRead;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? cs.onPrimary : cs.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.onPrimary.withValues(alpha: 0.2)
                      : cs.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge.toString(),
                  style: TextStyle(
                    color: isSelected ? cs.onPrimary : cs.onError,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final _NotificationItem notification;
  final VoidCallback onTap;

  IconData get _typeIcon {
    switch (notification.type) {
      case NotificationType.attendance:
        return Icons.event_available;
      case NotificationType.assignment:
        return Icons.assignment;
      case NotificationType.finance:
        return Icons.account_balance_wallet;
      case NotificationType.performance:
        return Icons.grade;
      case NotificationType.liveClass:
        return Icons.videocam;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color _typeColor(ColorScheme cs) {
    switch (notification.type) {
      case NotificationType.attendance:
        return Colors.orange;
      case NotificationType.assignment:
        return cs.primary;
      case NotificationType.finance:
        return Colors.green;
      case NotificationType.performance:
        return Colors.purple;
      case NotificationType.liveClass:
        return Colors.red;
      case NotificationType.general:
        return cs.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _typeColor(cs);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: notification.isRead
              ? cs.surfaceContainerLowest
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? cs.outlineVariant.withValues(alpha: 0.3)
                : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w700,
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
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: cs.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (notification.childName != null) ...[
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: cs.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification.childName!,
                          style: TextStyle(
                            color: cs.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: cs.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notification.createdAt,
                        style: TextStyle(
                          color: cs.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: cs.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
