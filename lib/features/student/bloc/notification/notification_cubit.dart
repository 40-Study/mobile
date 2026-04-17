import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({required StudentRepository repository})
      : _repository = repository,
        super(const NotificationInitial());

  final StudentRepository _repository;
  int _currentPage = 1;
  static const _pageSize = 20;

  Future<void> loadNotifications({bool? isRead, String? type}) async {
    emit(const NotificationLoading());
    _currentPage = 1;

    try {
      final result = await _repository.getNotifications(
        isRead: isRead,
        type: type,
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(NotificationLoaded(
        notifications: result.notifications,
        unreadCount: result.unreadCount,
        total: result.total,
        hasMore: result.notifications.length >= _pageSize,
      ));
    } catch (e) {
      debugPrint('loadNotifications error: $e');
      emit(NotificationFailure(message: e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! NotificationLoaded || !currentState.hasMore) return;

    _currentPage++;

    try {
      final result = await _repository.getNotifications(
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(currentState.copyWith(
        notifications: [...currentState.notifications, ...result.notifications],
        hasMore: result.notifications.length >= _pageSize,
      ));
    } catch (e) {
      _currentPage--;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markNotificationAsRead(id);

      final currentState = state;
      if (currentState is NotificationLoaded) {
        final updated = currentState.notifications.map((n) {
          if (n.id == id) {
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

        emit(currentState.copyWith(
          notifications: updated,
          unreadCount: currentState.unreadCount > 0
              ? currentState.unreadCount - 1
              : 0,
        ));
      }
    } catch (e) {
      debugPrint('markAsRead error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();

      final currentState = state;
      if (currentState is NotificationLoaded) {
        final updated = currentState.notifications.map((n) {
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
          notifications: updated,
          unreadCount: 0,
        ));
      }
    } catch (e) {
      debugPrint('markAllAsRead error: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);

      final currentState = state;
      if (currentState is NotificationLoaded) {
        final notification = currentState.notifications.firstWhere(
          (n) => n.id == id,
          orElse: () => const NotificationItemModel(id: '', title: ''),
        );
        final updated = currentState.notifications
            .where((n) => n.id != id)
            .toList();

        emit(currentState.copyWith(
          notifications: updated,
          total: currentState.total > 0 ? currentState.total - 1 : 0,
          unreadCount: !notification.isRead && currentState.unreadCount > 0
              ? currentState.unreadCount - 1
              : currentState.unreadCount,
        ));
      }
    } catch (e) {
      debugPrint('deleteNotification error: $e');
    }
  }

  Future<void> refresh() async {
    await loadNotifications();
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadNotificationCount();
      final currentState = state;
      if (currentState is NotificationLoaded) {
        emit(currentState.copyWith(unreadCount: count));
      }
    } catch (e) {
      debugPrint('loadUnreadCount error: $e');
    }
  }
}
