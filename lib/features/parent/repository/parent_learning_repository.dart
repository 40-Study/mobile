import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_learning_hub_data.dart';

/// Interface repository quản lý dữ liệu cho phân hệ Học tập (Parent Learning)
abstract class ParentLearningRepository {
  /// Lấy danh sách con để hiển thị Family Scope Selector
  Future<List<FamilyScopeChild>> getChildren();

  /// Lấy dữ liệu tóm tắt cho 1 con cụ thể tại Learning Root Hub
  Future<ParentLearningHubData?> getLearningHubData(String childId);

  /// Lấy bản đồ dữ liệu tóm tắt của tất cả các con
  /// dạng `Map<String, ParentLearningHubData>`
  Future<Map<String, ParentLearningHubData>> getAllLearningHubData();
}
