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
    required this.selectedDate,
    required this.currentMonth,
    this.isCalendarExpanded = false,
    this.eventsMap = const {},
    this.totalSessionsInWeek = 0,
    this.sessions = const [],
    this.errorMessage,
  });

  final ParentScheduleStatus status;
  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final DateTime selectedDate;
  final DateTime currentMonth;
  final bool isCalendarExpanded;
  final Map<DateTime, List<String>> eventsMap;
  final int totalSessionsInWeek;
  final List<ParentScheduleSession> sessions;
  final String? errorMessage;

  bool get isLoading => status == ParentScheduleStatus.loading;
  bool get isSuccess => status == ParentScheduleStatus.success;
  bool get isFailure => status == ParentScheduleStatus.failure;

  /// Nhóm danh sách các buổi học của ngày được chọn theo từng con.
  /// Phục vụ khi phụ huynh chọn "Tất cả các con" (selectedChildId == null).
  Map<String, List<ParentScheduleSession>> get sessionsByChild {
    final map = <String, List<ParentScheduleSession>>{};
    for (final s in sessions) {
      map.putIfAbsent(s.childId, () => []).add(s);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
    return map;
  }

  ParentScheduleState copyWith({
    ParentScheduleStatus? status,
    List<FamilyScopeChild>? children,
    String? selectedChildId,
    bool clearSelectedChild = false,
    DateTime? selectedDate,
    DateTime? currentMonth,
    bool? isCalendarExpanded,
    Map<DateTime, List<String>>? eventsMap,
    int? totalSessionsInWeek,
    List<ParentScheduleSession>? sessions,
    String? errorMessage,
  }) {
    return ParentScheduleState(
      status: status ?? this.status,
      children: children ?? this.children,
      selectedChildId: clearSelectedChild
          ? null
          : (selectedChildId ?? this.selectedChildId),
      selectedDate: selectedDate ?? this.selectedDate,
      currentMonth: currentMonth ?? this.currentMonth,
      isCalendarExpanded: isCalendarExpanded ?? this.isCalendarExpanded,
      eventsMap: eventsMap ?? this.eventsMap,
      totalSessionsInWeek: totalSessionsInWeek ?? this.totalSessionsInWeek,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
