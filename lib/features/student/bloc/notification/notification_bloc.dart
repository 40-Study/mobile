import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/student/bloc/notification/notification_event.dart';
import 'package:study/features/student/bloc/notification/notification_state.dart';
import 'package:study/features/student/data/models/notification_model.dart';
import 'package:study/features/student/repository/student_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._repository) : super(const NotificationInitial()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationMarkedAllRead>(_onMarkedAllRead);
    on<NotificationLoadMore>(_onLoadMore);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(
    NotificationStarted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationInProgress());

    // Fetch notifications và unread count song song
    final results = await Future.wait([
      _repository.getNotifications(),
      _repository.getUnreadNotificationCount(),
    ]);

    final notifResult = results[0] as ApiResult<({List<NotificationModel> items, bool hasMore})>;
    final countResult = results[1] as ApiResult<int>;

    notifResult.when(
      success: (data) {
        // Dùng server count, fallback sang local count
        final unreadCount = countResult.valueOrNull ??
            data.items.where((n) => !n.isRead).length;
        emit(NotificationSuccess(
          notifications: data.items,
          unreadCount: unreadCount,
          hasMore: data.hasMore,
          currentPage: 1,
        ));
      },
      failure: (failure) {
        emit(NotificationFailure(failure.message ?? 'Đã có lỗi xảy ra'));
      },
    );
  }

  Future<void> _onLoadMore(
    NotificationLoadMore event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationSuccess) return;
    if (current.isLoadingMore || !current.hasMore) return; // Prevent duplicate

    emit(NotificationSuccess(
      notifications: current.notifications,
      unreadCount: current.unreadCount,
      pendingIds: current.pendingIds,
      isMarkAllPending: current.isMarkAllPending,
      hasMore: current.hasMore,
      isLoadingMore: true,
      currentPage: current.currentPage,
    ));

    final nextPage = current.currentPage + 1;
    final result = await _repository.getNotifications(page: nextPage);

    final latestState = state;
    if (latestState is! NotificationSuccess) return;

    result.when(
      success: (data) {
        emit(NotificationSuccess(
          notifications: [...latestState.notifications, ...data.items],
          unreadCount: latestState.unreadCount,
          pendingIds: latestState.pendingIds,
          isMarkAllPending: latestState.isMarkAllPending,
          hasMore: data.hasMore,
          isLoadingMore: false,
          currentPage: nextPage,
        ));
      },
      failure: (_) {
        // Load more failed, reset loading state
        emit(NotificationSuccess(
          notifications: latestState.notifications,
          unreadCount: latestState.unreadCount,
          pendingIds: latestState.pendingIds,
          isMarkAllPending: latestState.isMarkAllPending,
          hasMore: latestState.hasMore,
          isLoadingMore: false,
          currentPage: latestState.currentPage,
        ));
      },
    );
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationSuccess) return;
    if (current.pendingIds.contains(event.id)) return; // Đang xử lý

    // Show pending state
    emit(NotificationSuccess(
      notifications: current.notifications,
      unreadCount: current.unreadCount,
      pendingIds: {...current.pendingIds, event.id},
    ));

    // Wait for server confirmation
    final result = await _repository.markNotificationRead(event.id);

    if (result.isSuccess) {
      // Refresh unread count từ server
      final countResult = await _repository.getUnreadNotificationCount();
      final latestState = state;
      if (latestState is! NotificationSuccess) return;

      final newCount = countResult.valueOrNull ?? (latestState.unreadCount - 1);
      final updated = latestState.notifications.map((n) {
        if (n.id == event.id) return n.copyWith(isRead: true);
        return n;
      }).toList();

      emit(NotificationSuccess(
        notifications: updated,
        unreadCount: newCount,
        pendingIds: {...latestState.pendingIds}..remove(event.id),
        isMarkAllPending: latestState.isMarkAllPending,
      ));
    } else {
      // Remove pending, keep current state
      final latestState = state;
      if (latestState is! NotificationSuccess) return;
      emit(NotificationSuccess(
        notifications: latestState.notifications,
        unreadCount: latestState.unreadCount,
        pendingIds: {...latestState.pendingIds}..remove(event.id),
        isMarkAllPending: latestState.isMarkAllPending,
      ));
    }
  }

  Future<void> _onMarkedAllRead(
    NotificationMarkedAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationSuccess) return;
    if (current.isMarkAllPending) return; // Đang xử lý
    if (current.pendingIds.isNotEmpty) return; // Block nếu có item đang pending

    // Show pending state
    emit(NotificationSuccess(
      notifications: current.notifications,
      unreadCount: current.unreadCount,
      pendingIds: current.pendingIds,
      isMarkAllPending: true,
    ));

    // Wait for server confirmation
    final result = await _repository.markAllNotificationsRead();

    final latestState = state;
    if (latestState is! NotificationSuccess) return;

    if (result.isSuccess) {
      final updated = latestState.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      emit(NotificationSuccess(
        notifications: updated,
        unreadCount: 0,
      ));
    } else {
      // Keep current state, clear pending
      emit(NotificationSuccess(
        notifications: latestState.notifications,
        unreadCount: latestState.unreadCount,
      ));
    }
  }
}
