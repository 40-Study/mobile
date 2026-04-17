part of 'notification_cubit.dart';

@immutable
sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

final class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required this.notifications,
    this.unreadCount = 0,
    this.total = 0,
    this.hasMore = false,
  });

  final List<NotificationItemModel> notifications;
  final int unreadCount;
  final int total;
  final bool hasMore;

  NotificationLoaded copyWith({
    List<NotificationItemModel>? notifications,
    int? unreadCount,
    int? total,
    bool? hasMore,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount, total, hasMore];
}

final class NotificationFailure extends NotificationState {
  const NotificationFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
