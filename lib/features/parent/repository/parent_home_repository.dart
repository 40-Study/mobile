import 'package:study/features/parent/data/models/models.dart';

/// Repository tổng hợp và phân mảnh dữ liệu cho Parent Home Screen.
abstract class ParentHomeRepository {
  /// Lấy toàn bộ dashboard cùng lúc
  Future<ParentHomeData> getHomeDashboard({String? childId});

  /// Lấy danh sách con
  Future<List<FamilyScopeChild>> getChildren();

  /// Lấy danh sách cảnh báo "Cần xử lý" của con (hoặc tất cả các con nếu
  /// [childId] là null)
  Future<List<ParentAlertItem>> getAlerts({String? childId});

  /// Lấy lịch học sắp tới
  Future<List<ParentScheduleItem>> getSchedules({String? childId});

  /// Lấy dữ liệu phân tích học tập (đơn lẻ theo [childId])
  Future<ParentAnalyticsData?> getAnalytics({String? childId});

  /// Lấy danh sách phân tích học tập (nhiều con nếu [childId] là null)
  Future<List<ParentAnalyticsData>> getAnalyticsList({String? childId});
}

