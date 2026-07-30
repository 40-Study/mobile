import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

final class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

final class ScheduleInProgress extends ScheduleState {
  const ScheduleInProgress();
}

final class ScheduleSuccess extends ScheduleState {
  const ScheduleSuccess({
    required this.currentMonth,
    required this.selectedDate,
    this.eventDates = const {},
    this.selectedDateItems = const [],
    this.isLoadingDay = false,
  });

  final DateTime currentMonth;
  final DateTime selectedDate;
  final Set<DateTime> eventDates; // Days that have events
  final List<ScheduleItemModel> selectedDateItems;
  final bool isLoadingDay;

  @override
  List<Object?> get props => [
        currentMonth,
        selectedDate,
        eventDates,
        selectedDateItems,
        isLoadingDay,
      ];

  ScheduleSuccess copyWith({
    DateTime? currentMonth,
    DateTime? selectedDate,
    Set<DateTime>? eventDates,
    List<ScheduleItemModel>? selectedDateItems,
    bool? isLoadingDay,
  }) {
    return ScheduleSuccess(
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      eventDates: eventDates ?? this.eventDates,
      selectedDateItems: selectedDateItems ?? this.selectedDateItems,
      isLoadingDay: isLoadingDay ?? this.isLoadingDay,
    );
  }
}

final class ScheduleFailure extends ScheduleState {
  const ScheduleFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
