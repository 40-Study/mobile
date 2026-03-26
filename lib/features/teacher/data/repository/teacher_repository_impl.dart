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

  // ==========================================================================
  // CLASSES
  // ==========================================================================

  @override
  Future<List<ClassModel>> getClasses({
    String? status,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.getClasses(
        page: page,
        pageSize: pageSize,
        status: status,
      );

      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'classes') ??
          _parseList(data, 'data');

      if (items == null) return [];

      var classes = items
          .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Filter by search query if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        classes = classes
            .where((c) => c.displayName.toLowerCase().contains(query))
            .toList();
      }

      return classes;
    } catch (e) {
      debugPrint('getClasses error: $e');
      if (_useMockOnError) return _getMockClasses(status, searchQuery);
      rethrow;
    }
  }

  List<ClassModel> _getMockClasses(String? status, String? searchQuery) {
    var classes = [
      const ClassModel(
        id: '1',
        name: 'Lop React Native - Khoa 1',
        description: 'Lop hoc lap trinh React Native cho nguoi moi bat dau',
        courseId: 'c1',
        courseName: 'React Native Co Ban',
        maxStudents: 30,
        studentCount: 25,
        startDate: '2024-01-15',
        endDate: '2024-04-15',
        status: 'active',
      ),
      const ClassModel(
        id: '2',
        name: 'Lop UI/UX Design - Khoa 3',
        description: 'Lop thiet ke giao dien nguoi dung',
        courseId: 'c2',
        courseName: 'UI/UX Design Masterclass',
        maxStudents: 25,
        studentCount: 20,
        startDate: '2024-02-01',
        endDate: '2024-05-01',
        status: 'active',
      ),
      const ClassModel(
        id: '3',
        name: 'Lop Flutter - Khoa 2',
        description: 'Lop hoc lap trinh Flutter',
        courseId: 'c3',
        courseName: 'Flutter Development',
        maxStudents: 30,
        studentCount: 30,
        startDate: '2023-10-01',
        endDate: '2024-01-01',
        status: 'completed',
      ),
    ];

    if (status != null && status.isNotEmpty && status != 'all') {
      classes = classes
          .where((c) => c.status.toLowerCase() == status.toLowerCase())
          .toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      classes = classes
          .where((c) => c.displayName.toLowerCase().contains(query))
          .toList();
    }

    return classes;
  }

  @override
  Future<ClassModel> getClassDetail(String classId) async {
    try {
      final response = await _api.getClass(classId);
      final data = response.data;
      final result = data['data'] as Map<String, dynamic>? ??
          data as Map<String, dynamic>;
      return ClassModel.fromJson(result);
    } catch (e) {
      debugPrint('getClassDetail error: $e');
      if (_useMockOnError) {
        final classes = _getMockClasses(null, null);
        return classes.firstWhere(
          (c) => c.id == classId,
          orElse: () => classes.first,
        );
      }
      rethrow;
    }
  }

  @override
  Future<ClassModel> createClass(Map<String, dynamic> data) async {
    final response = await _api.createClass(data);
    final result = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return ClassModel.fromJson(result);
  }

  @override
  Future<ClassModel> updateClass(
    String classId,
    Map<String, dynamic> data,
  ) async {
    final response = await _api.updateClass(classId, data);
    final result = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return ClassModel.fromJson(result);
  }

  @override
  Future<void> deleteClass(String classId) async {
    await _api.deleteClass(classId);
  }

  // ==========================================================================
  // CLASS TEACHERS
  // ==========================================================================

  @override
  Future<List<ClassTeacherModel>> getClassTeachers(String classId) async {
    try {
      final response = await _api.getClassTeachers(classId);
      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'teachers') ??
          _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => ClassTeacherModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getClassTeachers error: $e');
      if (_useMockOnError) return _getMockClassTeachers();
      rethrow;
    }
  }

  List<ClassTeacherModel> _getMockClassTeachers() {
    return [
      const ClassTeacherModel(
        id: '1',
        teacherId: 't1',
        fullName: 'Nguyen Van A',
        email: 'nguyenvana@example.com',
        role: 'owner',
      ),
      const ClassTeacherModel(
        id: '2',
        teacherId: 't2',
        fullName: 'Tran Thi B',
        email: 'tranthib@example.com',
        role: 'assistant',
      ),
    ];
  }

  @override
  Future<void> addTeacherToClass(
    String classId,
    String teacherId, {
    String role = 'assistant',
  }) async {
    await _api.addTeacherToClass(classId, {
      'teacher_id': teacherId,
      'role': role,
    });
  }

  @override
  Future<void> removeTeacherFromClass(
    String classId,
    String teacherId,
  ) async {
    await _api.removeTeacherFromClass(classId, teacherId);
  }

  // ==========================================================================
  // CLASS SCHEDULES
  // ==========================================================================

  @override
  Future<List<ClassScheduleModel>> getClassScheduleModels(
    String classId,
  ) async {
    try {
      final response = await _api.getClassSchedules(classId);
      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'schedules') ??
          _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => ClassScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getClassScheduleModels error: $e');
      if (_useMockOnError) return _getMockClassSchedules();
      rethrow;
    }
  }

  List<ClassScheduleModel> _getMockClassSchedules() {
    return [
      const ClassScheduleModel(
        id: '1',
        dayOfWeek: 2,
        startTime: '19:00',
        endTime: '21:00',
        room: 'Phong 101',
      ),
      const ClassScheduleModel(
        id: '2',
        dayOfWeek: 5,
        startTime: '19:00',
        endTime: '21:00',
        room: 'Phong 101',
      ),
      const ClassScheduleModel(
        id: '3',
        dayOfWeek: 7,
        startTime: '09:00',
        endTime: '11:00',
        room: 'Phong 102',
      ),
    ];
  }

  @override
  Future<ClassScheduleModel> createClassSchedule(
    String classId,
    Map<String, dynamic> data,
  ) async {
    final response = await _api.createSchedule(classId, data);
    final result = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return ClassScheduleModel.fromJson(result);
  }

  @override
  Future<ClassScheduleModel> updateClassSchedule(
    String classId,
    String scheduleId,
    Map<String, dynamic> data,
  ) async {
    final response = await _api.updateSchedule(classId, scheduleId, data);
    final result = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return ClassScheduleModel.fromJson(result);
  }

  @override
  Future<void> deleteClassSchedule(
    String classId,
    String scheduleId,
  ) async {
    await _api.deleteSchedule(classId, scheduleId);
  }

  // ==========================================================================
  // ATTENDANCES
  // ==========================================================================

  @override
  Future<List<AttendanceModel>> getClassAttendances(
    String classId, {
    String? sessionDate,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _api.getClassAttendances(
        classId,
        sessionDate: sessionDate,
        page: page,
        pageSize: pageSize,
      );

      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'attendances') ??
          _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getClassAttendances error: $e');
      if (_useMockOnError) return _getMockAttendances();
      rethrow;
    }
  }

  List<AttendanceModel> _getMockAttendances() {
    return [
      const AttendanceModel(
        id: '1',
        studentId: 's1',
        studentName: 'Nguyen Van An',
        studentCode: 'STU001',
        status: 'present',
        sessionDate: '2024-03-20',
      ),
      const AttendanceModel(
        id: '2',
        studentId: 's2',
        studentName: 'Le Thi Binh',
        studentCode: 'STU002',
        status: 'absent',
        sessionDate: '2024-03-20',
      ),
      const AttendanceModel(
        id: '3',
        studentId: 's3',
        studentName: 'Tran Minh Tam',
        studentCode: 'STU003',
        status: 'late',
        sessionDate: '2024-03-20',
      ),
      const AttendanceModel(
        id: '4',
        studentId: 's4',
        studentName: 'Pham Thu Ha',
        studentCode: 'STU004',
        status: 'excused',
        sessionDate: '2024-03-20',
      ),
    ];
  }

  @override
  Future<AttendanceModel> createAttendance(
    String classId,
    Map<String, dynamic> data,
  ) async {
    final response = await _api.createAttendance(classId, data);
    final result = response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>;
    return AttendanceModel.fromJson(result);
  }

  @override
  Future<void> batchUpdateAttendance(
    String classId,
    List<Map<String, dynamic>> attendances,
  ) async {
    await _api.batchUpdateAttendance(classId, {'attendances': attendances});
  }
}
