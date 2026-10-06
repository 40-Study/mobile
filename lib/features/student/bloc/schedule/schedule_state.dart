import 'package:equatable/equatable.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
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
    this.classCourseNavigation,
  });

  final DateTime currentMonth;
  final DateTime selectedDate;
  final Set<DateTime> eventDates;
  final List<ScheduleItemModel> selectedDateItems;
  final bool isLoadingDay;
  final Map<String, String> dailyNotes; // key: "yyyy-MM-dd", value: note
  final ScheduleClassCourseNavigation? classCourseNavigation;

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
        classCourseNavigation,
      ];

  ScheduleSuccess copyWith({
    DateTime? currentMonth,
    DateTime? selectedDate,
    Set<DateTime>? eventDates,
    List<ScheduleItemModel>? selectedDateItems,
    bool? isLoadingDay,
    Map<String, String>? dailyNotes,
    ScheduleClassCourseNavigation? classCourseNavigation,
    bool clearNavigation = false,
  }) {
    return ScheduleSuccess(
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      eventDates: eventDates ?? this.eventDates,
      selectedDateItems: selectedDateItems ?? this.selectedDateItems,
      isLoadingDay: isLoadingDay ?? this.isLoadingDay,
      dailyNotes: dailyNotes ?? this.dailyNotes,
      classCourseNavigation: clearNavigation ? null : (classCourseNavigation ?? this.classCourseNavigation),
    );
  }
}

/// Result of class->course lookup for navigation
sealed class ScheduleClassCourseNavigation extends Equatable {
  const ScheduleClassCourseNavigation();
}

final class ScheduleClassCourseNavigationLoading extends ScheduleClassCourseNavigation {
  const ScheduleClassCourseNavigationLoading();

  @override
  List<Object?> get props => [];
}

final class ScheduleClassCourseNavigationSuccess extends ScheduleClassCourseNavigation {
  const ScheduleClassCourseNavigationSuccess(this.enrollment);

  final EnrollmentModel enrollment;

  @override
  List<Object?> get props => [enrollment];
}

final class ScheduleClassCourseNavigationError extends ScheduleClassCourseNavigation {
  const ScheduleClassCourseNavigationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ScheduleFailure extends ScheduleState {
  const ScheduleFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
