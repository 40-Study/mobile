import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_event.dart';
import 'package:study/features/student/bloc/notification/notification_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._repository) : super(const NotificationInitial()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationMarkedAllRead>(_onMarkedAllRead);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(
    NotificationStarted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationInProgress());

    final result = await _repository.getNotifications();

    result.when(
      success: (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        emit(NotificationSuccess(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
      failure: (failure) {
        emit(NotificationFailure(failure.message ?? 'Đã có lỗi xảy ra'));
      },
    );
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationSuccess) return;

    // Optimistic update
    final updated = current.notifications.map((n) {
      if (n.id == event.id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final unreadCount = updated.where((n) => !n.isRead).length;
    emit(NotificationSuccess(notifications: updated, unreadCount: unreadCount));

    // Call API
    await _repository.markNotificationRead(event.id);
  }

  Future<void> _onMarkedAllRead(
    NotificationMarkedAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationSuccess) return;

    // Optimistic update
    final updated = current.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(NotificationSuccess(notifications: updated, unreadCount: 0));

    // Call API
    await _repository.markAllNotificationsRead();
  }
}
