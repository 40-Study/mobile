import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.selectedType,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.page = 1,
  });

  final List<NotificationItemModel> notifications;
  final int unreadCount;
  final String? selectedType;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final int page;

  /// Loc theo loai.
  List<NotificationItemModel> get filteredNotifications {
    if (selectedType == null) return notifications;
    return notifications.where((n) => n.type == selectedType).toList();
  }

  /// Nhom theo ngay.
  Map<String, List<NotificationItemModel>> get groupedByDate {
    final map = <String, List<NotificationItemModel>>{};
    for (final notification in filteredNotifications) {
      final key = _getDateKey(notification.createdAt);
      map.putIfAbsent(key, () => []).add(notification);
    }
    return map;
  }

  String _getDateKey(String? dateStr) {
    if (dateStr == null) return 'Truoc do';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return 'Truoc do';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) return 'Hom nay';
    if (notificationDate == yesterday) return 'Hom qua';
    if (now.difference(date).inDays < 7) return 'Tuan nay';
    return 'Truoc do';
  }

  NotificationsLoaded copyWith({
    List<NotificationItemModel>? notifications,
    int? unreadCount,
    String? selectedType,
    bool? isLoadingMore,
    bool? hasReachedMax,
    int? page,
    bool clearType = false,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        selectedType,
        isLoadingMore,
        hasReachedMax,
        page,
      ];
}

final class NotificationsError extends NotificationsState {
  const NotificationsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
