import 'package:study/features/parent/data/models/parent_schedule_session.dart';

/// Base event cho Parent Schedule BLoC.
sealed class ParentScheduleEvent {
  const ParentScheduleEvent();
}

/// Bắt đầu tải dữ liệu lịch học lần đầu.
class ParentScheduleStarted extends ParentScheduleEvent {
  const ParentScheduleStarted({
    this.childId,
    this.selectedDate,
    this.tab = ParentScheduleTab.week,
  });

  final String? childId;
  final DateTime? selectedDate;
  final ParentScheduleTab tab;
}

/// Thay đổi hồ sơ con đang xem.
class ParentScheduleChildChanged extends ParentScheduleEvent {
  const ParentScheduleChildChanged(this.childId);

  final String? childId;
}

/// Chuyển tab lọc thời gian (Hôm nay / Tuần này / Tháng này).
class ParentScheduleTabChanged extends ParentScheduleEvent {
  const ParentScheduleTabChanged(this.tab);

  final ParentScheduleTab tab;
}

/// Chọn một ngày cụ thể trên dải lịch tuần.
class ParentScheduleDateSelected extends ParentScheduleEvent {
  const ParentScheduleDateSelected(this.date);

  final DateTime date;
}

/// Chuyển sang tuần trước hoặc tuần sau.
class ParentScheduleWeekChanged extends ParentScheduleEvent {
  const ParentScheduleWeekChanged(this.anchorDate);

  final DateTime anchorDate;
}

/// Làm mới dữ liệu (kéo để tải lại).
class ParentScheduleRefreshed extends ParentScheduleEvent {
  const ParentScheduleRefreshed();
}
