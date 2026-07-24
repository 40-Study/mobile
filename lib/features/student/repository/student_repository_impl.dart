import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/course/data/models/course_model.dart';
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

    // Mock data
    return Result.success([
      ScheduleItemModel(
        id: '1',
        title: 'Toan cao cap A1',
        type: 'livestream',
        startTime: DateTime.now().copyWith(hour: 9, minute: 0),
        endTime: DateTime.now().copyWith(hour: 10, minute: 30),
        courseName: 'Toan 10',
        instructorName: 'Nguyen Van A',
        location: 'Phong A101',
      ),
      ScheduleItemModel(
        id: '2',
        title: 'Python Co ban - Bai 2.3',
        type: 'video',
        startTime: DateTime.now().copyWith(hour: 14, minute: 0),
        endTime: DateTime.now().copyWith(hour: 15, minute: 30),
        courseName: 'Python Co ban',
        instructorName: 'Tran Van B',
      ),
    ]);
  }

  @override
  Future<ApiResult<List<AssignmentModel>>> getPendingAssignments() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return Result.success([
      AssignmentModel(
        id: '1',
        title: 'Quiz: Bien va kieu du lieu',
        type: 'quiz',
        courseName: 'Python Co ban',
        questionCount: 10,
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
      AssignmentModel(
        id: '2',
        title: 'Bai tap: Ham so',
        type: 'assignment',
        courseName: 'Toan 10',
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
      ),
      EnrollmentModel(
        id: '2',
        status: 'active',
        progressPercentage: 80,
        completedLessons: 16,
        totalLessons: 20,
        lastAccessedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  @override
  Future<ApiResult<EnrollmentModel?>> getContinueLearning() async {
    final result = await getActiveEnrollments();

    return result.when(
      success: (enrollments) {
        if (enrollments.isEmpty) return Result.success(null);

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
  Future<ApiResult<EnrollmentModel>> getCourseDetail(String enrollmentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Mock data với sections và lessons
    return Result.success(
      EnrollmentModel(
        id: enrollmentId,
        status: 'active',
        progressPercentage: 45,
        completedLessons: 9,
        totalLessons: 20,
        course: CourseModel(
          id: 'course-1',
          title: 'Python Co ban',
          shortDescription: 'Hoc lap trinh Python tu co ban den nang cao',
          instructorName: 'Nguyen Van A',
          totalLessons: 20,
          totalSections: 4,
          totalDurationMins: 480,
          sections: [
            SectionModel(
              id: 'section-1',
              title: 'Gioi thieu Python',
              totalLessons: 5,
              lessons: [
                LessonModel(
                  id: 'lesson-1',
                  title: 'Python la gi?',
                  durationMinutes: 15,
                  progress: const LessonProgressModel(
                    status: 'completed',
                    progressPercentage: 100,
                  ),
                ),
                LessonModel(
                  id: 'lesson-2',
                  title: 'Cai dat moi truong',
                  durationMinutes: 20,
                  progress: const LessonProgressModel(
                    status: 'completed',
                    progressPercentage: 100,
                  ),
                ),
                LessonModel(
                  id: 'lesson-3',
                  title: 'Hello World',
                  durationMinutes: 10,
                  progress: const LessonProgressModel(
                    status: 'in_progress',
                    progressPercentage: 50,
                  ),
                ),
                const LessonModel(id: 'lesson-4', title: 'Bien va hang', durationMinutes: 25),
                const LessonModel(id: 'lesson-5', title: 'Kieu du lieu', durationMinutes: 30),
              ],
            ),
            SectionModel(
              id: 'section-2',
              title: 'Cau truc dieu khien',
              totalLessons: 5,
              lessons: [
                const LessonModel(id: 'lesson-6', title: 'If-else', durationMinutes: 20),
                const LessonModel(id: 'lesson-7', title: 'Vong lap for', durationMinutes: 25),
                const LessonModel(id: 'lesson-8', title: 'Vong lap while', durationMinutes: 20),
                const LessonModel(id: 'lesson-9', title: 'Break va continue', durationMinutes: 15),
                const LessonModel(id: 'lesson-10', title: 'Bai tap tong hop', durationMinutes: 30),
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
        title: 'Python la gi?',
        description: 'Tim hieu ve ngon ngu lap trinh Python va ung dung cua no.',
        durationMinutes: 15,
        contents: [
          const LessonContentModel(
            id: 'content-1',
            type: 'video',
            title: 'Video bai giang',
            videoUrl: 'https://example.com/video.mp4',
            duration: 900,
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
    return Result.success(null);
  }

  @override
  Future<ApiResult<List<BadgeModel>>> getBadges() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return Result.success([
      BadgeModel(
        id: '1',
        name: 'Nguoi moi bat dau',
        description: 'Hoan thanh bai hoc dau tien',
        isEarned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 10)),
        category: 'learning',
      ),
      BadgeModel(
        id: '2',
        name: 'Hoc sinh cham chi',
        description: 'Hoc 7 ngay lien tuc',
        isEarned: true,
        earnedAt: DateTime.now().subtract(const Duration(days: 3)),
        category: 'streak',
      ),
      const BadgeModel(
        id: '3',
        name: 'Master Python',
        description: 'Hoan thanh khoa Python',
        category: 'course',
      ),
      const BadgeModel(
        id: '4',
        name: 'Quiz Champion',
        description: 'Dat 100 diem 5 bai quiz',
        category: 'quiz',
      ),
      const BadgeModel(
        id: '5',
        name: 'Nguoi hoc nhanh',
        description: 'Hoan thanh 10 bai hoc trong 1 ngay',
        category: 'speed',
      ),
      const BadgeModel(
        id: '6',
        name: 'Hoc sinh xuat sac',
        description: 'Hoan thanh 3 khoa hoc',
        category: 'learning',
      ),
    ]);
  }

  @override
  Future<ApiResult<StudentStatsModel>> getStats() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return Result.success(const StudentStatsModel(
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
    ));
  }
}
