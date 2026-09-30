import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_class_detail_model.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';
import 'package:study/features/parent/data/models/parent_learning_hub_data.dart';
import 'package:study/features/parent/data/models/parent_learning_insights_model.dart';

/// Interface repository quản lý dữ liệu cho phân hệ Học tập (Parent Learning)
abstract class ParentLearningRepository {
  /// Lấy danh sách con để hiển thị Family Scope Selector
  Future<List<FamilyScopeChild>> getChildren();

  /// Lấy dữ liệu tóm tắt cho 1 con cụ thể tại Learning Root Hub
  Future<ParentLearningHubData?> getLearningHubData(String childId);

  /// Lấy bản đồ dữ liệu tóm tắt của tất cả các con
  /// dạng `Map<String, ParentLearningHubData>`
  Future<Map<String, ParentLearningHubData>> getAllLearningHubData();

  /// Lấy thông tin chi tiết một lớp học của con
  Future<ParentClassDetailModel?> getClassDetail(
    String classId, {
    String? childId,
  });

  /// Lấy báo cáo phân tích sư phạm chuyên sâu của con (Learning Insights)
  Future<ParentLearningInsightsModel?> getLearningInsights(String childId);

  /// Lấy danh sách khóa học đề xuất cá nhân hoá cho con
  Future<List<ParentRecommendedCourseItem>> getRecommendedCourses(
    String childId,
  );

  /// Lấy thông tin chi tiết khóa học được gợi ý
  Future<ParentRecommendedCourseDetailModel?> getRecommendedCourseDetail(
    String courseId, {
    String? childId,
  });
}
