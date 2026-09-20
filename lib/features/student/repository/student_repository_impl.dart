import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';
import 'package:study/data/last_accessed_course_storage.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/course/data/course_api_client.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/student_api_client.dart';
import 'package:study/features/student/repository/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl({
    required StudentApiClient studentApi,
    required CourseApiClient courseApi,
    required AuthRepository authRepository,
    required LastAccessedCourseStorage lastAccessedStorage,
  })  : _studentApi = studentApi,
        _courseApi = courseApi,
        _authRepository = authRepository,
        _lastAccessedStorage = lastAccessedStorage;

  final StudentApiClient _studentApi;
  final CourseApiClient _courseApi;
  final AuthRepository _authRepository;
  final LastAccessedCourseStorage _lastAccessedStorage;

  Future<String?> _getCurrentUserId() async {
    final user = await _authRepository.getSavedUser();
    return user?.id;
  }

  @override
  Future<ApiResult<List<ScheduleItemModel>>> getTodaySchedule() {
    return getScheduleByDate(DateTime.now());
  }

  List<dynamic> _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) {
      // Check common wrapper keys
      for (final key in ['items', 'data', 'courses', 'enrollments', 'notifications', 'badges', 'certificates']) {
        final nested = data[key];
        if (nested is List) return nested;
      }
      // Handle Map with numeric string keys like {"0": ..., "1": ...}
      if (data.keys.every((k) => int.tryParse(k.toString()) != null)) {
        return data.values.toList();
      }
    }
    return [];
  }

  // Flatten nested instructor/category to top-level fields for CourseModel
  Map<String, dynamic> _normalizeCourse(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    final instructor = json['instructor'];
    if (instructor is Map) {
      result['instructor_name'] ??= instructor['name'];
      // API returns 'avatar', model expects 'instructor_avatar'
      result['instructor_avatar'] ??= instructor['avatar'] ?? instructor['avatar_url'];
    }
    final category = json['category'];
    if (category is Map) {
      result['category_name'] ??= category['name'];
    }
    // Handle price as String from API
    if (result['price'] is String) {
      result['price'] = double.tryParse(result['price'] as String) ?? 0;
    }
    return result;
  }

  @override
  Future<ApiResult<List<ScheduleItemModel>>> getScheduleByDate(DateTime date) async {
    try {
      final response = await _studentApi.getMyTimetable();
      final entries = _extractList(response.data['data']?['entries']);

      // Filter by day_of_week (0=Sunday, 1=Monday matching DateTime.weekday where 1=Monday, 7=Sunday)
      final targetDayOfWeek = date.weekday == 7 ? 0 : date.weekday;
      final filtered = entries.where((e) => e['day_of_week'] == targetDayOfWeek);

      // Transform to ScheduleItemModel format
      final items = filtered.map((e) {
        final startTimeStr = e['start_time'] as String? ?? '00:00:00';
        final endTimeStr = e['end_time'] as String? ?? '00:00:00';
        final startParts = startTimeStr.split(':');
        final endParts = endTimeStr.split(':');

        return ScheduleItemModel(
          id: e['schedule_id'] as String? ?? '',
          title: e['class_name'] as String? ?? 'Class',
          type: 'class',
          classId: e['class_id'] as String?,
          courseId: e['course_id'] as String?,
          lessonId: e['lesson_id'] as String?,
          instructorName: e['instructor_name'] as String?,
          startTime: DateTime(date.year, date.month, date.day,
            int.tryParse(startParts[0]) ?? 0, int.tryParse(startParts[1]) ?? 0),
          endTime: DateTime(date.year, date.month, date.day,
            int.tryParse(endParts[0]) ?? 0, int.tryParse(endParts[1]) ?? 0),
          location: e['room'] as String?,
        );
      }).toList();

      return Result.success(items);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<Set<DateTime>>> getEventDates(DateTime month) async {
    try {
      // Get timetable to know which days have classes
      final response = await _studentApi.getMyTimetable();
      final entries = _extractList(response.data['data']?['entries']);

      // Get all day_of_week values from timetable
      final daysOfWeek = entries
          .map((e) => e['day_of_week'] as int)
          .toSet();

      // Generate all dates in month that match those days
      final dates = <DateTime>{};
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      for (var d = firstDay; !d.isAfter(lastDay); d = d.add(const Duration(days: 1))) {
        final dow = d.weekday == 7 ? 0 : d.weekday;
        if (daysOfWeek.contains(dow)) {
          dates.add(DateTime(d.year, d.month, d.day));
        }
      }

      return Result.success(dates);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<AssignmentModel>>> getPendingAssignments() async {
    try {
      // Use enrollments to get pending assignments
      final response = await _courseApi.getMyEnrollments(status: 'active');
      final data = _extractList(response.data['data']);
      debugPrint('📋 Enrollments count: ${data.length}');

      // Collect assignments from enrollments
      final assignments = <AssignmentModel>[];
      for (final enrollment in data) {
        final enrollmentId = enrollment['id'] as String?;
        final assignmentList = enrollment['pending_assignments'] as List? ?? [];
        debugPrint('📋 Enrollment $enrollmentId: ${assignmentList.length} assignments');
        debugPrint('📋 Raw: $assignmentList');
        for (final e in assignmentList) {
          final json = Map<String, dynamic>.from(e as Map);
          json['enrollment_id'] = enrollmentId;
          assignments.add(AssignmentModel.fromJson(json));
        }
      }
      debugPrint('📋 Total assignments: ${assignments.length}');
      return Result.success(assignments);
    } catch (e) {
      debugPrint('📋 Error: $e');
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  // Transform flat course_* fields to nested course object
  Map<String, dynamic> _normalizeEnrollment(Map<String, dynamic> json) {
    final result = Map<String, dynamic>.from(json);
    // If no nested course but has course_* fields, build course object
    if (result['course'] == null && result['course_id'] != null) {
      result['course'] = {
        'id': result['course_id'],
        'title': result['course_title'],
        'slug': result['course_slug'],
        'thumbnail_url': result['course_thumbnail'],
        'category_name': result['course_category'],
      };
    } else if (result['course'] is Map<String, dynamic>) {
      // Normalize existing course (flatten instructor/category)
      result['course'] = _normalizeCourse(result['course'] as Map<String, dynamic>);
    }
    return result;
  }

  @override
  Future<ApiResult<List<EnrollmentModel>>> getActiveEnrollments() async {
    try {
      final response = await _courseApi.getMyEnrollments(status: 'active');
      final list = _extractList(response.data['data']);
      return Result.success(
        list.map((e) => EnrollmentModel.fromJson(_normalizeEnrollment(e as Map<String, dynamic>))).toList(),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<EnrollmentModel?>> getContinueLearning() async {
    final result = await getActiveEnrollments();
    return result.when(
      success: (enrollments) {
        if (enrollments.isEmpty) return const Result.success(null);

        // Ưu tiên local storage
        final lastId = _lastAccessedStorage.getLastEnrollmentId();
        if (lastId != null) {
          final match = enrollments.where((e) => e.id == lastId).firstOrNull;
          if (match != null) return Result.success(match);
        }

        // Fallback: sort by lastAccessedAt từ API
        enrollments.sort((a, b) {
          final aTime = a.lastAccessedAt ?? DateTime(1970);
          final bTime = b.lastAccessedAt ?? DateTime(1970);
          return bTime.compareTo(aTime);
        });
        return Result.success(enrollments.first);
      },
      failure: Result.failure,
    );
  }

  @override
  Future<void> setLastAccessedCourse(String enrollmentId) async {
    await _lastAccessedStorage.setLastAccessed(enrollmentId);
  }

  @override
  Future<ApiResult<EnrollmentModel>> getCourseDetail(String enrollmentId) async {
    try {
      final response = await _courseApi.getEnrollment(enrollmentId);
      final enrollmentJson = response.data['data'] as Map<String, dynamic>;

      // Fetch course detail with sections/lessons if courseId exists
      final courseId = enrollmentJson['course_id'] as String?;
      if (courseId != null) {
        try {
          final courseResponse = await _courseApi.getCourse(courseId);
          final courseJson = courseResponse.data['data'] as Map<String, dynamic>?;
          if (courseJson != null) {
            // Normalize course to flatten instructor/category
            enrollmentJson['course'] = _normalizeCourse(courseJson);
          }
        } catch (_) {
          // Course fetch failed, continue with enrollment only
        }
      }

      return Result.success(
        EnrollmentModel.fromJson(_normalizeEnrollment(enrollmentJson)),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<LessonModel>> getLessonDetail(String lessonId) async {
    try {
      final response = await _courseApi.getLesson(lessonId);
      final data = response.data['data'] as Map<String, dynamic>;

      // Debug: check if API returns video content
      debugPrint('Lesson API response: $data');
      final contents = data['contents'] as List?;
      if (contents != null) {
        for (final c in contents) {
          debugPrint('Content: type=${c['type']}, video_url=${c['video_url']}');
        }
      }

      return Result.success(LessonModel.fromJson(data));
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<bool>> markLessonComplete(
    String lessonId, {
    List<List<int>>? playedRanges,
    int? durationSeconds,
  }) async {
    try {
      final body = <String, dynamic>{
        'status': 'completed',
        'progress_percentage': 100,
      };
      if (playedRanges != null) body['played_ranges'] = playedRanges;
      if (durationSeconds != null) body['duration_seconds'] = durationSeconds;
      final response = await _courseApi.updateLessonProgress(lessonId, body);
      final courseCompleted = response.data['data']?['course_completed'] == true;
      return Result.success(courseCompleted);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _studentApi.getNotifications();
      final list = _extractList(response.data['data']);
      return Result.success(
        list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<int>> getUnreadNotificationCount() async {
    try {
      final response = await _studentApi.getUnreadCount();
      final count = response.data['data']['count'] as int? ?? 0;
      return Result.success(count);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> markNotificationRead(String id) async {
    try {
      await _studentApi.markRead(id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> markAllNotificationsRead() async {
    try {
      await _studentApi.markAllRead();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<BadgeModel>>> getBadges() async {
    try {
      final response = await _studentApi.getMyAchievements();
      final data = response.data['data'];
      // Backend returns array directly, not nested under 'badges'
      final list = _extractList(data);
      return Result.success(
        list.map((e) => BadgeModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<CertificateModel>>> getCertificates() async {
    try {
      final response = await _courseApi.getMyCertificates();
      final list = _extractList(response.data['data']);
      return Result.success(
        list.map((e) => CertificateModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<StudentStatsModel>> getStats() async {
    try {
      // Get userId from auth to fetch public profile stats
      final userId = await _getCurrentUserId();
      if (userId == null) {
        return const Result.success(StudentStatsModel());
      }
      final response = await _studentApi.getPublicProfile(userId);
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) {
        return const Result.success(StudentStatsModel());
      }
      final stats = data['stats'] as Map<String, dynamic>?;
      if (stats == null) {
        return const Result.success(StudentStatsModel());
      }
      return Result.success(StudentStatsModel.fromJson(stats));
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<QuizQuestionModel>>> getQuizQuestions(String quizId) async {
    try {
      final response = await _studentApi.getQuizQuestions(quizId);
      final list = _extractList(response.data['data']);
      return Result.success(
        list.map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<({String attemptId, List<QuizQuestionModel> questions, int timeLimitMinutes})>> startQuiz(String quizId) async {
    try {
      final response = await _studentApi.startQuiz(quizId);
      final data = response.data['data'] as Map<String, dynamic>;
      final attemptId = data['attempt_id'] as String? ?? '';
      final list = _extractList(data['questions']);
      final timeLimitMinutes = (data['time_limit_minutes'] as num?)?.toInt() ?? 10;
      return Result.success((
        attemptId: attemptId,
        questions: list.map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>)).toList(),
        timeLimitMinutes: timeLimitMinutes,
      ));
    } on DioException catch (e) {
      final message = e.response?.data?['error'] as String? ??
          e.response?.data?['message'] as String? ??
          'Không thể bắt đầu quiz';
      final displayMessage = switch (message) {
        'max attempts reached' => 'Bạn đã hết lượt làm bài kiểm tra này',
        _ => message,
      };
      return Result.failure(ServerFailure(message: displayMessage));
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<QuizSubmitResult>> submitQuiz(
    String quizId,
    String attemptId,
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final response = await _studentApi.submitQuiz(quizId, {
        'attempt_id': attemptId,
        'answers': answers,
      });
      return Result.success(
        QuizSubmitResult.fromJson(response.data['data'] as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<QuizModel>>> getQuizzesByLesson(String lessonId) async {
    try {
      final response = await _studentApi.getQuizzesByLesson(lessonId);
      final list = _extractList(response.data['data']);
      return Result.success(
        list.map((e) => QuizModel.fromJson(e as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<CourseModel>>> searchCourses(String query) async {
    try {
      final response = await _studentApi.searchCourses(query: query);
      final list = _extractList(response.data['data']);
      return Result.success(
        list.map((e) => CourseModel.fromJson(_normalizeCourse(e as Map<String, dynamic>))).toList(),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<CourseModel>>> getAllCourses({int page = 1}) async {
    try {
      final response = await _courseApi.getCourses(page: page);
      final list = _extractList(response.data['data']);
      return Result.success(
        list.map((e) => CourseModel.fromJson(_normalizeCourse(e as Map<String, dynamic>))).toList(),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<CourseModel>> getCourseById(String courseId) async {
    try {
      final response = await _courseApi.getCourse(courseId);
      final data = response.data['data'] as Map<String, dynamic>;
      return Result.success(
        CourseModel.fromJson(_normalizeCourse(data)),
      );
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ContributionModel>>> getContributions(String userId) async {
    try {
      final response = await _studentApi.getPublicProfile(userId);
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return const Result.success([]);

      final activityList = data['activity'] as List<dynamic>? ?? [];
      final contributions = activityList
          .map((e) => ContributionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Result.success(contributions);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<String?>> getCourseIdFromClass(String classId) async {
    try {
      final response = await _studentApi.getClass(classId);
      final courseId = response.data['data']?['course_id'] as String?;
      return Result.success(courseId);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }
}
