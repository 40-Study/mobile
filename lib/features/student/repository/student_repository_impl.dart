import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';

/// Mock implementation — replace với real API client sau
class StudentRepositoryImpl implements StudentRepository {
  @override
  Future<ApiResult<List<ScheduleItemModel>>> getTodaySchedule() async {
    return getScheduleByDate(DateTime.now());
  }

  @override
  Future<ApiResult<List<ScheduleItemModel>>> getScheduleByDate(
    DateTime date,
  ) async {
    // TODO: Wire up với real API
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Chỉ trả data cho những ngày có event (sync với _generateMockEventDates)
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final hasEvent = (date.day - 1) % 3 == 0 || isToday;

    if (!hasEvent) {
      return const Result.success([]);
    }

    // Mock data
    return Result.success([
      ScheduleItemModel(
        id: '1',
        title: 'Toán cao cấp A1',
        type: 'livestream',
        startTime: date.copyWith(hour: 9, minute: 0),
        endTime: date.copyWith(hour: 10, minute: 30),
        courseName: 'Toán 10',
        courseId: '1',
        lessonId: 'lesson-1',
        instructorName: 'Nguyễn Văn An',
        location: 'Phòng A101',
      ),
      ScheduleItemModel(
        id: '2',
        title: 'Python cơ bản - Bài 2.3',
        type: 'video',
        startTime: date.copyWith(hour: 14, minute: 0),
        endTime: date.copyWith(hour: 15, minute: 30),
        courseName: 'Python cơ bản',
        courseId: '1',
        lessonId: 'lesson-2',
        instructorName: 'Trần Minh Bình',
      ),
    ]);
  }

  @override
  Future<ApiResult<List<AssignmentModel>>> getPendingAssignments() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return Result.success([
      AssignmentModel(
        id: '1',
        title: 'Quiz: Biến và kiểu dữ liệu',
        type: 'quiz',
        courseName: 'Python cơ bản',
        questionCount: 10,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
      AssignmentModel(
        id: '2',
        title: 'Bài tập: Hàm số',
        type: 'assignment',
        courseName: 'Toán 10',
        questionCount: 5,
        dueDate: DateTime.now().add(const Duration(days: 5)),
      ),
    ]);
  }

  @override
  Future<ApiResult<List<EnrollmentModel>>> getActiveEnrollments() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Mock data
    return Result.success([
      EnrollmentModel(
        id: '1',
        status: 'active',
        progressPercentage: 45,
        completedLessons: 9,
        totalLessons: 20,
        lastAccessedAt: DateTime.now().subtract(const Duration(hours: 2)),
        course: const CourseModel(
          id: 'course-1',
          title: 'Python từ cơ bản đến ứng dụng',
          instructorName: 'Nguyễn Minh Anh',
          categoryName: 'Lập trình',
          totalLessons: 20,
        ),
      ),
      EnrollmentModel(
        id: '2',
        status: 'active',
        progressPercentage: 80,
        completedLessons: 16,
        totalLessons: 20,
        lastAccessedAt: DateTime.now().subtract(const Duration(days: 1)),
        course: const CourseModel(
          id: 'course-2',
          title: 'Toán tư duy lớp 10',
          instructorName: 'Trần Hoàng Nam',
          categoryName: 'Toán học',
          totalLessons: 20,
        ),
      ),
    ]);
  }

  @override
  Future<ApiResult<EnrollmentModel?>> getContinueLearning() async {
    final result = await getActiveEnrollments();

    return result.when(
      success: (enrollments) {
        if (enrollments.isEmpty) return const Result.success(null);

        // Sort by last accessed
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
  Future<ApiResult<EnrollmentModel>> getCourseDetail(
    String enrollmentId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Mock data với sections và lessons
    return Result.success(
      EnrollmentModel(
        id: enrollmentId,
        status: 'active',
        progressPercentage: 45,
        completedLessons: 9,
        totalLessons: 20,
        course: const CourseModel(
          id: 'course-1',
          title: 'Python cơ bản',
          shortDescription: 'Học lập trình Python từ cơ bản đến nâng cao',
          instructorName: 'Nguyễn Văn An',
          totalLessons: 20,
          totalSections: 4,
          totalDurationMins: 480,
          sections: [
            SectionModel(
              id: 'section-1',
              title: 'Giới thiệu Python',
              totalLessons: 5,
              totalDurationMins: 100,
              lessons: [
                LessonModel(
                  id: 'lesson-1',
                  title: 'Python là gì?',
                  durationMinutes: 15,
                  contents: [
                    LessonContentModel(id: 'c1-1', type: 'video', title: 'Giới thiệu về Python', duration: 300),
                    LessonContentModel(id: 'c1-2', type: 'video', title: 'Lịch sử phát triển', duration: 240),
                    LessonContentModel(id: 'c1-3', type: 'exercise', title: 'Bài tập kiểm tra', duration: 180),
                  ],
                  progress: LessonProgressModel(
                    status: 'completed',
                    progressPercentage: 100,
                  ),
                ),
                LessonModel(
                  id: 'lesson-2',
                  title: 'Cài đặt môi trường',
                  durationMinutes: 20,
                  contents: [
                    LessonContentModel(id: 'c2-1', type: 'video', title: 'Cài đặt Python trên Windows', duration: 360),
                    LessonContentModel(id: 'c2-2', type: 'video', title: 'Cài đặt Python trên Mac', duration: 300),
                    LessonContentModel(id: 'c2-3', type: 'article', title: 'Cấu hình IDE', duration: 240),
                  ],
                  progress: LessonProgressModel(
                    status: 'completed',
                    progressPercentage: 100,
                  ),
                ),
                LessonModel(
                  id: 'lesson-3',
                  title: 'Hello World',
                  durationMinutes: 10,
                  contents: [
                    LessonContentModel(id: 'c3-1', type: 'video', title: 'Chương trình đầu tiên', duration: 300),
                    LessonContentModel(id: 'c3-2', type: 'exercise', title: 'Thực hành viết code', duration: 180),
                  ],
                  progress: LessonProgressModel(
                    status: 'in_progress',
                    progressPercentage: 50,
                  ),
                ),
                LessonModel(
                  id: 'lesson-4',
                  title: 'Biến và hằng',
                  durationMinutes: 25,
                  contents: [
                    LessonContentModel(id: 'c4-1', type: 'video', title: 'Khai báo biến', duration: 420),
                    LessonContentModel(id: 'c4-2', type: 'video', title: 'Hằng số trong Python', duration: 300),
                    LessonContentModel(id: 'c4-3', type: 'exercise', title: 'Bài tập về biến', duration: 240),
                  ],
                ),
                LessonModel(
                  id: 'lesson-5',
                  title: 'Kiểu dữ liệu',
                  durationMinutes: 30,
                  contents: [
                    LessonContentModel(id: 'c5-1', type: 'video', title: 'Các kiểu dữ liệu cơ bản', duration: 480),
                    LessonContentModel(id: 'c5-2', type: 'video', title: 'Ép kiểu dữ liệu', duration: 360),
                    LessonContentModel(id: 'c5-3', type: 'exercise', title: 'Thực hành kiểu dữ liệu', duration: 300),
                  ],
                ),
              ],
            ),
            SectionModel(
              id: 'section-2',
              title: 'Cấu trúc điều khiển',
              totalLessons: 5,
              totalDurationMins: 110,
              lessons: [
                LessonModel(
                  id: 'lesson-6',
                  title: 'If-else',
                  durationMinutes: 20,
                  contents: [
                    LessonContentModel(id: 'c6-1', type: 'video', title: 'Câu lệnh if', duration: 360),
                    LessonContentModel(id: 'c6-2', type: 'video', title: 'Câu lệnh if-else', duration: 300),
                    LessonContentModel(id: 'c6-3', type: 'exercise', title: 'Bài tập if-else', duration: 240),
                  ],
                ),
                LessonModel(
                  id: 'lesson-7',
                  title: 'Vòng lặp for',
                  durationMinutes: 25,
                  contents: [
                    LessonContentModel(id: 'c7-1', type: 'video', title: 'Cú pháp vòng lặp for', duration: 420),
                    LessonContentModel(id: 'c7-2', type: 'video', title: 'Range trong Python', duration: 300),
                    LessonContentModel(id: 'c7-3', type: 'exercise', title: 'Thực hành vòng lặp', duration: 300),
                  ],
                ),
                LessonModel(
                  id: 'lesson-8',
                  title: 'Vòng lặp while',
                  durationMinutes: 20,
                  contents: [
                    LessonContentModel(id: 'c8-1', type: 'video', title: 'Cú pháp while', duration: 360),
                    LessonContentModel(id: 'c8-2', type: 'exercise', title: 'Bài tập while', duration: 240),
                  ],
                ),
                LessonModel(
                  id: 'lesson-9',
                  title: 'Break và continue',
                  durationMinutes: 15,
                  contents: [
                    LessonContentModel(id: 'c9-1', type: 'video', title: 'Sử dụng break', duration: 240),
                    LessonContentModel(id: 'c9-2', type: 'video', title: 'Sử dụng continue', duration: 240),
                  ],
                ),
                LessonModel(
                  id: 'lesson-10',
                  title: 'Bài tập tổng hợp',
                  durationMinutes: 30,
                  contents: [
                    LessonContentModel(id: 'c10-1', type: 'article', title: 'Hướng dẫn bài tập', duration: 300),
                    LessonContentModel(id: 'c10-2', type: 'exercise', title: 'Bài tập 1: FizzBuzz', duration: 600),
                    LessonContentModel(id: 'c10-3', type: 'exercise', title: 'Bài tập 2: Tìm số nguyên tố', duration: 600),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Future<ApiResult<LessonModel>> getLessonDetail(String lessonId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return Result.success(
      LessonModel(
        id: lessonId,
        title: 'Python là gì?',
        description:
            'Tìm hiểu về ngôn ngữ lập trình Python và ứng dụng của nó trong phát triển phần mềm, khoa học dữ liệu, và trí tuệ nhân tạo.',
        durationMinutes: 15,
        contents: const [
          LessonContentModel(
            id: 'content-1',
            type: 'video',
            title: 'Giới thiệu tổng quan về Python',
            videoUrl: 'https://example.com/video1.mp4',
            duration: 300,
          ),
          LessonContentModel(
            id: 'content-2',
            type: 'video',
            title: 'Lịch sử phát triển Python',
            videoUrl: 'https://example.com/video2.mp4',
            duration: 240,
          ),
          LessonContentModel(
            id: 'content-3',
            type: 'article',
            title: 'Tài liệu tham khảo',
            duration: 180,
          ),
          LessonContentModel(
            id: 'content-4',
            type: 'exercise',
            title: 'Bài tập kiểm tra kiến thức',
            duration: 300,
          ),
        ],
        progress: const LessonProgressModel(
          status: 'in_progress',
          progressPercentage: 50,
          videoWatchedSeconds: 450,
        ),
      ),
    );
  }

  @override
  Future<ApiResult<void>> markLessonComplete(String lessonId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const Result.success(null);
  }

  @override
  Future<ApiResult<List<BadgeModel>>> getBadges() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return Result.success([
      BadgeModel(
        id: '1',
        name: 'Người mới bắt đầu',
        description: 'Hoàn thành bài học đầu tiên',
        isEarned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 10)),
        category: 'learning',
      ),
      BadgeModel(
        id: '2',
        name: 'Học sinh chăm chỉ',
        description: 'Học 7 ngày liên tục',
        isEarned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 3)),
        category: 'streak',
      ),
      const BadgeModel(
        id: '3',
        name: 'Master Python',
        description: 'Hoàn thành khóa Python',
        category: 'course',
      ),
      const BadgeModel(
        id: '4',
        name: 'Quiz Champion',
        description: 'Đạt 100 điểm 5 bài quiz',
        category: 'quiz',
      ),
      const BadgeModel(
        id: '5',
        name: 'Người học nhanh',
        description: 'Hoàn thành 10 bài học trong 1 ngày',
        category: 'speed',
      ),
      const BadgeModel(
        id: '6',
        name: 'Học sinh xuất sắc',
        description: 'Hoàn thành 3 khóa học',
        category: 'learning',
      ),
    ]);
  }

  @override
  Future<ApiResult<StudentStatsModel>> getStats() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return const Result.success(
      StudentStatsModel(
        level: 5,
        currentXp: 750,
        nextLevelXp: 1000,
        streakDays: 7,
        totalCourses: 3,
        completedCourses: 1,
        totalLessons: 60,
        completedLessons: 25,
        totalQuizScore: 85.5,
        totalStudyHours: 24.5,
        weeklyStudyHours: [2.5, 3.0, 1.5, 4.0, 2.0, 5.5, 3.5],
      ),
    );
  }
}
