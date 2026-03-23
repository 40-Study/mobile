import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';
import 'package:study/features/teacher/data/teacher_api_client.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  TeacherRepositoryImpl({required TeacherApiClient apiClient})
      : _api = apiClient;

  final TeacherApiClient _api;

  /// Enable mock data when API fails (for development).
  static const _useMockOnError = true;

  @override
  Future<TeacherStatsModel> getStats() async {
    // Real data: totalCourses, activeCourses, totalStudents (from /api/classes)
    // Mock data: monthlyRevenue, revenueData, completionRate, newStudents
    // (No dashboard/stats/finance API available)
    try {
      final courses = await getCourses();
      int totalStudents = 0;
      for (final course in courses) {
        totalStudents += course.studentCount;
      }

      return TeacherStatsModel(
        monthlyRevenue: 42850000,
        newStudents: totalStudents > 0 ? totalStudents : 128,
        completionRate: 94.2,
        totalCourses: courses.length,
        activeCourses: courses.where((c) => c.isPublished).length,
        totalStudents: totalStudents > 0 ? totalStudents : 1240,
        revenueData: const [15, 22, 18, 25, 30, 28, 42],
      );
    } catch (e) {
      // Return mock stats on error
      return const TeacherStatsModel(
        monthlyRevenue: 42850000,
        newStudents: 128,
        completionRate: 94.2,
        totalCourses: 3,
        activeCourses: 2,
        totalStudents: 1240,
        revenueData: [15, 22, 18, 25, 30, 28, 42],
      );
    }
  }

  @override
  Future<List<TeacherNotificationModel>> getNotifications({
    int limit = 5,
  }) async {
    // TODO: Replace with actual notification API when available
    // Return mock data for now
    return [
      const TeacherNotificationModel(
        id: '1',
        title: 'Học viên Lê Anh Tuấn vừa nộp bài tập cuối khóa.',
        subtitle: 'UI/UX Design',
        type: 'assignment',
        createdAt: '2 phút trước',
      ),
      const TeacherNotificationModel(
        id: '2',
        title: 'Yêu cầu rút tiền tháng 10 đã được phê duyệt.',
        subtitle: 'Tài chính',
        type: 'finance',
        createdAt: '1 giờ trước',
      ),
      const TeacherNotificationModel(
        id: '3',
        title: 'Chào mừng giảng viên mới gia nhập hệ thống.',
        subtitle: 'Hệ thống',
        type: 'system',
        createdAt: 'Hôm qua',
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<TeacherScheduleModel>> getUpcomingSchedule({
    int limit = 5,
  }) async {
    try {
      // Get all classes first
      final courses = await getCourses();
      if (courses.isEmpty) {
        if (_useMockOnError) return _getMockSchedules(limit);
        return [];
      }

      // Get schedules from all classes
      final allSchedules = <TeacherScheduleModel>[];
      for (final course in courses.take(5)) {
        // Limit to first 5 classes
        try {
          final schedules = await getClassSchedules(course.id);
          allSchedules.addAll(schedules);
        } catch (_) {
          // Skip if class schedule fails
        }
      }

      if (allSchedules.isEmpty && _useMockOnError) {
        return _getMockSchedules(limit);
      }

      // Sort by start time and take limit
      allSchedules.sort((a, b) {
        final aTime = DateTime.tryParse(a.startTime) ?? DateTime.now();
        final bTime = DateTime.tryParse(b.startTime) ?? DateTime.now();
        return aTime.compareTo(bTime);
      });

      return allSchedules.take(limit).toList();
    } catch (e) {
      debugPrint('getUpcomingSchedule error: $e');
      if (_useMockOnError) return _getMockSchedules(limit);
      rethrow;
    }
  }

  List<TeacherScheduleModel> _getMockSchedules(int limit) {
    return [
      const TeacherScheduleModel(
        id: '1',
        title: 'Workshop: Tư duy thiết kế Sản phẩm',
        startTime: '2024-03-14T19:30:00',
        meetingType: 'Meet',
      ),
      const TeacherScheduleModel(
        id: '2',
        title: 'Review đồ án: Mobile App Core',
        startTime: '2024-03-16T09:00:00',
        meetingType: 'offline',
        studentCount: 12,
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<CourseModel>> getCourses({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // Try classes first (more likely for teachers)
      final response = await _api.getClasses(
        page: page,
        pageSize: pageSize,
        status: status,
      );

      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'classes') ??
          _parseList(data, 'courses') ??
          _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getCourses error: $e');
      if (_useMockOnError) return _getMockCourses(status);
      rethrow;
    }
  }

  List<CourseModel> _getMockCourses(String? status) {
    final courses = [
      const CourseModel(
        id: '1',
        name: 'Lập trình React Native cho người mới bắt đầu',
        studentCount: 1240,
        rating: 4.8,
        reviewCount: 256,
        status: 'active',
        categoryName: 'Mobile Development',
      ),
      const CourseModel(
        id: '2',
        name: 'UI/UX Design Masterclass: Từ số 0 đến Pro',
        studentCount: 856,
        rating: 4.9,
        reviewCount: 189,
        status: 'active',
        categoryName: 'Design',
      ),
      const CourseModel(
        id: '3',
        name: 'Digital Marketing Strategy 2024',
        studentCount: 0,
        status: 'draft',
        categoryName: 'Marketing',
      ),
    ];

    if (status != null && status.isNotEmpty && status != 'all') {
      return courses
          .where((c) => c.status.toLowerCase() == status.toLowerCase())
          .toList();
    }
    return courses;
  }

  @override
  Future<CourseModel> createCourse(Map<String, dynamic> data) async {
    final response = await _api.createClass(data);
    final result = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return CourseModel.fromJson(result);
  }

  @override
  Future<CourseModel> updateCourse(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _api.updateClass(id, data);
    final result = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return CourseModel.fromJson(result);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _api.deleteClass(id);
  }

  @override
  Future<List<StudentModel>> getStudents({
    String? classId,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      if (classId == null) {
        // If no classId, try to get from first class
        final courses = await getCourses();
        if (courses.isEmpty) return _getMockStudents(searchQuery);
        classId = courses.first.id;
      }

      final response = await _api.getClassStudents(
        classId,
        page: page,
        pageSize: pageSize,
        search: searchQuery,
      );

      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'students') ??
          _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getStudents error: $e');
      if (_useMockOnError) return _getMockStudents(searchQuery);
      rethrow;
    }
  }

  List<StudentModel> _getMockStudents(String? searchQuery) {
    var students = [
      const StudentModel(
        id: '1',
        studentCode: 'STU9901',
        fullName: 'Nguyễn Văn An',
        enrolledCourse: 'UI/UX Advanced Masterclass',
        progress: 85,
        lastActivity: '2 giờ trước',
      ),
      const StudentModel(
        id: '2',
        studentCode: 'STU9924',
        fullName: 'Lê Thị Bình',
        enrolledCourse: 'Frontend Developer Pro',
        progress: 42,
        lastActivity: 'Hôm qua',
      ),
      const StudentModel(
        id: '3',
        studentCode: 'STU9915',
        fullName: 'Trần Minh Tâm',
        enrolledCourse: 'Graphic Design Fundamentals',
        progress: 100,
        lastActivity: 'Hoàn thành',
      ),
    ];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      students = students
          .where(
            (s) =>
                s.displayName.toLowerCase().contains(query) ||
                (s.studentCode?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    return students;
  }

  @override
  Future<void> addStudentToClass(String classId, String studentId) async {
    await _api.addStudentToClass(classId, {'student_id': studentId});
  }

  @override
  Future<void> removeStudentFromClass(
    String classId,
    String studentId,
  ) async {
    await _api.removeStudentFromClass(classId, studentId);
  }

  @override
  Future<List<TeacherScheduleModel>> getClassSchedules(String classId) async {
    final response = await _api.getClassSchedules(classId);
    final data = response.data;
    final List<dynamic>? items = _parseList(data, 'schedules') ??
        _parseList(data, 'data');

    if (items == null) return [];

    return items
        .map((e) => TeacherScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Helper to parse list from response data.
  List<dynamic>? _parseList(dynamic data, String key) {
    if (data is Map<String, dynamic>) {
      final value = data[key];
      if (value is List<dynamic>) return value;

      // Check nested data
      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedValue = nestedData[key];
        if (nestedValue is List<dynamic>) return nestedValue;
      }
    }
    if (data is List<dynamic>) return data;
    return null;
  }
}
