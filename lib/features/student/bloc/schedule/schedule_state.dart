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
    this.dailyNotes = const {},
  });

  final DateTime currentMonth;
  final DateTime selectedDate;
  final Set<DateTime> eventDates;
  final List<ScheduleItemModel> selectedDateItems;
  final bool isLoadingDay;
  final Map<String, String> dailyNotes; // key: "yyyy-MM-dd", value: note

  /// Get note for a specific date
  String? getNoteForDate(DateTime date) {
    final key = dateKey(date);
    return dailyNotes[key];
  }

  /// Check if date has note
  bool hasNote(DateTime date) {
    return dailyNotes.containsKey(dateKey(date));
  }

  static String dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        currentMonth,
        selectedDate,
        eventDates,
        selectedDateItems,
        isLoadingDay,
        dailyNotes,
      ];

  ScheduleSuccess copyWith({
    DateTime? currentMonth,
    DateTime? selectedDate,
    Set<DateTime>? eventDates,
    List<ScheduleItemModel>? selectedDateItems,
    bool? isLoadingDay,
    Map<String, String>? dailyNotes,
  }) {
    return ScheduleSuccess(
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      eventDates: eventDates ?? this.eventDates,
      selectedDateItems: selectedDateItems ?? this.selectedDateItems,
      isLoadingDay: isLoadingDay ?? this.isLoadingDay,
      dailyNotes: dailyNotes ?? this.dailyNotes,
    );
  }
}

final class ScheduleFailure extends ScheduleState {
  const ScheduleFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
