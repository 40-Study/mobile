/// Sự kiện cho Parent Home BLoC.
sealed class ParentHomeEvent {
  const ParentHomeEvent();
}

class ParentHomeStarted extends ParentHomeEvent {
  const ParentHomeStarted();
}

class ParentHomeChildSelected extends ParentHomeEvent {
  const ParentHomeChildSelected(this.childId);

  final String? childId;
}

class ParentHomeRefreshed extends ParentHomeEvent {
  const ParentHomeRefreshed();
}

/// Các khối chức năng hỗ trợ Retry cục bộ khi gặp lỗi (Partial Failure)
enum ParentHomeSection { alerts, schedules, analytics }

class ParentHomeSectionRetried extends ParentHomeEvent {
  const ParentHomeSectionRetried(this.section);

  final ParentHomeSection section;
}
