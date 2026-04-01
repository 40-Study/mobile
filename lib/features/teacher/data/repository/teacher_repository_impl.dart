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
    // Use mock courses data for consistency
    final courses = _getMockCourses(null);
    int totalStudents = 0;
    for (final course in courses) {
      totalStudents += course.studentCount;
    }

    return TeacherStatsModel(
      monthlyRevenue: 42850000,
      newStudents: 128,
      completionRate: 94.2,
      totalCourses: courses.length,
      activeCourses: courses.where((c) => c.isPublished).length,
      totalStudents: totalStudents,
      revenueData: const [15, 22, 18, 25, 30, 28, 42],
    );
  }

  @override
  Future<TeacherWalletModel> getWallet() async {
    // TODO: Replace with actual wallet API when available
    return const TeacherWalletModel(
      balance: 45280000,
      monthlyIncome: 12450000,
      incomeChangePercent: 15.2,
      isPremium: true,
    );
  }

  @override
  Future<List<PendingAssignmentModel>> getPendingAssignments({
    int limit = 5,
  }) async {
    // TODO: Replace with actual API when available
    return [
      const PendingAssignmentModel(
        id: '1',
        studentName: 'Lê Minh Tuấn',
        assignmentTitle: 'Bài tập 3: Grid System',
        submittedAt: '2 giờ trước',
        courseName: 'UI/UX Design',
      ),
      const PendingAssignmentModel(
        id: '2',
        studentName: 'Nguyễn Thu Thủy',
        assignmentTitle: 'Đồ án cuối khóa - Wireframe',
        submittedAt: '5 giờ trước',
        courseName: 'UI/UX Design',
      ),
      const PendingAssignmentModel(
        id: '3',
        studentName: 'Trần Văn Hùng',
        assignmentTitle: 'Bài tập: Component Design',
        submittedAt: 'Hôm qua',
        courseName: 'React Native',
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<TeacherActivityModel>> getActivities({int limit = 10}) async {
    // TODO: Replace with actual API when available
    return [
      const TeacherActivityModel(
        id: '1',
        title: 'Rút tiền thành công',
        subtitle: 'Hệ thống đã chuyển 5.000.000đ vào tài khoản Techcombank',
        type: ActivityType.withdrawal,
        createdAt: '10:45 AM',
      ),
      const TeacherActivityModel(
        id: '2',
        title: 'Khóa học "UX Design" có 5 học viên mới',
        subtitle: 'Tổng số học viên hiện tại: 256',
        type: ActivityType.newStudent,
        createdAt: 'HÔM QUA',
      ),
      const TeacherActivityModel(
        id: '3',
        title: 'Đánh giá 5 sao từ học viên',
        subtitle: 'Nguyễn Văn An đã đánh giá khóa học React Native',
        type: ActivityType.review,
        createdAt: '2 ngày trước',
      ),
    ].take(limit).toList();
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Format as ISO string
    String formatTime(DateTime date, int hour, int minute) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
    }

    return [
      TeacherScheduleModel(
        id: '1',
        title: 'Lớp UI/UX Design - Buổi 15',
        courseName: 'UI/UX Design Masterclass',
        startTime: formatTime(today, 9, 0),
        meetingType: 'offline',
        studentCount: 18,
      ),
      TeacherScheduleModel(
        id: '2',
        title: 'Live Q&A: Thiết kế Mobile App',
        courseName: 'Flutter Development',
        startTime: formatTime(today, 14, 30),
        meetingType: 'Meet',
        studentCount: 45,
      ),
      TeacherScheduleModel(
        id: '3',
        title: 'Workshop: Tư duy thiết kế Sản phẩm',
        courseName: 'UI/UX Design Masterclass',
        startTime: formatTime(today, 19, 30),
        meetingType: 'Meet',
        studentCount: 32,
      ),
      TeacherScheduleModel(
        id: '4',
        title: 'Review đồ án cuối khóa',
        courseName: 'React Native',
        startTime: formatTime(today, 20, 0),
        meetingType: 'offline',
        studentCount: 12,
      ),
      TeacherScheduleModel(
        id: '5',
        title: 'Lớp Flutter Nâng cao - Buổi 8',
        courseName: 'Flutter Development',
        startTime: formatTime(tomorrow, 9, 0),
        meetingType: 'offline',
        studentCount: 22,
      ),
      TeacherScheduleModel(
        id: '6',
        title: 'Mentoring 1-1: Dự án thực tế',
        courseName: 'Agile Project Management',
        startTime: formatTime(tomorrow, 15, 0),
        meetingType: 'Meet',
        studentCount: 5,
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<CourseModel>> getCourses({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    // TODO: Enable real API when ready
    // For now, use mock data for development
    return _getMockCourses(status);
  }

  List<CourseModel> _getMockCourses(String? status) {
    final courses = [
      const CourseModel(
        id: '1',
        name: 'Thiết kế UI/UX Nâng cao 2024',
        studentCount: 1240,
        classCount: 12,
        rating: 4.8,
        reviewCount: 256,
        status: 'published',
        isOnSale: true,
        price: 199.00,
        progressPercent: 75,
        categoryName: 'Design',
        thumbnailUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400',
      ),
      const CourseModel(
        id: '2',
        name: 'Lập trình ReactJS Thực chiến',
        studentCount: 0,
        classCount: 0,
        rating: 0,
        reviewCount: 0,
        status: 'draft',
        isOnSale: false,
        price: 0,
        progressPercent: 0,
        categoryName: 'Web Development',
        thumbnailUrl: 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400',
      ),
      const CourseModel(
        id: '3',
        name: 'Quản trị Dự án Agile Mastery',
        studentCount: 856,
        classCount: 8,
        rating: 4.9,
        reviewCount: 189,
        status: 'published',
        isOnSale: true,
        price: 149.00,
        progressPercent: 100,
        categoryName: 'Business',
        thumbnailUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400',
      ),
      const CourseModel(
        id: '4',
        name: 'Flutter Mobile Development',
        studentCount: 520,
        classCount: 6,
        rating: 4.7,
        reviewCount: 98,
        status: 'published',
        isOnSale: true,
        price: 179.00,
        progressPercent: 100,
        categoryName: 'Mobile Development',
        thumbnailUrl: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
      ),
      const CourseModel(
        id: '5',
        name: 'Data Science với Python',
        studentCount: 0,
        classCount: 0,
        rating: 0,
        reviewCount: 0,
        status: 'draft',
        isOnSale: false,
        price: 0,
        progressPercent: 30,
        categoryName: 'Data Science',
        thumbnailUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
      ),
      const CourseModel(
        id: '6',
        name: 'Marketing Digital 2024',
        studentCount: 320,
        classCount: 5,
        rating: 4.5,
        reviewCount: 67,
        status: 'archived',
        isOnSale: false,
        price: 99.00,
        progressPercent: 100,
        categoryName: 'Marketing',
        thumbnailUrl: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
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
        id: 's1',
        studentCode: 'STU001',
        fullName: 'Nguyễn Văn An',
        email: 'nguyenvanan@gmail.com',
        enrolledCourse: 'UI/UX Advanced Masterclass',
        progress: 85,
        lastActivity: '2 giờ trước',
      ),
      const StudentModel(
        id: 's2',
        studentCode: 'STU002',
        fullName: 'Lê Thị Bình',
        email: 'lethibinh@gmail.com',
        enrolledCourse: 'Frontend Developer Pro',
        progress: 72,
        lastActivity: 'Hôm qua',
      ),
      const StudentModel(
        id: 's3',
        studentCode: 'STU003',
        fullName: 'Trần Minh Tâm',
        email: 'tranminhtam@gmail.com',
        enrolledCourse: 'Graphic Design Fundamentals',
        progress: 92,
        lastActivity: '3 giờ trước',
      ),
      const StudentModel(
        id: 's4',
        studentCode: 'STU004',
        fullName: 'Phạm Thu Hà',
        email: 'phamthuha@gmail.com',
        enrolledCourse: 'UI/UX Design',
        progress: 45,
        lastActivity: '1 tuần trước',
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
    // TODO: Enable real API when ready
    // For now, use mock data for development
    return _getMockClasses(status, searchQuery);
  }

  List<ClassModel> _getMockClasses(String? status, String? searchQuery) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find next occurrence of each weekday
    DateTime nextWeekday(int weekday) {
      var date = today;
      while (date.weekday != weekday) {
        date = date.add(const Duration(days: 1));
      }
      return date;
    }

    String formatDate(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    var classes = [
      // Monday classes (Thứ 2)
      ClassModel(
        id: '1',
        name: 'Toán Cao Cấp - A1',
        description: 'Lớp Toán cao cấp dành cho sinh viên năm nhất',
        courseId: 'c1',
        courseName: 'Toán Cao Cấp',
        maxStudents: 35,
        studentCount: 32,
        startDate: '2026-01-15',
        endDate: '2026-05-15',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(1)), // Monday
        nextScheduleTime: '08:30 - 10:00',
        nextScheduleRoom: 'Phòng 402, Tòa B',
        isOnline: false,
      ),
      ClassModel(
        id: '2',
        name: 'UI/UX Design - Khóa 5',
        description: 'Thiết kế giao diện người dùng',
        courseId: 'c4',
        courseName: 'UI/UX Design Masterclass',
        maxStudents: 25,
        studentCount: 22,
        startDate: '2026-03-01',
        endDate: '2026-07-01',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(1)), // Monday
        nextScheduleTime: '14:00 - 16:00',
        nextScheduleRoom: 'Phòng 105, Tòa C',
        isOnline: false,
      ),
      // Tuesday classes (Thứ 3)
      ClassModel(
        id: '3',
        name: 'Vật Lý Đại Cương - B2',
        description: 'Lớp Vật lý hạt nhân nâng cao',
        courseId: 'c2',
        courseName: 'Vật Lý Đại Cương',
        maxStudents: 30,
        studentCount: 28,
        startDate: '2026-02-01',
        endDate: '2026-06-01',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(2)), // Tuesday
        nextScheduleTime: '13:30 - 15:00',
        nextScheduleRoom: 'Phòng 301, Tòa A',
        isOnline: false,
      ),
      ClassModel(
        id: '4',
        name: 'Toán Cao Cấp - A2',
        description: 'Lớp Toán cao cấp buổi tối',
        courseId: 'c1',
        courseName: 'Toán Cao Cấp',
        maxStudents: 40,
        studentCount: 38,
        startDate: '2026-01-20',
        endDate: '2026-05-20',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(2)), // Tuesday
        nextScheduleTime: '18:00 - 20:00',
        nextScheduleRoom: 'Phòng 501, Tòa A',
        isOnline: false,
      ),
      // Wednesday classes (Thứ 4)
      ClassModel(
        id: '5',
        name: 'Lập trình Python - K1',
        description: 'Lớp lập trình Python cơ bản và nâng cao',
        courseId: 'c3',
        courseName: 'Python Programming',
        maxStudents: 45,
        studentCount: 45,
        startDate: '2026-01-20',
        endDate: '2026-05-20',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(3)), // Wednesday
        nextScheduleTime: '09:00 - 11:30',
        nextScheduleRoom: 'Lab 201',
        isOnline: true,
      ),
      // Thursday classes (Thứ 5)
      ClassModel(
        id: '6',
        name: 'Vật Lý Đại Cương - B1',
        description: 'Lớp Vật lý cơ bản',
        courseId: 'c2',
        courseName: 'Vật Lý Đại Cương',
        maxStudents: 35,
        studentCount: 30,
        startDate: '2026-02-10',
        endDate: '2026-06-10',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(4)), // Thursday
        nextScheduleTime: '08:00 - 10:00',
        nextScheduleRoom: 'Phòng 202, Tòa B',
        isOnline: false,
      ),
      ClassModel(
        id: '7',
        name: 'UI/UX Design - Khóa 6',
        description: 'Thiết kế UX nâng cao',
        courseId: 'c4',
        courseName: 'UI/UX Design Masterclass',
        maxStudents: 30,
        studentCount: 18,
        startDate: '2026-03-15',
        endDate: '2026-07-15',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(4)), // Thursday
        nextScheduleTime: '19:00 - 21:00',
        nextScheduleRoom: 'Online - Google Meet',
        isOnline: true,
      ),
      // Friday classes (Thứ 6)
      ClassModel(
        id: '8',
        name: 'Lập trình Python - K2',
        description: 'Python cho Data Science',
        courseId: 'c3',
        courseName: 'Python Programming',
        maxStudents: 30,
        studentCount: 25,
        startDate: '2026-02-01',
        endDate: '2026-06-01',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(5)), // Friday
        nextScheduleTime: '14:00 - 16:30',
        nextScheduleRoom: 'Lab 202',
        isOnline: false,
      ),
      // Saturday classes (Thứ 7)
      ClassModel(
        id: '9',
        name: 'Flutter Mobile - K1',
        description: 'Lập trình di động với Flutter',
        courseId: 'c6',
        courseName: 'Flutter Development',
        maxStudents: 25,
        studentCount: 20,
        startDate: '2026-03-01',
        endDate: '2026-07-01',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(6)), // Saturday
        nextScheduleTime: '09:00 - 12:00',
        nextScheduleRoom: 'Lab 301',
        isOnline: false,
      ),
      ClassModel(
        id: '10',
        name: 'Toán Cao Cấp - A3',
        description: 'Lớp ôn tập cuối tuần',
        courseId: 'c1',
        courseName: 'Toán Cao Cấp',
        maxStudents: 50,
        studentCount: 42,
        startDate: '2026-02-01',
        endDate: '2026-05-01',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(6)), // Saturday
        nextScheduleTime: '14:00 - 17:00',
        nextScheduleRoom: 'Hội trường A',
        isOnline: false,
      ),
      // Sunday classes (Chủ nhật)
      ClassModel(
        id: '11',
        name: 'UI/UX Workshop',
        description: 'Workshop thiết kế cuối tuần',
        courseId: 'c4',
        courseName: 'UI/UX Design Masterclass',
        maxStudents: 20,
        studentCount: 15,
        startDate: '2026-03-01',
        endDate: '2026-06-01',
        status: 'active',
        nextScheduleDate: formatDate(nextWeekday(7)), // Sunday
        nextScheduleTime: '09:00 - 12:00',
        nextScheduleRoom: 'Online - Zoom',
        isOnline: true,
      ),
      // Completed classes
      const ClassModel(
        id: '12',
        name: 'React Native - Khóa 3',
        description: 'Lập trình di động với React Native',
        courseId: 'c5',
        courseName: 'Mobile Development',
        maxStudents: 30,
        studentCount: 30,
        startDate: '2025-10-01',
        endDate: '2026-01-01',
        status: 'completed',
      ),
      const ClassModel(
        id: '13',
        name: 'Python Cơ bản - K0',
        description: 'Khóa Python cho người mới bắt đầu',
        courseId: 'c3',
        courseName: 'Python Programming',
        maxStudents: 35,
        studentCount: 33,
        startDate: '2025-09-01',
        endDate: '2025-12-15',
        status: 'completed',
      ),
      // Cancelled classes
      const ClassModel(
        id: '14',
        name: 'Flutter Advanced',
        description: 'Flutter nâng cao - Bị hủy do thiếu học viên',
        courseId: 'c6',
        courseName: 'Flutter Development',
        maxStudents: 20,
        studentCount: 5,
        startDate: '2025-08-01',
        endDate: '2025-11-01',
        status: 'cancelled',
      ),
      const ClassModel(
        id: '15',
        name: 'Vật Lý Lượng Tử',
        description: 'Khóa nâng cao - Bị hủy',
        courseId: 'c2',
        courseName: 'Vật Lý Đại Cương',
        maxStudents: 25,
        studentCount: 8,
        startDate: '2025-07-01',
        endDate: '2025-10-01',
        status: 'cancelled',
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

  // ==========================================================================
  // STUDENT DETAIL
  // ==========================================================================

  @override
  Future<StudentDetailModel> getStudentDetail(
    String classId,
    String studentId,
  ) async {
    // TODO: Replace with actual API when available
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _getMockStudentDetail(studentId);
  }

  StudentDetailModel _getMockStudentDetail(String studentId) {
    final mockStudents = <String, StudentDetailModel>{
      's1': const StudentDetailModel(
        id: 's1',
        studentCode: 'STU001',
        fullName: 'Nguyễn Văn An',
        email: 'nguyenvanan@gmail.com',
        phone: '0912345678',
        dateOfBirth: '2000-05-15',
        address: '123 Nguyễn Trãi, Quận 1, TP.HCM',
        enrolledAt: '2026-01-10',
        progress: 85,
        parent: ParentModel(
          id: 'p1',
          fullName: 'Nguyễn Văn Bình',
          relationship: 'Bố',
          phone: '0987654321',
          email: 'nguyenvanbinh@gmail.com',
        ),
        assignments: [
          StudentAssignmentModel(
            id: 'a1',
            title: 'Bài tập 1: Thiết kế Landing Page',
            status: AssignmentStatus.completed,
            dueDate: '2026-02-15',
            submittedAt: '2026-02-14',
            score: 90,
            maxScore: 100,
            feedback: 'Bài làm tốt, thiết kế sáng tạo',
          ),
          StudentAssignmentModel(
            id: 'a2',
            title: 'Bài tập 2: Wireframe Mobile App',
            status: AssignmentStatus.completed,
            dueDate: '2026-02-28',
            submittedAt: '2026-02-27',
            score: 85,
            maxScore: 100,
          ),
          StudentAssignmentModel(
            id: 'a3',
            title: 'Bài tập 3: Design System',
            status: AssignmentStatus.incomplete,
            dueDate: '2026-03-15',
          ),
          StudentAssignmentModel(
            id: 'a4',
            title: 'Đồ án cuối khóa: App Hoàn chỉnh',
            status: AssignmentStatus.incomplete,
            dueDate: '2026-04-30',
          ),
        ],
        attendanceSummary: AttendanceSummaryModel(
          totalSessions: 12,
          presentCount: 10,
          absentCount: 0,
          lateCount: 2,
          excusedCount: 0,
        ),
      ),
      's2': const StudentDetailModel(
        id: 's2',
        studentCode: 'STU002',
        fullName: 'Lê Thị Bình',
        email: 'lethibinh@gmail.com',
        phone: '0923456789',
        dateOfBirth: '2001-08-20',
        address: '456 Lê Lợi, Quận 3, TP.HCM',
        enrolledAt: '2026-01-12',
        progress: 72,
        parent: ParentModel(
          id: 'p2',
          fullName: 'Lê Văn Cường',
          relationship: 'Bố',
          phone: '0976543210',
          email: 'levancuong@gmail.com',
        ),
        assignments: [
          StudentAssignmentModel(
            id: 'a1',
            title: 'Bài tập 1: Thiết kế Landing Page',
            status: AssignmentStatus.completed,
            dueDate: '2026-02-15',
            submittedAt: '2026-02-15',
            score: 78,
            maxScore: 100,
          ),
          StudentAssignmentModel(
            id: 'a2',
            title: 'Bài tập 2: Wireframe Mobile App',
            status: AssignmentStatus.late,
            dueDate: '2026-02-28',
            submittedAt: '2026-03-02',
            score: 65,
            maxScore: 100,
            feedback: 'Nộp trễ, trừ 10 điểm',
          ),
          StudentAssignmentModel(
            id: 'a3',
            title: 'Bài tập 3: Design System',
            status: AssignmentStatus.incomplete,
            dueDate: '2026-03-15',
          ),
        ],
        attendanceSummary: AttendanceSummaryModel(
          totalSessions: 12,
          presentCount: 8,
          absentCount: 2,
          lateCount: 1,
          excusedCount: 1,
        ),
      ),
      's3': const StudentDetailModel(
        id: 's3',
        studentCode: 'STU003',
        fullName: 'Trần Minh Tâm',
        email: 'tranminhtam@gmail.com',
        phone: '0934567890',
        dateOfBirth: '1999-12-10',
        address: '789 Hai Bà Trưng, Quận 5, TP.HCM',
        enrolledAt: '2026-01-15',
        progress: 92,
        parent: ParentModel(
          id: 'p3',
          fullName: 'Trần Thị Dung',
          relationship: 'Mẹ',
          phone: '0965432109',
          email: 'tranthidung@gmail.com',
        ),
        assignments: [
          StudentAssignmentModel(
            id: 'a1',
            title: 'Bài tập 1: Thiết kế Landing Page',
            status: AssignmentStatus.completed,
            dueDate: '2026-02-15',
            submittedAt: '2026-02-12',
            score: 95,
            maxScore: 100,
            feedback: 'Xuất sắc! Thiết kế rất chuyên nghiệp',
          ),
          StudentAssignmentModel(
            id: 'a2',
            title: 'Bài tập 2: Wireframe Mobile App',
            status: AssignmentStatus.completed,
            dueDate: '2026-02-28',
            submittedAt: '2026-02-25',
            score: 92,
            maxScore: 100,
          ),
          StudentAssignmentModel(
            id: 'a3',
            title: 'Bài tập 3: Design System',
            status: AssignmentStatus.completed,
            dueDate: '2026-03-15',
            submittedAt: '2026-03-10',
            score: 88,
            maxScore: 100,
          ),
        ],
        attendanceSummary: AttendanceSummaryModel(
          totalSessions: 12,
          presentCount: 12,
          absentCount: 0,
          lateCount: 0,
          excusedCount: 0,
        ),
      ),
      's4': const StudentDetailModel(
        id: 's4',
        studentCode: 'STU004',
        fullName: 'Phạm Thu Hà',
        email: 'phamthuha@gmail.com',
        phone: '0945678901',
        dateOfBirth: '2000-03-25',
        address: '321 Võ Văn Tần, Quận 10, TP.HCM',
        enrolledAt: '2026-01-18',
        progress: 45,
        parent: ParentModel(
          id: 'p4',
          fullName: 'Phạm Văn Hùng',
          relationship: 'Bố',
          phone: '0954321098',
          email: 'phamvanhung@gmail.com',
        ),
        assignments: [
          StudentAssignmentModel(
            id: 'a1',
            title: 'Bài tập 1: Thiết kế Landing Page',
            status: AssignmentStatus.completed,
            dueDate: '2026-02-15',
            submittedAt: '2026-02-16',
            score: 70,
            maxScore: 100,
          ),
          StudentAssignmentModel(
            id: 'a2',
            title: 'Bài tập 2: Wireframe Mobile App',
            status: AssignmentStatus.incomplete,
            dueDate: '2026-02-28',
          ),
          StudentAssignmentModel(
            id: 'a3',
            title: 'Bài tập 3: Design System',
            status: AssignmentStatus.incomplete,
            dueDate: '2026-03-15',
          ),
        ],
        attendanceSummary: AttendanceSummaryModel(
          totalSessions: 12,
          presentCount: 6,
          absentCount: 4,
          lateCount: 1,
          excusedCount: 1,
        ),
      ),
    };

    return mockStudents[studentId] ??
        StudentDetailModel(
          id: studentId,
          studentCode: 'STU999',
          fullName: 'Học viên',
          progress: 0,
          parent: const ParentModel(
            id: 'p0',
            fullName: 'Phụ huynh',
          ),
          assignments: const [],
        );
  }
}
