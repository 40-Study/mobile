import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_alert_item.dart';
import 'package:study/features/parent/data/models/parent_analytics_data.dart';
import 'package:study/features/parent/data/models/parent_schedule_item.dart';

/// Aggregate model chứa toàn bộ dữ liệu cho Parent Home Screen.
class ParentHomeData {
  const ParentHomeData({
    required this.children,
    required this.selectedChildId,
    required this.alerts,
    required this.schedules,
    required this.analytics,
  });

  final List<FamilyScopeChild> children;

  /// `null` nghĩa là đang chọn "Tất cả các con".
  final String? selectedChildId;

  final List<ParentAlertItem> alerts;
  final List<ParentScheduleItem> schedules;
  final ParentAnalyticsData? analytics;
}
