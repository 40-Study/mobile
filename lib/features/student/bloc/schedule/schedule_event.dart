import 'package:equatable/equatable.dart';

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

final class ScheduleStarted extends ScheduleEvent {
  const ScheduleStarted();
}

final class ScheduleDateSelected extends ScheduleEvent {
  const ScheduleDateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

final class ScheduleMonthChanged extends ScheduleEvent {
  const ScheduleMonthChanged(this.month);

  final DateTime month;

  @override
  List<Object?> get props => [month];
}

final class ScheduleNoteSaved extends ScheduleEvent {
  const ScheduleNoteSaved({required this.date, required this.note});

  final DateTime date;
  final String note;

  @override
  List<Object?> get props => [date, note];
}

final class ScheduleNoteDeleted extends ScheduleEvent {
  const ScheduleNoteDeleted(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}
