import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_event.dart';
import 'package:study/features/student/bloc/notification/notification_state.dart';
import 'package:study/features/student/data/models/models.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationInitial()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationMarkedAllRead>(_onMarkedAllRead);
  }

  Future<void> _onStarted(
    NotificationStarted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationInProgress());

    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Mock data
    final now = DateTime.now();
    final notifications = [
      NotificationModel(
        id: '1',
        title: 'Bai hoc moi',
        body: 'Khoa hoc Flutter da cap nhat bai hoc moi',
        type: NotificationType.course,
        createdAt: now,
      ),
      NotificationModel(
        id: '2',
        title: 'Livestream sap dien ra',
        body: 'Buoi hoc truc tuyen bat dau luc 14:00',
        type: NotificationType.livestream,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '3',
        title: 'Deadline sap toi',
        body: 'Bai tap "React Hooks" het han trong 2 ngay',
        type: NotificationType.assignment,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '4',
        title: 'Huy hieu moi',
        body: 'Ban da dat duoc huy hieu "7 ngay streak"',
        type: NotificationType.achievement,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    final unreadCount = notifications.where((n) => !n.isRead).length;

    emit(NotificationSuccess(
      notifications: notifications,
      unreadCount: unreadCount,
    ));
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationSuccess) return;

    final updated = current.notifications.map((n) {
      if (n.id == event.id) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
          actionUrl: n.actionUrl,
        );
      }
      return n;
    }).toList();

    final unreadCount = updated.where((n) => !n.isRead).length;

    emit(NotificationSuccess(
      notifications: updated,
      unreadCount: unreadCount,
    ));
  }

  Future<void> _onMarkedAllRead(
    NotificationMarkedAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationSuccess) return;

    final updated = current.notifications.map((n) {
      return NotificationModel(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
        actionUrl: n.actionUrl,
      );
    }).toList();

    emit(NotificationSuccess(
      notifications: updated,
      unreadCount: 0,
    ));
  }
}
