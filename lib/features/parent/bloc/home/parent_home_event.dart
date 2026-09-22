/// Base event cho Parent Home BLoC.
sealed class ParentHomeEvent {
  const ParentHomeEvent();
}

/// Khởi tạo và tải dữ liệu lần đầu.
class ParentHomeStarted extends ParentHomeEvent {
  const ParentHomeStarted();
}

/// Phụ huynh chọn 1 con (hoặc "Tất cả các con" với `childId = null`).
class ParentHomeChildSelected extends ParentHomeEvent {
  const ParentHomeChildSelected(this.childId);

  final String? childId;
}

/// Kéo xuống để refresh.
class ParentHomeRefreshed extends ParentHomeEvent {
  const ParentHomeRefreshed();
}
