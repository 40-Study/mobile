import 'package:study/features/parent/data/models/models.dart';

/// Repository xử lý dữ liệu cho Family Insights Inbox
abstract class FamilyInsightsRepository {
  /// Lấy danh sách các insight của mọi con hoặc theo con cụ thể
  Future<List<FamilyInsightItem>> getInsights({String? childId});

  /// Gửi lời khen ngợi / khích lệ từ phụ huynh tới con
  Future<void> sendEncouragement(String insightId);

  /// Đánh dấu tất cả thông báo là đã đọc
  Future<void> markAllAsRead();
}
