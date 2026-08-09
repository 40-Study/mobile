import 'package:equatable/equatable.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationStarted extends NotificationEvent {
  const NotificationStarted();
}

final class NotificationMarkedRead extends NotificationEvent {
  const NotificationMarkedRead(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class NotificationMarkedAllRead extends NotificationEvent {
  const NotificationMarkedAllRead();
}
