import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/notifications/notifications_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({required StudentRepository repository})
      : _repository = repository,
        super(const NotificationsInitial());

  final StudentRepository _repository;

  /// Tai danh sach thong bao.
  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    try {
      final results = await Future.wait([
        _repository.getNotifications(),
        _repository.getUnreadNotificationCount(),
      ]);

      final notificationList = results[0] as NotificationListModel;
      emit(NotificationsLoaded(
        notifications: notificationList.notifications,
        unreadCount: results[1] as int,
      ));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Lam moi.
  Future<void> refresh() async {
    final currentState = state;
    try {
      final results = await Future.wait([
        _repository.getNotifications(),
        _repository.getUnreadNotificationCount(),
      ]);

      final notificationList = results[0] as NotificationListModel;
      if (currentState is NotificationsLoaded) {
        emit(currentState.copyWith(
          notifications: notificationList.notifications,
          unreadCount: results[1] as int,
          page: 1,
          hasReachedMax: false,
        ));
      } else {
        emit(NotificationsLoaded(
          notifications: notificationList.notifications,
          unreadCount: results[1] as int,
        ));
      }
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Loc theo loai.
  void filterByType(String? type) {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;
    emit(currentState.copyWith(
      selectedType: type,
      clearType: type == null,
    ));
  }

  /// Danh dau da doc.
  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    try {
      await _repository.markNotificationAsRead(notificationId);

      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == notificationId) {
          return NotificationItemModel(
            id: n.id,
            title: n.title,
            body: n.body,
            type: n.type,
            isRead: true,
            actionUrl: n.actionUrl,
            actionType: n.actionType,
            referenceId: n.referenceId,
            data: n.data,
            createdAt: n.createdAt,
            readAt: DateTime.now().toIso8601String(),
          );
        }
        return n;
      }).toList();

      final newUnreadCount = currentState.unreadCount > 0
          ? currentState.unreadCount - 1
          : 0;

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      // Silent fail
    }
  }

  /// Danh dau tat ca da doc.
  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    try {
      await _repository.markAllNotificationsAsRead();

      final updatedNotifications = currentState.notifications.map((n) {
        return NotificationItemModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          actionUrl: n.actionUrl,
          actionType: n.actionType,
          referenceId: n.referenceId,
          data: n.data,
          createdAt: n.createdAt,
          readAt: DateTime.now().toIso8601String(),
        );
      }).toList();

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));
    } catch (e) {
      // Silent fail
    }
  }

  /// Xoa thong bao.
  Future<void> deleteNotification(String notificationId) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    try {
      await _repository.deleteNotification(notificationId);

      final notification = currentState.notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => throw Exception('Not found'),
      );

      final updatedNotifications = currentState.notifications
          .where((n) => n.id != notificationId)
          .toList();

      final newUnreadCount = !notification.isRead && currentState.unreadCount > 0
          ? currentState.unreadCount - 1
          : currentState.unreadCount;

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      // Silent fail
    }
  }

  /// Tai them.
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! NotificationsLoaded ||
        currentState.isLoadingMore ||
        currentState.hasReachedMax) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.page + 1;
      final moreNotifications = await _repository.getNotifications(page: nextPage);

      if (moreNotifications.notifications.isEmpty) {
        emit(currentState.copyWith(isLoadingMore: false, hasReachedMax: true));
      } else {
        emit(currentState.copyWith(
          notifications: [...currentState.notifications, ...moreNotifications.notifications],
          isLoadingMore: false,
          page: nextPage,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
