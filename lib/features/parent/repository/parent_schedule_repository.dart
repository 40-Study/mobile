import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';

/// Interface repository quản lý lịch học dành cho Phụ huynh.
abstract class ParentScheduleRepository {
  /// Lấy danh sách con để render Family Scope Selector
  Future<List<FamilyScopeChild>> getChildren();

  /// Lấy danh sách ca học của đúng ngày được chọn (sắp xếp tăng dần theo giờ)
  Future<List<ParentScheduleSession>> getSessionsForDate({
    String? childId,
    required DateTime date,
  });

  /// Lấy bản đồ các ngày trong tháng có ca học:
  /// `Map<DateTime, List<String>>` (ngày -> danh sách childId có ca học)
  /// Phục vụ hiển thị multi-color dots trên lịch tháng & tuần.
  Future<Map<DateTime, List<String>>> getEventsMapByMonth({
    String? childId,
    required DateTime month,
  });

  /// Lấy tổng số buổi học trong tuần chứa anchorDate
  /// (hiển thị trên badge của lịch tuần, vd: • 14 buổi học trong tuần)
  Future<int> getSessionCountForWeek({
    String? childId,
    required DateTime anchorDate,
  });

  /// Phương thức tương thích cũ
  Future<List<ParentScheduleSession>> getScheduleSessions({
    String? childId,
    DateTime? date,
    ParentScheduleTab tab = ParentScheduleTab.week,
  });

  /// Phương thức tương thích cũ lấy danh sách ngày có event
  Future<List<DateTime>> getEventDates({
    String? childId,
    required DateTime anchorDate,
  });
}
