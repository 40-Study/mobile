import 'package:flutter/foundation.dart';
import 'package:study/features/student/data/mock/mock_course_detail_data.dart';
import 'package:study/features/student/data/mock/mock_lesson_detail_data.dart';
import 'package:study/features/student/data/models/course_detail_model.dart';
import 'package:study/features/student/data/models/lesson_detail_model.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/data/student_api_client.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl({required StudentApiClient apiClient})
      : _api = apiClient;

  final StudentApiClient _api;

  /// Enable mock data when API fails (for development).
  static const _useMockOnError = true;

  @override
  Future<StudentStatsModel> getStats() async {
    try {
      final results = await Future.wait([
        getClasses(),
        getEnrollments(),
        getUpcomingLivestreams(),
      ]);

      final classes = results[0] as List<StudentClassModel>;
      final enrollments = results[1] as List<EnrollmentModel>;
      final livestreams = results[2] as List<StudentScheduleModel>;

      // Calculate overall progress
      double totalProgress = 0;
      for (final e in enrollments) {
        totalProgress += e.progress;
      }
      final avgProgress =
          enrollments.isNotEmpty ? totalProgress / enrollments.length : 0;

      // Calculate attendance rate
      double totalAttendance = 0;
      for (final c in classes) {
        totalAttendance += c.attendanceRate;
      }
      final avgAttendance =
          classes.isNotEmpty ? totalAttendance / classes.length : 0;

      return StudentStatsModel(
        totalClasses: classes.length,
        totalCourses: enrollments.length,
        todayLivestreams:
            livestreams.where((l) => l.isUpcoming || l.isLive).length,
        overallProgress: avgProgress.toDouble(),
        attendanceRate: avgAttendance.toDouble(),
      );
    } catch (e) {
      debugPrint('getStats error: $e');
      if (_useMockOnError) {
        return const StudentStatsModel(
          totalClasses: 7,
          totalCourses: 5,
          todayLivestreams: 3,
          overallProgress: 128.0,
          attendanceRate: 92.5,
          averageScore: 8.3,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<StudentScheduleModel>> getTodaySchedule() async {
    try {
      // Get from classes schedules and livestreams
      final classes = await getClasses();
      final schedules = <StudentScheduleModel>[];

      for (final cls in classes.take(5)) {
        try {
          final response = await _api.getClassSchedules(cls.id);
          final data = response.data;
          final List<dynamic>? items =
              _parseList(data, 'schedules') ?? _parseList(data, 'data');

          if (items != null) {
            schedules.addAll(
              items.map(
                (e) => StudentScheduleModel.fromJson(e as Map<String, dynamic>),
              ),
            );
          }
        } catch (_) {
          // Skip if schedule fetch fails
        }
      }

      if (schedules.isEmpty && _useMockOnError) {
        return _getMockTodaySchedule();
      }

      // Filter for today and sort by time
      final now = DateTime.now();
      final todaySchedules = schedules.where((s) {
        if (s.startTime == null) return false;
        try {
          final dt = DateTime.parse(s.startTime!);
          return dt.year == now.year &&
              dt.month == now.month &&
              dt.day == now.day;
        } catch (_) {
          return false;
        }
      }).toList();

      todaySchedules.sort((a, b) {
        final aTime = DateTime.tryParse(a.startTime ?? '') ?? DateTime.now();
        final bTime = DateTime.tryParse(b.startTime ?? '') ?? DateTime.now();
        return aTime.compareTo(bTime);
      });

      return todaySchedules;
    } catch (e) {
      debugPrint('getTodaySchedule error: $e');
      if (_useMockOnError) return _getMockTodaySchedule();
      rethrow;
    }
  }

  List<StudentScheduleModel> _getMockTodaySchedule() {
    final today = DateTime.now();
    String _dt(int hour, int minute) =>
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}T'
        '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}:00';

    return [
      StudentScheduleModel(
        id: '1',
        title: 'Buoi 12: Xu ly tap hop du lieu lon voi MongoDB & Node.js',
        className: 'Lap trinh Web Fullstack',
        teacherName: 'Thay Minh Hoang',
        startTime: _dt(8, 0),
        endTime: _dt(10, 0),
        status: 'live',
        isLivestream: true,
        meetingUrl: 'https://zoom.us/j/123',
      ),
      StudentScheduleModel(
        id: '2',
        title: 'Buoi 08: Thiet ke he thong Design System chuyen nghiep',
        className: 'UI/UX Advanced Design',
        teacherName: 'Co Lan Phuong',
        startTime: _dt(13, 30),
        endTime: _dt(15, 30),
        status: 'upcoming',
      ),
      StudentScheduleModel(
        id: '3',
        title: 'Buoi 24: Ky nang thuyet trinh truoc dam dong',
        className: 'Tieng Anh Giao Tiep',
        teacherName: 'Mr. David Smith',
        startTime: _dt(18, 0),
        endTime: _dt(20, 0),
        status: 'upcoming',
      ),
    ];
  }

  @override
  Future<List<EnrollmentModel>> getEnrollments({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.getEnrollments(
        page: page,
        pageSize: pageSize,
        status: status,
      );

      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'enrollments') ??
          _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getEnrollments error: $e');
      if (_useMockOnError) return _getMockEnrollments(status);
      rethrow;
    }
  }

  /// Mock enrollments theo API DOCS - GET /enrollments
  /// Response: EnrollmentListResponseDTO
  List<EnrollmentModel> _getMockEnrollments(String? status) {
    final enrollments = [
      const EnrollmentModel(
        id: 'enroll-001',
        userId: 'user-001',
        courseId: 'course-001',
        enrolledAt: '2024-01-15T10:00:00Z',
        progressPercentage: '75.5',
        lastAccessedAt: '2024-03-23T14:30:00Z',
        courseTitle: 'Lap trinh React Native nang cao',
        courseSlug: 'lap-trinh-react-native-nang-cao',
        courseThumbnail: 'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400',
        courseCategory: 'Mobile Development',
        // Legacy fields
        courseName: 'Lap trinh React Native nang cao',
        instructorName: 'Tran Hoang Nam',
        progress: 75,
        lastLearned: '2 ngay truoc',
        nextLesson: 'Lesson 13 - Navigation va Deep Linking',
        totalLessons: 16,
        completedLessons: 12,
        status: 'active',
      ),
      const EnrollmentModel(
        id: 'enroll-002',
        userId: 'user-001',
        courseId: 'course-002',
        enrolledAt: '2024-02-01T08:00:00Z',
        progressPercentage: '30.0',
        lastAccessedAt: '2024-03-16T09:15:00Z',
        courseTitle: 'Thiet ke UI/UX cho nguoi moi bat dau',
        courseSlug: 'thiet-ke-ui-ux-cho-nguoi-moi',
        courseThumbnail: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400',
        courseCategory: 'Design',
        courseName: 'Thiet ke UI/UX cho nguoi moi bat dau',
        instructorName: 'Nguyen Thuy Linh',
        progress: 30,
        lastLearned: '1 tuan truoc',
        nextLesson: 'Lesson 4 - Wireframe va Prototyping',
        totalLessons: 12,
        completedLessons: 4,
        status: 'active',
      ),
      const EnrollmentModel(
        id: 'enroll-003',
        userId: 'user-001',
        courseId: 'course-003',
        enrolledAt: '2024-01-20T11:00:00Z',
        progressPercentage: '90.0',
        lastAccessedAt: '2024-03-25T10:00:00Z',
        courseTitle: 'Phan tich du lieu voi Python',
        courseSlug: 'phan-tich-du-lieu-voi-python',
        courseThumbnail: 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=400',
        courseCategory: 'Data Science',
        courseName: 'Phan tich du lieu voi Python',
        instructorName: 'Le Quang Minh',
        progress: 90,
        lastLearned: 'Hom nay',
        nextLesson: 'Lesson 19 - Data Visualization nang cao',
        totalLessons: 20,
        completedLessons: 18,
        status: 'active',
      ),
      const EnrollmentModel(
        id: 'enroll-004',
        userId: 'user-001',
        courseId: 'course-004',
        enrolledAt: '2024-03-10T14:00:00Z',
        progressPercentage: '5.0',
        lastAccessedAt: '2024-03-22T16:45:00Z',
        courseTitle: 'Marketing Ky thuat so 4.0',
        courseSlug: 'marketing-ky-thuat-so-4-0',
        courseThumbnail: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400',
        courseCategory: 'Marketing',
        courseName: 'Marketing Ky thuat so 4.0',
        instructorName: 'Pham Phuong Thao',
        progress: 5,
        lastLearned: '3 ngay truoc',
        nextLesson: 'Lesson 2 - Content Marketing',
        totalLessons: 20,
        completedLessons: 1,
        status: 'active',
      ),
      const EnrollmentModel(
        id: 'enroll-005',
        userId: 'user-001',
        courseId: 'course-005',
        enrolledAt: '2023-09-01T08:00:00Z',
        progressPercentage: '100.0',
        completedAt: '2024-02-15T17:30:00Z',
        lastAccessedAt: '2024-02-15T17:30:00Z',
        courseTitle: 'Flutter Mobile Development Masterclass',
        courseSlug: 'flutter-mobile-development-masterclass',
        courseThumbnail: 'https://images.unsplash.com/photo-1617040619263-41c5a9ca7521?w=400',
        courseCategory: 'Mobile Development',
        courseName: 'Flutter Mobile Development Masterclass',
        instructorName: 'Thay Pham Van D',
        progress: 100,
        lastLearned: '1 thang truoc',
        nextLesson: '',
        totalLessons: 30,
        completedLessons: 30,
        status: 'completed',
      ),
      const EnrollmentModel(
        id: 'enroll-006',
        userId: 'user-001',
        courseId: 'course-006',
        enrolledAt: '2023-11-01T09:00:00Z',
        progressPercentage: '100.0',
        completedAt: '2024-03-10T11:00:00Z',
        lastAccessedAt: '2024-03-10T11:00:00Z',
        courseTitle: 'JavaScript ES6+ va Design Patterns',
        courseSlug: 'javascript-es6-design-patterns',
        courseThumbnail: 'https://images.unsplash.com/photo-1579468118864-1b9ea3c0db4a?w=400',
        courseCategory: 'Web Development',
        courseName: 'JavaScript ES6+ va Design Patterns',
        instructorName: 'Thay Tran Van B',
        progress: 100,
        lastLearned: '2 tuan truoc',
        nextLesson: '',
        totalLessons: 20,
        completedLessons: 20,
        status: 'completed',
      ),
      const EnrollmentModel(
        id: 'enroll-007',
        userId: 'user-001',
        courseId: 'course-007',
        enrolledAt: '2023-06-15T10:00:00Z',
        progressPercentage: '100.0',
        completedAt: '2023-12-20T14:00:00Z',
        lastAccessedAt: '2023-12-20T14:00:00Z',
        courseTitle: 'Data Science co ban voi Python',
        courseSlug: 'data-science-co-ban-voi-python',
        courseThumbnail: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
        courseCategory: 'Data Science',
        courseName: 'Data Science co ban voi Python',
        instructorName: 'Co Hoang Thi E',
        progress: 100,
        lastLearned: '3 thang truoc',
        nextLesson: '',
        totalLessons: 15,
        completedLessons: 15,
        status: 'completed',
      ),
      const EnrollmentModel(
        id: 'enroll-008',
        userId: 'user-001',
        courseId: 'course-008',
        enrolledAt: '2024-03-20T08:00:00Z',
        progressPercentage: '0',
        courseTitle: 'Thiet ke he thong phan mem - System Design',
        courseSlug: 'thiet-ke-he-thong-phan-mem',
        courseThumbnail: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=400',
        courseCategory: 'Software Architecture',
        courseName: 'Thiet ke he thong phan mem - System Design',
        instructorName: 'Vo Thanh Tung',
        progress: 0,
        totalLessons: 24,
        completedLessons: 0,
        status: 'pending',
      ),
      const EnrollmentModel(
        id: 'enroll-009',
        userId: 'user-001',
        courseId: 'course-009',
        enrolledAt: '2024-03-22T09:00:00Z',
        progressPercentage: '0',
        courseTitle: 'Kubernetes va DevOps cho nguoi moi',
        courseSlug: 'kubernetes-devops-cho-nguoi-moi',
        courseThumbnail: 'https://images.unsplash.com/photo-1667372393119-3d4c48d07fc9?w=400',
        courseCategory: 'DevOps',
        courseName: 'Kubernetes va DevOps cho nguoi moi',
        instructorName: 'Nguyen Duc Huy',
        progress: 0,
        totalLessons: 18,
        completedLessons: 0,
        status: 'pending',
      ),
    ];

    if (status != null && status.isNotEmpty && status != 'all') {
      return enrollments
          .where((e) => e.status.toLowerCase() == status.toLowerCase())
          .toList();
    }
    return enrollments;
  }

  @override
  Future<EnrollmentModel> getEnrollmentDetail(String id) async {
    try {
      final response = await _api.getEnrollment(id);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return EnrollmentModel.fromJson(data);
    } catch (e) {
      debugPrint('getEnrollmentDetail error: $e');
      if (_useMockOnError) {
        return const EnrollmentModel(
          id: '1',
          courseId: 'c1',
          courseName: 'Python Co ban cho Nguoi moi',
          instructorName: 'Thay Nguyen Van A',
          progress: 75,
          lastLearned: '2 ngay truoc',
          nextLesson: 'Lesson 15 - Functions',
          totalLessons: 20,
          completedLessons: 15,
          status: 'active',
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<StudentClassModel>> getClasses({
    String? status,
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
      final List<dynamic>? items =
          _parseList(data, 'classes') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => StudentClassModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getClasses error: $e');
      if (_useMockOnError) return _getMockClasses(status);
      rethrow;
    }
  }

  List<StudentClassModel> _getMockClasses(String? status) {
    final classes = [
      const StudentClassModel(
        id: '1',
        name: 'Lop Toan 10A1',
        description: 'Lop Toan nang cao cho hoc sinh khoi 10',
        teacherName: 'Thay Nguyen Van A',
        scheduleText: 'T2, T4, T6 - 08:00',
        attendanceRate: 90,
        averageScore: 8.5,
        studentCount: 25,
        maxStudents: 30,
        status: 'active',
      ),
      const StudentClassModel(
        id: '2',
        name: 'Lop Tieng Anh IELTS',
        description: 'Luyen thi IELTS band 6.5+',
        teacherName: 'Co Tran Thi B',
        scheduleText: 'T3, T5 - 14:00',
        attendanceRate: 85,
        averageScore: 7.8,
        studentCount: 20,
        maxStudents: 25,
        status: 'active',
      ),
      const StudentClassModel(
        id: '3',
        name: 'Lop Vat Ly 11',
        description: 'On thi dai hoc mon Vat Ly',
        teacherName: 'Thay Le Van C',
        scheduleText: 'T7 - 09:00',
        attendanceRate: 95,
        averageScore: 9.0,
        studentCount: 18,
        maxStudents: 20,
        status: 'active',
      ),
    ];

    if (status != null && status.isNotEmpty && status != 'all') {
      return classes
          .where((c) => c.status.toLowerCase() == status.toLowerCase())
          .toList();
    }
    return classes;
  }

  @override
  Future<StudentClassModel> getClassDetail(String id) async {
    try {
      final response = await _api.getClass(id);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return StudentClassModel.fromJson(data);
    } catch (e) {
      debugPrint('getClassDetail error: $e');
      if (_useMockOnError) {
        return const StudentClassModel(
          id: '1',
          name: 'Lop Toan 10A1',
          description: 'Lop Toan nang cao cho hoc sinh khoi 10',
          teacherName: 'Thay Nguyen Van A',
          scheduleText: 'T2, T4, T6 - 08:00',
          attendanceRate: 90,
          averageScore: 8.5,
          studentCount: 25,
          maxStudents: 30,
          status: 'active',
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<StudentScheduleModel>> getUpcomingLivestreams({
    int limit = 5,
  }) async {
    try {
      final response = await _api.getUpcomingLivestreams(
        pageSize: limit,
        status: 'upcoming',
      );

      final data = response.data;
      final List<dynamic>? items = _parseList(data, 'livestreams') ??
          _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => StudentScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getUpcomingLivestreams error: $e');
      if (_useMockOnError) return _getMockLivestreams(limit);
      rethrow;
    }
  }

  List<StudentScheduleModel> _getMockLivestreams(int limit) {
    return [
      const StudentScheduleModel(
        id: '1',
        title: 'On tap chuong 3 - Ham so',
        className: 'Lop Toan 10A1',
        teacherName: 'Thay Nguyen Van A',
        startTime: '2024-03-25T08:00:00',
        status: 'live',
        isLivestream: true,
      ),
      const StudentScheduleModel(
        id: '2',
        title: 'Speaking Practice - Part 2',
        className: 'Lop Tieng Anh IELTS',
        teacherName: 'Co Tran Thi B',
        startTime: '2024-03-25T14:00:00',
        status: 'upcoming',
        isLivestream: true,
      ),
    ].take(limit).toList();
  }

  @override
  Future<void> updateLessonProgress(String lessonId, int progress) async {
    try {
      await _api.updateLessonProgress(lessonId, {'progress': progress});
    } catch (e) {
      debugPrint('updateLessonProgress error: $e');
      // Silently fail in mock mode
      if (!_useMockOnError) rethrow;
    }
  }

  @override
  Future<EnrollmentModel> enrollCourse(String courseId) async {
    try {
      final response = await _api.enrollCourse(courseId);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return EnrollmentModel.fromJson(data);
    } catch (e) {
      debugPrint('enrollCourse error: $e');
      if (_useMockOnError) {
        return EnrollmentModel(
          id: 'new-${DateTime.now().millisecondsSinceEpoch}',
          courseId: courseId,
          courseName: 'Khoa hoc moi',
          progress: 0,
          status: 'active',
        );
      }
      rethrow;
    }
  }

  @override
  Future<CourseDetailModel> getCourseDetail({
    required String enrollmentId,
    required String courseId,
  }) async {
    try {
      final response = await _api.getCourseDetail(courseId);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      // TODO: Parse from API response when available
      return MockCourseDetailData.getCourseDetail(courseId);
    } catch (e) {
      debugPrint('getCourseDetail error: $e');
      if (_useMockOnError) {
        return MockCourseDetailData.getCourseDetail(courseId);
      }
      rethrow;
    }
  }

  @override
  Future<LessonDetailModel> getLessonDetail(String lessonId) async {
    try {
      final response = await _api.getLessonDetail(lessonId);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      // TODO: Parse from API response when available
      return MockLessonDetailData.getLessonDetail(lessonId);
    } catch (e) {
      debugPrint('getLessonDetail error: $e');
      if (_useMockOnError) {
        return MockLessonDetailData.getLessonDetail(lessonId);
      }
      rethrow;
    }
  }

  @override
  Future<void> unenrollCourse(String courseId) async {
    try {
      await _api.unenrollCourse(courseId);
    } catch (e) {
      debugPrint('unenrollCourse error: $e');
      if (!_useMockOnError) rethrow;
    }
  }

  // ==========================================================================
  // CART
  // ==========================================================================

  @override
  Future<CartModel> getCart() async {
    try {
      final response = await _api.getCart();
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return CartModel.fromJson(data);
    } catch (e) {
      debugPrint('getCart error: $e');
      if (_useMockOnError) {
        return const CartModel(items: [], total: 0, totalItem: 0);
      }
      rethrow;
    }
  }

  @override
  Future<void> addToCart(String courseId) async {
    try {
      await _api.addToCart({'course_id': courseId});
    } catch (e) {
      debugPrint('addToCart error: $e');
      if (!_useMockOnError) rethrow;
    }
  }

  @override
  Future<void> removeFromCart(List<String> courseIds) async {
    try {
      await _api.removeFromCart({'course_ids': courseIds});
    } catch (e) {
      debugPrint('removeFromCart error: $e');
      if (!_useMockOnError) rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _api.clearCart();
    } catch (e) {
      debugPrint('clearCart error: $e');
      if (!_useMockOnError) rethrow;
    }
  }

  @override
  Future<bool> isCourseInCart(String courseId) async {
    try {
      final response = await _api.checkCourseInCart(courseId);
      final data = response.data;
      return data['in_cart'] == true || data['data']?['in_cart'] == true;
    } catch (e) {
      debugPrint('isCourseInCart error: $e');
      if (_useMockOnError) return false;
      rethrow;
    }
  }

  // ==========================================================================
  // ORDERS
  // ==========================================================================

  @override
  Future<OrderModel> createOrder({
    required String source,
    required List<String> courseIds,
    String? couponCode,
  }) async {
    try {
      final body = <String, dynamic>{
        'source': source,
        'course_ids': courseIds,
      };
      if (couponCode != null) body['coupon_code'] = couponCode;

      final response = await _api.createOrder(body);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    } catch (e) {
      debugPrint('createOrder error: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.getOrders(
        page: page,
        pageSize: pageSize,
        status: status,
      );

      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'orders') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getOrders error: $e');
      if (_useMockOnError) return [];
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderDetail(String id) async {
    try {
      final response = await _api.getOrder(id);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    } catch (e) {
      debugPrint('getOrderDetail error: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // ASSIGNMENTS
  // ==========================================================================

  @override
  Future<List<AssignmentModel>> getAssignments({
    String? sessionId,
    String? classId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.getAssignments(
        sessionId: sessionId,
        classId: classId,
        page: page,
        pageSize: pageSize,
      );

      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'assignments') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getAssignments error: $e');
      if (_useMockOnError) return _getMockAssignments();
      rethrow;
    }
  }

  List<AssignmentModel> _getMockAssignments() {
    return const [
      AssignmentModel(
        id: 'assign-001',
        title: 'Two Sum',
        description: 'Tim 2 so trong mang co tong bang target',
        difficulty: 'easy',
        timeLimit: 1000,
        memoryLimit: 256,
        languages: ['python', 'javascript', 'java'],
        dueDate: '2024-04-01T23:59:59Z',
        maxSubmissions: 10,
        submissionCount: 3,
        bestScore: 100,
        status: 'open',
      ),
      AssignmentModel(
        id: 'assign-002',
        title: 'Reverse Linked List',
        description: 'Dao nguoc danh sach lien ket',
        difficulty: 'medium',
        timeLimit: 2000,
        memoryLimit: 256,
        languages: ['python', 'javascript', 'java', 'cpp'],
        dueDate: '2024-04-05T23:59:59Z',
        maxSubmissions: 5,
        submissionCount: 1,
        bestScore: 80,
        status: 'open',
      ),
      AssignmentModel(
        id: 'assign-003',
        title: 'Binary Tree Level Order Traversal',
        description: 'Duyet cay nhi phan theo tang',
        difficulty: 'hard',
        timeLimit: 3000,
        memoryLimit: 512,
        languages: ['python', 'java'],
        dueDate: '2024-04-10T23:59:59Z',
        maxSubmissions: 3,
        submissionCount: 0,
        status: 'open',
      ),
    ];
  }

  @override
  Future<AssignmentModel> getAssignmentDetail(String id) async {
    try {
      final response = await _api.getAssignment(id);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return AssignmentModel.fromJson(data);
    } catch (e) {
      debugPrint('getAssignmentDetail error: $e');
      if (_useMockOnError) {
        return const AssignmentModel(
          id: 'assign-001',
          title: 'Two Sum',
          description: 'Tim 2 so trong mang co tong bang target',
          difficulty: 'easy',
          timeLimit: 1000,
          memoryLimit: 256,
          languages: ['python', 'javascript', 'java'],
        );
      }
      rethrow;
    }
  }

  @override
  Future<AssignmentSandboxModel> getAssignmentSandbox(String id) async {
    try {
      final response = await _api.getAssignmentSandbox(id);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return AssignmentSandboxModel.fromJson(data);
    } catch (e) {
      debugPrint('getAssignmentSandbox error: $e');
      if (_useMockOnError) {
        return const AssignmentSandboxModel(
          id: 'assign-001',
          title: 'Two Sum',
          description:
              'Cho mot mang so nguyen nums va mot so nguyen target, tra ve chi so cua 2 so co tong bang target.',
          difficulty: 'easy',
          timeLimit: 1000,
          memoryLimit: 256,
          languages: ['python', 'javascript', 'java'],
          starterCode: {
            'python': 'def twoSum(nums, target):\n    # Your code here\n    pass',
            'javascript':
                'function twoSum(nums, target) {\n    // Your code here\n}',
          },
          sampleTests: [
            SampleTestModel(
              input: '[2,7,11,15]\n9',
              expectedOutput: '[0,1]',
              explanation: 'nums[0] + nums[1] = 2 + 7 = 9',
            ),
          ],
        );
      }
      rethrow;
    }
  }

  // ==========================================================================
  // SUBMISSIONS
  // ==========================================================================

  @override
  Future<SubmissionModel> submitAssignment({
    required String assignmentId,
    required String language,
    required String code,
  }) async {
    try {
      final response = await _api.submitAssignment({
        'assignment_id': assignmentId,
        'language': language,
        'code': code,
      });
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return SubmissionModel.fromJson(data);
    } catch (e) {
      debugPrint('submitAssignment error: $e');
      rethrow;
    }
  }

  @override
  Future<RunCodeResultModel> runCode({
    required String assignmentId,
    required String language,
    required String code,
  }) async {
    try {
      final response = await _api.runCode({
        'assignment_id': assignmentId,
        'language': language,
        'code': code,
      });
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return RunCodeResultModel.fromJson(data);
    } catch (e) {
      debugPrint('runCode error: $e');
      rethrow;
    }
  }

  @override
  Future<SubmissionModel> getSubmissionDetail(String id) async {
    try {
      final response = await _api.getSubmission(id);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return SubmissionModel.fromJson(data);
    } catch (e) {
      debugPrint('getSubmissionDetail error: $e');
      rethrow;
    }
  }

  @override
  Future<List<SubmissionModel>> getSubmissions({
    String? assignmentId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.getSubmissions(
        assignmentId: assignmentId,
        page: page,
        pageSize: pageSize,
      );

      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'submissions') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => SubmissionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getSubmissions error: $e');
      if (_useMockOnError) return [];
      rethrow;
    }
  }

  // ==========================================================================
  // NOTIFICATIONS
  // ==========================================================================

  @override
  Future<NotificationListModel> getNotifications({
    bool? isRead,
    String? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.getNotifications(
        isRead: isRead,
        type: type,
        page: page,
        pageSize: pageSize,
      );

      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return NotificationListModel.fromJson(data);
    } catch (e) {
      debugPrint('getNotifications error: $e');
      if (_useMockOnError) {
        return const NotificationListModel(
          notifications: [],
          total: 0,
          unreadCount: 0,
        );
      }
      rethrow;
    }
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _api.getUnreadNotificationCount();
      final data = response.data;
      return (data['count'] ?? data['data']?['count'] ?? 0) as int;
    } catch (e) {
      debugPrint('getUnreadNotificationCount error: $e');
      if (_useMockOnError) return 0;
      rethrow;
    }
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    try {
      await _api.markNotificationAsRead(id);
    } catch (e) {
      debugPrint('markNotificationAsRead error: $e');
      if (!_useMockOnError) rethrow;
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _api.markAllNotificationsAsRead();
    } catch (e) {
      debugPrint('markAllNotificationsAsRead error: $e');
      if (!_useMockOnError) rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _api.deleteNotification(id);
    } catch (e) {
      debugPrint('deleteNotification error: $e');
      if (!_useMockOnError) rethrow;
    }
  }

  // ==========================================================================
  // GAMIFICATION
  // ==========================================================================

  @override
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final response = await _api.getAchievements();

      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'achievements') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getAchievements error: $e');
      if (_useMockOnError) return _getMockAchievements();
      rethrow;
    }
  }

  List<AchievementModel> _getMockAchievements() {
    return const [
      AchievementModel(
        id: 'ach-001',
        name: 'Nguoi moi bat dau',
        description: 'Hoan thanh khoa hoc dau tien',
        iconUrl: 'https://example.com/icons/beginner.png',
        category: 'learning',
        pointsReward: 100,
        requirementType: 'courses_completed',
        requirementValue: 1,
        isUnlocked: true,
        unlockedAt: '2024-02-15T10:00:00Z',
        rarity: 'common',
      ),
      AchievementModel(
        id: 'ach-002',
        name: 'Hoc vien cham chi',
        description: 'Hoc 7 ngay lien tuc',
        iconUrl: 'https://example.com/icons/streak.png',
        category: 'streak',
        pointsReward: 200,
        requirementType: 'streak_days',
        requirementValue: 7,
        isUnlocked: true,
        unlockedAt: '2024-03-01T10:00:00Z',
        rarity: 'uncommon',
      ),
      AchievementModel(
        id: 'ach-003',
        name: 'Code Master',
        description: 'Giai 50 bai tap lap trinh',
        iconUrl: 'https://example.com/icons/codemaster.png',
        category: 'coding',
        pointsReward: 500,
        requirementType: 'assignments_completed',
        requirementValue: 50,
        isUnlocked: false,
        progress: 0.6,
        currentValue: 30,
        rarity: 'rare',
      ),
    ];
  }

  @override
  Future<List<AchievementModel>> getMyAchievements() async {
    try {
      final response = await _api.getMyAchievements();

      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'achievements') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getMyAchievements error: $e');
      if (_useMockOnError) {
        return _getMockAchievements().where((a) => a.isUnlocked).toList();
      }
      rethrow;
    }
  }

  @override
  Future<LeaderboardModel> getLeaderboard({
    String periodType = 'weekly',
    int limit = 50,
  }) async {
    try {
      final response = await _api.getLeaderboard(
        periodType: periodType,
        limit: limit,
      );

      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return LeaderboardModel.fromJson(data);
    } catch (e) {
      debugPrint('getLeaderboard error: $e');
      if (_useMockOnError) return _getMockLeaderboard();
      rethrow;
    }
  }

  LeaderboardModel _getMockLeaderboard() {
    return const LeaderboardModel(
      periodType: 'weekly',
      entries: [
        LeaderboardEntryModel(
          userId: 'user-001',
          userName: 'Nguyen Van A',
          rank: 1,
          points: 1500,
          coursesCompleted: 5,
          lessonsCompleted: 120,
          streakDays: 30,
        ),
        LeaderboardEntryModel(
          userId: 'user-002',
          userName: 'Tran Thi B',
          rank: 2,
          points: 1350,
          coursesCompleted: 4,
          lessonsCompleted: 100,
          streakDays: 25,
        ),
        LeaderboardEntryModel(
          userId: 'user-003',
          userName: 'Le Van C',
          rank: 3,
          points: 1200,
          coursesCompleted: 3,
          lessonsCompleted: 85,
          streakDays: 20,
        ),
      ],
      totalParticipants: 500,
    );
  }

  @override
  Future<LeaderboardEntryModel> getMyRank() async {
    try {
      final response = await _api.getMyRank();
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return LeaderboardEntryModel.fromJson(data);
    } catch (e) {
      debugPrint('getMyRank error: $e');
      if (_useMockOnError) {
        return const LeaderboardEntryModel(
          userId: 'current-user',
          userName: 'Ban',
          rank: 42,
          points: 850,
          coursesCompleted: 2,
          lessonsCompleted: 45,
          streakDays: 10,
        );
      }
      rethrow;
    }
  }

  // ==========================================================================
  // VOUCHERS
  // ==========================================================================

  @override
  Future<List<VoucherModel>> getPublicVouchers() async {
    try {
      final response = await _api.getPublicVouchers();

      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'vouchers') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => VoucherModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getPublicVouchers error: $e');
      if (_useMockOnError) return _getMockVouchers();
      rethrow;
    }
  }

  List<VoucherModel> _getMockVouchers() {
    return const [
      VoucherModel(
        id: 'voucher-001',
        code: 'NEWUSER50',
        name: 'Giam 50% cho nguoi moi',
        description: 'Ap dung cho nguoi dung moi, giam toi da 500K',
        discountType: 'percentage',
        discountValue: 50,
        maxDiscount: 500000,
        minOrderValue: 200000,
        endDate: '2024-04-30T23:59:59Z',
        isActive: true,
        isPublic: true,
      ),
      VoucherModel(
        id: 'voucher-002',
        code: 'SPRING100K',
        name: 'Giam 100K mua Xuan',
        description: 'Giam truc tiep 100K cho don tu 300K',
        discountType: 'fixed',
        discountValue: 100000,
        minOrderValue: 300000,
        endDate: '2024-05-15T23:59:59Z',
        isActive: true,
        isPublic: true,
      ),
    ];
  }

  @override
  Future<VoucherModel> getVoucherByCode(String code) async {
    try {
      final response = await _api.getVoucherByCode(code);
      final data = response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>;
      return VoucherModel.fromJson(data);
    } catch (e) {
      debugPrint('getVoucherByCode error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveVoucher(String id) async {
    try {
      await _api.saveVoucher(id);
    } catch (e) {
      debugPrint('saveVoucher error: $e');
      if (!_useMockOnError) rethrow;
    }
  }

  @override
  Future<void> unsaveVoucher(String id) async {
    try {
      await _api.unsaveVoucher(id);
    } catch (e) {
      debugPrint('unsaveVoucher error: $e');
      if (!_useMockOnError) rethrow;
    }
  }

  @override
  Future<List<VoucherModel>> getMySavedVouchers() async {
    try {
      final response = await _api.getMySavedVouchers();

      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'vouchers') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => VoucherModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getMySavedVouchers error: $e');
      if (_useMockOnError) return [];
      rethrow;
    }
  }

  // ==========================================================================
  // DISCUSSIONS / FORUM
  // ==========================================================================

  @override
  Future<List<ForumPostModel>> getDiscussions({
    String? category,
    String? sort,
    int page = 1,
    int pageSize = 20,
  }) async {
    // TODO: Implement API call when available
    if (_useMockOnError) return _getMockDiscussions();
    return [];
  }

  List<ForumPostModel> _getMockDiscussions() {
    return [
      ForumPostModel(
        id: 'd1',
        slug: 'cach-hoc-lap-trinh-hieu-qua',
        title: 'Cach hoc lap trinh hieu qua cho nguoi moi bat dau?',
        content: 'Minh moi bat dau hoc lap trinh, moi nguoi co the chia se kinh nghiem khong?',
        category: DiscussionCategory.learningTips,
        authorId: 'u1',
        authorName: 'Nguyen Van A',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        upvoteCount: 15,
        replyCount: 8,
        userVote: VoteType.none,
      ),
      ForumPostModel(
        id: 'd2',
        slug: 'review-khoa-hoc-python',
        title: 'Review khoa hoc Python cho nguoi moi',
        content: 'Minh da hoan thanh khoa hoc Python, day la nhung diem minh thich...',
        category: DiscussionCategory.programming,
        authorId: 'u2',
        authorName: 'Tran Thi B',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        upvoteCount: 42,
        replyCount: 12,
        userVote: VoteType.upvote,
      ),
    ];
  }

  @override
  Future<ForumPostModel> getDiscussion(String slug) async {
    // TODO: Implement API call when available
    if (_useMockOnError) {
      return ForumPostModel(
        id: 'd1',
        slug: slug,
        title: 'Cach hoc lap trinh hieu qua cho nguoi moi bat dau?',
        content: 'Minh moi bat dau hoc lap trinh, moi nguoi co the chia se kinh nghiem khong? Minh dang tim hieu ve Python va JavaScript.',
        category: DiscussionCategory.learningTips,
        authorId: 'u1',
        authorName: 'Nguyen Van A',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        upvoteCount: 15,
        replyCount: 3,
        userVote: VoteType.none,
        comments: [
          CommentModel(
            id: 'c1',
            content: 'Ban nen bat dau voi Python, no de hoc hon.',
            authorId: 'u2',
            authorName: 'Tran Thi B',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      );
    }
    throw Exception('Discussion not found');
  }

  @override
  Future<ForumPostModel> createDiscussion({
    required String title,
    required String content,
    required String category,
  }) async {
    // TODO: Implement API call when available
    return ForumPostModel(
      id: 'new-${DateTime.now().millisecondsSinceEpoch}',
      slug: title.toLowerCase().replaceAll(' ', '-'),
      title: title,
      content: content,
      category: DiscussionCategory.fromString(category),
      authorId: 'current-user',
      authorName: 'Ban',
      createdAt: DateTime.now(),
      upvoteCount: 0,
      replyCount: 0,
    );
  }

  @override
  Future<void> voteDiscussion(String discussionId, VoteType voteType) async {
    // TODO: Implement API call when available
    debugPrint('Vote $voteType on discussion $discussionId');
  }

  @override
  Future<void> removeVote(String discussionId) async {
    // TODO: Implement API call when available
    debugPrint('Remove vote on discussion $discussionId');
  }

  @override
  Future<void> addComment(String slug, String content, {String? parentId}) async {
    // TODO: Implement API call when available
    debugPrint('Add comment to $slug: $content');
  }

  // ==========================================================================
  // LIVESTREAMS
  // ==========================================================================

  @override
  Future<List<LivestreamModel>> getLivestreams({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    // TODO: Implement API call when available
    if (_useMockOnError) return _getMockLivestreamModels();
    return [];
  }

  List<LivestreamModel> _getMockLivestreamModels() {
    return [
      LivestreamModel(
        id: 'ls1',
        title: 'On tap chuong 3 - Ham so',
        description: 'On tap kien thuc ve ham so cho ky thi giua ky',
        hostId: 'h1',
        hostName: 'Thay Nguyen Van A',
        status: LivestreamStatus.live,
        scheduledAt: DateTime.now(),
        maxViewers: 100,
        activeParticipants: 45,
        isRecorded: true,
        className: 'Lop Toan 10A1',
      ),
      LivestreamModel(
        id: 'ls2',
        title: 'Speaking Practice - Part 2',
        hostId: 'h2',
        hostName: 'Co Tran Thi B',
        status: LivestreamStatus.scheduled,
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        maxViewers: 50,
        isRecorded: false,
        className: 'Lop IELTS',
      ),
      LivestreamModel(
        id: 'ls3',
        title: 'Giai bai tap Vat Ly',
        hostId: 'h3',
        hostName: 'Thay Le Van C',
        status: LivestreamStatus.ended,
        scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
        startedAt: DateTime.now().subtract(const Duration(days: 1)),
        endedAt: DateTime.now().subtract(const Duration(hours: 22)),
        maxViewers: 80,
        isRecorded: true,
        className: 'Lop Vat Ly 11',
      ),
    ];
  }

  @override
  Future<LivestreamModel> getLivestream(String id) async {
    // TODO: Implement API call when available
    if (_useMockOnError) {
      return LivestreamModel(
        id: id,
        title: 'On tap chuong 3 - Ham so',
        description: 'On tap kien thuc ve ham so cho ky thi giua ky. Noi dung gom: dinh nghia ham so, tinh chat, do thi...',
        hostId: 'h1',
        hostName: 'Thay Nguyen Van A',
        status: LivestreamStatus.live,
        scheduledAt: DateTime.now(),
        maxViewers: 100,
        activeParticipants: 45,
        isRecorded: true,
        className: 'Lop Toan 10A1',
      );
    }
    throw Exception('Livestream not found');
  }

  // ==========================================================================
  // COURSES (Discovery)
  // ==========================================================================

  @override
  Future<List<CourseModel>> getTrendingCourses({int limit = 10}) async {
    try {
      final response = await _api.getTrendingCourses(limit: limit);
      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'courses') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getTrendingCourses error: $e');
      if (_useMockOnError) return _getMockTrendingCourses(limit);
      rethrow;
    }
  }

  List<CourseModel> _getMockTrendingCourses(int limit) {
    return [
      const CourseModel(
        id: 'tc1',
        title: 'Python cho Data Science',
        description: 'Hoc Python tu co ban den nang cao cho phan tich du lieu',
        thumbnail: 'https://picsum.photos/400/225?random=1',
        instructorName: 'Thay Nguyen AI',
        category: 'Data Science',
        level: 'Intermediate',
        price: 499000,
        originalPrice: 999000,
        rating: 4.8,
        ratingCount: 1250,
        studentCount: 5420,
        lessonCount: 85,
        totalDuration: 720,
        isTrending: true,
        isBestseller: true,
      ),
      const CourseModel(
        id: 'tc2',
        title: 'Flutter Mobile Development',
        description: 'Xay dung ung dung di dong da nen tang voi Flutter',
        thumbnail: 'https://picsum.photos/400/225?random=2',
        instructorName: 'Co Tran Flutter',
        category: 'Mobile Development',
        level: 'Beginner',
        price: 399000,
        originalPrice: 799000,
        rating: 4.9,
        ratingCount: 890,
        studentCount: 3200,
        lessonCount: 120,
        totalDuration: 960,
        isTrending: true,
        isNew: true,
      ),
      const CourseModel(
        id: 'tc3',
        title: 'Machine Learning A-Z',
        description: 'Tu zero den hero trong Machine Learning',
        thumbnail: 'https://picsum.photos/400/225?random=3',
        instructorName: 'TS. Le ML',
        category: 'AI/ML',
        level: 'Advanced',
        price: 699000,
        rating: 4.7,
        ratingCount: 2100,
        studentCount: 8900,
        lessonCount: 150,
        totalDuration: 1200,
        isTrending: true,
      ),
      const CourseModel(
        id: 'tc4',
        title: 'Web Development Bootcamp',
        description: 'Full-stack web development tu HTML den Node.js',
        thumbnail: 'https://picsum.photos/400/225?random=4',
        instructorName: 'Anh Web Dev',
        category: 'Web Development',
        level: 'Beginner',
        price: 299000,
        originalPrice: 599000,
        rating: 4.6,
        ratingCount: 3500,
        studentCount: 12000,
        lessonCount: 200,
        totalDuration: 1800,
        isBestseller: true,
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<CourseModel>> getCourses({
    String? category,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.getCourses(
        category: category,
        search: search,
        page: page,
        pageSize: pageSize,
      );
      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'courses') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getCourses error: $e');
      if (_useMockOnError) return _getMockTrendingCourses(pageSize);
      rethrow;
    }
  }

  // ==========================================================================
  // COMPETITIONS
  // ==========================================================================

  @override
  Future<List<CompetitionModel>> getCompetitions({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.getCompetitions(
        status: status,
        page: page,
        pageSize: pageSize,
      );
      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'competitions') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => CompetitionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getCompetitions error: $e');
      if (_useMockOnError) return _getMockCompetitions();
      rethrow;
    }
  }

  List<CompetitionModel> _getMockCompetitions() {
    final now = DateTime.now();
    return [
      CompetitionModel(
        id: 'comp1',
        title: 'Code Challenge Thang 4',
        description: 'Cuoc thi lap trinh hang thang danh cho hoc sinh',
        thumbnail: 'https://picsum.photos/400/225?random=10',
        startDate: now.add(const Duration(days: 2)).toIso8601String(),
        endDate: now.add(const Duration(days: 5)).toIso8601String(),
        participantCount: 234,
        prizePool: '10,000,000 VND',
        prizes: ['5,000,000 VND', '3,000,000 VND', '2,000,000 VND'],
        difficulty: 'Intermediate',
      ),
      CompetitionModel(
        id: 'comp2',
        title: 'AI Hackathon 2024',
        description: 'Xay dung ung dung AI trong 48 gio',
        thumbnail: 'https://picsum.photos/400/225?random=11',
        startDate: now.subtract(const Duration(hours: 5)).toIso8601String(),
        endDate: now.add(const Duration(days: 2)).toIso8601String(),
        participantCount: 89,
        maxParticipants: 100,
        prizePool: '50,000,000 VND',
        difficulty: 'Advanced',
        isJoined: true,
        myRank: 12,
      ),
      CompetitionModel(
        id: 'comp3',
        title: 'Algorithm Sprint',
        description: 'Giai cac bai toan thuat toan trong thoi gian ngan nhat',
        thumbnail: 'https://picsum.photos/400/225?random=12',
        startDate: now.add(const Duration(days: 7)).toIso8601String(),
        endDate: now.add(const Duration(days: 8)).toIso8601String(),
        participantCount: 567,
        prizePool: '20,000,000 VND',
        difficulty: 'Hard',
      ),
    ];
  }

  @override
  Future<CompetitionModel> getCompetitionDetail(String id) async {
    try {
      final response = await _api.getCompetition(id);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final compData = data['competition'] ?? data['data'] ?? data;
        return CompetitionModel.fromJson(compData as Map<String, dynamic>);
      }
      throw Exception('Invalid competition data');
    } catch (e) {
      debugPrint('getCompetitionDetail error: $e');
      if (_useMockOnError) {
        return _getMockCompetitions().firstWhere((c) => c.id == id);
      }
      rethrow;
    }
  }

  @override
  Future<void> joinCompetition(String id) async {
    try {
      await _api.joinCompetition(id);
    } catch (e) {
      debugPrint('joinCompetition error: $e');
      // Allow mock success
    }
  }

  // ==========================================================================
  // FEATURED CONTENT
  // ==========================================================================

  @override
  Future<List<ForumPostModel>> getFeaturedDiscussions({int limit = 5}) async {
    try {
      final response = await _api.getFeaturedDiscussions(limit: limit);
      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'discussions') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => ForumPostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getFeaturedDiscussions error: $e');
      if (_useMockOnError) return _getMockFeaturedDiscussions(limit);
      rethrow;
    }
  }

  List<ForumPostModel> _getMockFeaturedDiscussions(int limit) {
    final now = DateTime.now();
    return [
      ForumPostModel(
        id: 'fp1',
        slug: 'tips-hoc-python-hieu-qua',
        title: '10 Tips hoc Python hieu qua cho nguoi moi bat dau',
        content: 'Chia se kinh nghiem hoc Python tu zero den hero trong 3 thang...',
        authorId: 'u1',
        authorName: 'Python Master',
        category: DiscussionCategory.learningTips,
        upvoteCount: 156,
        replyCount: 45,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ForumPostModel(
        id: 'fp2',
        slug: 'flutter-vs-react-native-2024',
        title: 'Flutter vs React Native 2024: Nen chon gi?',
        content: 'Phan tich chi tiet uu nhuoc diem cua 2 framework...',
        authorId: 'u2',
        authorName: 'Mobile Dev',
        category: DiscussionCategory.programming,
        upvoteCount: 89,
        replyCount: 67,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      ForumPostModel(
        id: 'fp3',
        slug: 'du-an-portfolio-cho-sinh-vien',
        title: 'Y tuong du an portfolio cho sinh vien IT',
        content: 'Tong hop 20 y tuong du an giup ban noi bat khi xin viec...',
        authorId: 'u3',
        authorName: 'Career Coach',
        category: DiscussionCategory.project,
        upvoteCount: 234,
        replyCount: 89,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ].take(limit).toList();
  }

  @override
  Future<List<AssignmentModel>> getPendingAssignments({int limit = 10}) async {
    try {
      final response = await _api.getPendingAssignments(limit: limit);
      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'assignments') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getPendingAssignments error: $e');
      if (_useMockOnError) return _getMockPendingAssignments(limit);
      rethrow;
    }
  }

  List<AssignmentModel> _getMockPendingAssignments(int limit) {
    final now = DateTime.now();
    return [
      AssignmentModel(
        id: 'pa1',
        title: 'Bai tap: Ham so va Do thi',
        description: 'Giai cac bai tap ve ham so bac 2',
        classId: 'c1',
        className: 'Lop Toan 10A1',
        difficulty: 'Medium',
        dueDate: now.add(const Duration(days: 1)).toIso8601String(),
        maxSubmissions: 3,
        submissionCount: 0,
        languages: ['Python', 'C++'],
      ),
      AssignmentModel(
        id: 'pa2',
        title: 'Lab 5: Data Structures',
        description: 'Implement Stack and Queue',
        classId: 'c2',
        className: 'Lap trinh Python',
        difficulty: 'Hard',
        dueDate: now.add(const Duration(days: 3)).toIso8601String(),
        maxSubmissions: 5,
        submissionCount: 1,
        bestScore: 70,
        languages: ['Python'],
      ),
      AssignmentModel(
        id: 'pa3',
        title: 'Essay: Climate Change',
        description: 'Write a 500-word essay about climate change effects',
        classId: 'c3',
        className: 'Tieng Anh IELTS',
        difficulty: 'Easy',
        dueDate: now.add(const Duration(hours: 12)).toIso8601String(),
        maxSubmissions: 1,
        submissionCount: 0,
      ),
    ].take(limit).toList();
  }

  // ==========================================================================
  // SCHEDULES
  // ==========================================================================

  @override
  Future<List<StudentScheduleModel>> getWeekSchedules() async {
    try {
      final response = await _api.getWeekSchedules();
      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'schedules') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => StudentScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getWeekSchedules error: $e');
      if (_useMockOnError) return _getMockWeekSchedules();
      rethrow;
    }
  }

  List<StudentScheduleModel> _getMockWeekSchedules() {
    final now = DateTime.now();
    return [
      StudentScheduleModel(
        id: 'ws1',
        title: 'Bai 15: Ham so Bac 2',
        className: 'Lop Toan 10A1',
        teacherName: 'Thay Nguyen Van A',
        startTime: now.add(const Duration(hours: 2)).toIso8601String(),
        endTime: now.add(const Duration(hours: 4)).toIso8601String(),
        status: 'scheduled',
      ),
      StudentScheduleModel(
        id: 'ws2',
        title: 'Luyen nghe IELTS',
        className: 'Tieng Anh IELTS',
        teacherName: 'Co Tran Thi B',
        startTime: now.add(const Duration(days: 1, hours: 3)).toIso8601String(),
        endTime: now.add(const Duration(days: 1, hours: 5)).toIso8601String(),
        status: 'scheduled',
      ),
      StudentScheduleModel(
        id: 'ws3',
        title: 'Thuc hanh Vat Ly',
        className: 'Lop Vat Ly 11',
        teacherName: 'Thay Le Van C',
        startTime: now.add(const Duration(days: 2, hours: 1)).toIso8601String(),
        endTime: now.add(const Duration(days: 2, hours: 3)).toIso8601String(),
        status: 'scheduled',
      ),
      StudentScheduleModel(
        id: 'ws4',
        title: 'Python OOP',
        className: 'Lap trinh Python',
        teacherName: 'Co Pham Thi D',
        startTime: now.add(const Duration(days: 3, hours: 4)).toIso8601String(),
        endTime: now.add(const Duration(days: 3, hours: 6)).toIso8601String(),
        status: 'scheduled',
      ),
    ];
  }

  @override
  Future<List<StudentScheduleModel>> getMonthSchedules({
    int? month,
    int? year,
  }) async {
    try {
      final response = await _api.getMonthSchedules(month: month, year: year);
      final data = response.data;
      final List<dynamic>? items =
          _parseList(data, 'schedules') ?? _parseList(data, 'data');

      if (items == null) return [];

      return items
          .map((e) => StudentScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getMonthSchedules error: $e');
      if (_useMockOnError) return _getMockWeekSchedules(); // Reuse for simplicity
      rethrow;
    }
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
