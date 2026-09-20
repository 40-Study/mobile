import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/parent_api_client.dart';
import 'package:study/features/parent/repository/parent_repository.dart';

/// Mock repository - hardcode children IDs, gọi API thật cho overview
/// TODO: Refactor khi backend có GET /api/parent/children
class ParentRepositoryMock implements ParentRepository {
  ParentRepositoryMock(this._apiClient);

  final ParentApiClient _apiClient;

  // Hardcode children - thay đổi khi backend có API
  static const _mockChildren = [
    (
      id: 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732',
      name: 'Nguyễn Minh Anh',
      className: '12 tuổi • Lớp 7',
      courses: 2,
    ),
    (
      id: 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad',
      name: 'Nguyễn Minh Khôi',
      className: '10 tuổi • Lớp 5',
      courses: 1,
    ),
  ];

  @override
  Future<ApiResult<List<ChildModel>>> getChildren() async {
    final children = _mockChildren
        .map((c) => ChildModel(
              id: c.id,
              fullName: c.name,
              className: c.className,
              enrolledCourses: c.courses,
            ))
        .toList();
    return Result.success(children);
  }

  @override
  Future<ApiResult<ChildOverviewModel>> getChildOverview(String childId) async {
    try {
      final response = await _apiClient.getChildOverview(childId);
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) {
        return Result.failure(const ServerFailure(message: 'No data'));
      }
      final overview = ChildOverviewModel.fromJson(data);
      return Result.success(overview);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ChildCourseModel>>> getChildCourses(String childId) async {
    try {
      final response = await _apiClient.getChildCourses(childId);
      final wrapper = response.data['data'] as Map<String, dynamic>?;
      final data = wrapper?['courses'] as List<dynamic>?;
      if (data == null) return Result.success([]);
      final courses = data
          .map((e) => ChildCourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(courses);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ChildScheduleModel>>> getChildSchedule(String childId) async {
    try {
      final response = await _apiClient.getChildSchedule(childId);
      final wrapper = response.data['data'] as Map<String, dynamic>?;
      if (wrapper == null) return Result.success([]);

      // Build class name map từ weekly_schedule
      final weeklySchedule = wrapper['weekly_schedule'] as List<dynamic>? ?? [];
      final classNameMap = <String, String>{};
      for (final item in weeklySchedule) {
        final map = item as Map<String, dynamic>;
        final classId = map['class_id'] as String?;
        final className = map['class_name'] as String?;
        if (classId != null && className != null && className.isNotEmpty) {
          classNameMap[classId] = className;
        }
      }

      // Parse upcoming_sessions và fill class_name
      final data = wrapper['upcoming_sessions'] as List<dynamic>? ?? [];
      final schedule = data.map((e) {
        final map = Map<String, dynamic>.from(e as Map<String, dynamic>);
        final classId = map['class_id'] as String?;
        if (classId != null &&
            (map['class_name'] == null ||
                (map['class_name'] as String).isEmpty)) {
          map['class_name'] = classNameMap[classId] ?? '';
        }
        return ChildScheduleModel.fromJson(map);
      }).toList();

      return Result.success(schedule);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ChildAssignmentModel>>> getChildAssignments(String childId) async {
    try {
      final response = await _apiClient.getChildAssignments(childId);
      final data = response.data['data'] as List<dynamic>?;
      if (data == null) return Result.success([]);
      final assignments = data
          .map((e) => ChildAssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(assignments);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ParentAlertModel>>> getAlerts() async {
    try {
      final response = await _apiClient.getAlerts();
      final data = response.data['data'] as List<dynamic>?;
      if (data == null) return Result.success([]);
      final alerts = data
          .map((e) => ParentAlertModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(alerts);
    } catch (e) {
      return Result.success([]);
    }
  }
}
