/// Base event cho Parent Schedule BLoC.
sealed class ParentScheduleEvent {
  const ParentScheduleEvent();
}

/// Bắt đầu tải dữ liệu lịch học lần đầu.
class ParentScheduleStarted extends ParentScheduleEvent {
  const ParentScheduleStarted({
    this.childId,
    this.initialDate,
  });

  final String? childId;
  final DateTime? initialDate;
}

/// Thay đổi hồ sơ con đang xem (hoặc chọn "Tất cả các con" với childId = null).
class ParentScheduleChildChanged extends ParentScheduleEvent {
  const ParentScheduleChildChanged(this.childId);

  final String? childId;
}

/// Chọn một ngày cụ thể trên quyển lịch (tuần hoặc tháng).
class ParentScheduleDateSelected extends ParentScheduleEvent {
  const ParentScheduleDateSelected(this.date);

  final DateTime date;
}

/// Chuyển sang tháng trước hoặc tháng sau trên lịch mở rộng.
class ParentScheduleMonthChanged extends ParentScheduleEvent {
  const ParentScheduleMonthChanged(this.month);

  final DateTime month;
}

/// Chuyển đổi trạng thái thu gọn (tuần) / mở rộng (tháng) của quyển lịch.
class ParentScheduleCalendarModeToggled extends ParentScheduleEvent {
  const ParentScheduleCalendarModeToggled();
}

/// Làm mới toàn bộ dữ liệu (kéo để tải lại).
class ParentScheduleRefreshed extends ParentScheduleEvent {
  const ParentScheduleRefreshed();
}
