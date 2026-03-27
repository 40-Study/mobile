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

  List<EnrollmentModel> _getMockEnrollments(String? status) {
    final enrollments = [
      const EnrollmentModel(
        id: '1',
        courseId: 'c1',
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
        id: '2',
        courseId: 'c2',
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
        id: '3',
        courseId: 'c3',
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
        id: '4',
        courseId: 'c4',
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
        id: '5',
        courseId: 'c5',
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
        id: '6',
        courseId: 'c6',
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
        id: '7',
        courseId: 'c7',
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
        id: '8',
        courseId: 'c8',
        courseName: 'Thiet ke he thong phan mem - System Design',
        instructorName: 'Vo Thanh Tung',
        progress: 0,
        totalLessons: 24,
        completedLessons: 0,
        status: 'pending',
      ),
      const EnrollmentModel(
        id: '9',
        courseId: 'c9',
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
