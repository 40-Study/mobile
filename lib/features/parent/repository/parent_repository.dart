import 'package:study/core/error/result.dart';
import 'package:study/features/parent/data/models/models.dart';

abstract class ParentRepository {
  Future<ApiResult<List<ChildModel>>> getChildren();
  Future<ApiResult<ChildOverviewModel>> getChildOverview(String childId);
  Future<ApiResult<List<ChildCourseModel>>> getChildCourses(String childId);
  Future<ApiResult<List<ChildScheduleModel>>> getChildSchedule(String childId);
  Future<ApiResult<List<ChildAssignmentModel>>> getChildAssignments(String childId);
  Future<ApiResult<List<ParentAlertModel>>> getAlerts();
}
