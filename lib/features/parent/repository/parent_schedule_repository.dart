import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';

/// Interface repository quản lý lịch học dành cho Phụ huynh.
abstract class ParentScheduleRepository {
  /// Lấy danh sách con để render Family Scope Selector
  Future<List<FamilyScopeChild>> getChildren();

  /// Lấy danh sách ca học theo con và ngày
  Future<List<ParentScheduleSession>> getScheduleSessions({
    String? childId,
    DateTime? date,
    ParentScheduleTab tab = ParentScheduleTab.week,
  });

  /// Lấy danh sách các ngày có ca học trong tuần/tháng để hiển thị event dots
  Future<List<DateTime>> getEventDates({
    String? childId,
    required DateTime anchorDate,
  });
}
