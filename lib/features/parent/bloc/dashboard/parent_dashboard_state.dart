import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/parent/data/models/models.dart';

part 'parent_dashboard_state.freezed.dart';

@freezed
abstract class MonthlyStats with _$MonthlyStats {
  const factory MonthlyStats({
    @Default(0) int totalCourses,
    @Default(0) double totalStudyHours,
    @Default(0) double avgAttendance,
    @Default(0) double totalExpenses,
  }) = _MonthlyStats;
}

@freezed
sealed class ParentDashboardState with _$ParentDashboardState {
  const factory ParentDashboardState.initial() = ParentDashboardInitial;
  const factory ParentDashboardState.loading() = ParentDashboardLoading;
  const factory ParentDashboardState.success({
    required List<ParentAlertModel> alerts,
    required List<ChildOverviewModel> childOverviews,
    required MonthlyStats monthlyStats,
    @Default([]) List<ChildScheduleModel> schedule,
    @Default([]) List<ChildCourseModel> courses,
  }) = ParentDashboardSuccess;
  const factory ParentDashboardState.failure(String message) = ParentDashboardFailure;
}
