import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';

enum ParentScheduleStatus {
  initial,
  loading,
  success,
  failure,
}

class ParentScheduleState {
  const ParentScheduleState({
    this.status = ParentScheduleStatus.initial,
    this.children = const [],
    this.selectedChildId,
    this.selectedTab = ParentScheduleTab.week,
    required this.selectedDate,
    required this.anchorWeekDate,
    this.eventDates = const [],
    this.sessions = const [],
    this.errorMessage,
  });

  final ParentScheduleStatus status;
  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final ParentScheduleTab selectedTab;
  final DateTime selectedDate;
  final DateTime anchorWeekDate;
  final List<DateTime> eventDates;
  final List<ParentScheduleSession> sessions;
  final String? errorMessage;

  bool get isLoading => status == ParentScheduleStatus.loading;
  bool get isSuccess => status == ParentScheduleStatus.success;
  bool get isFailure => status == ParentScheduleStatus.failure;

  /// Nhóm danh sách các buổi học theo ngày (chỉ tính năm, tháng, ngày).
  Map<DateTime, List<ParentScheduleSession>> get sessionsByDate {
    final map = <DateTime, List<ParentScheduleSession>>{};
    for (final s in sessions) {
      final key = DateTime(
        s.startTime.year,
        s.startTime.month,
        s.startTime.day,
      );
      map.putIfAbsent(key, () => []).add(s);
    }

    // Sắp xếp các buổi học trong ngày tăng dần theo giờ bắt đầu
    for (final list in map.values) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return map;
  }

  /// Trả về số ca học trong ngày cụ thể.
  int sessionCountForDate(DateTime date) {
    return sessions.where((s) => _isSameDay(s.startTime, date)).length;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  ParentScheduleState copyWith({
    ParentScheduleStatus? status,
    List<FamilyScopeChild>? children,
    String? selectedChildId,
    bool clearSelectedChild = false,
    ParentScheduleTab? selectedTab,
    DateTime? selectedDate,
    DateTime? anchorWeekDate,
    List<DateTime>? eventDates,
    List<ParentScheduleSession>? sessions,
    String? errorMessage,
  }) {
    return ParentScheduleState(
      status: status ?? this.status,
      children: children ?? this.children,
      selectedChildId: clearSelectedChild
          ? null
          : (selectedChildId ?? this.selectedChildId),
      selectedTab: selectedTab ?? this.selectedTab,
      selectedDate: selectedDate ?? this.selectedDate,
      anchorWeekDate: anchorWeekDate ?? this.anchorWeekDate,
      eventDates: eventDates ?? this.eventDates,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
