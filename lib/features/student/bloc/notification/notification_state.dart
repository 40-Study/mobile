import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

final class NotificationInProgress extends NotificationState {
  const NotificationInProgress();
}

final class NotificationSuccess extends NotificationState {
  const NotificationSuccess({
    required this.notifications,
    required this.unreadCount,
  });

  final List<NotificationModel> notifications;
  final int unreadCount;

  // Group by day
  List<NotificationModel> get todayList => notifications
      .where((n) => _isToday(n.createdAt))
      .toList();

  List<NotificationModel> get yesterdayList => notifications
      .where((n) => _isYesterday(n.createdAt))
      .toList();

  List<NotificationModel> get olderList => notifications
      .where((n) => !_isToday(n.createdAt) && !_isYesterday(n.createdAt))
      .toList();

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  @override
  List<Object?> get props => [notifications, unreadCount];
}

final class NotificationFailure extends NotificationState {
  const NotificationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
