import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/models/class_model.dart';
import 'package:study/features/teacher/data/models/teacher_course_detail_model.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';

part 'teacher_course_detail_state.dart';

class TeacherCourseDetailCubit extends Cubit<TeacherCourseDetailState> {
  TeacherCourseDetailCubit({
    required TeacherRepository repository,
    required this.courseId,
  })  : _repository = repository,
        super(const TeacherCourseDetailInitial());

  // ignore: unused_field
  final TeacherRepository _repository;
  final String courseId;

  Future<void> load() async {
    debugPrint('TeacherCourseDetailCubit: Loading course $courseId');
    emit(const TeacherCourseDetailLoading());

    try {
      // TODO: Replace with actual API call
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final detail = _getMockCourseDetail(courseId);
      debugPrint('TeacherCourseDetailCubit: Loaded ${detail.title}');
      emit(TeacherCourseDetailLoaded(detail: detail));
    } catch (e) {
      debugPrint('TeacherCourseDetailCubit: Error $e');
      emit(TeacherCourseDetailFailure(message: e.toString()));
    }
  }

  void changeTab(int index) {
    final currentState = state;
    if (currentState is TeacherCourseDetailLoaded) {
      emit(currentState.copyWith(currentTab: index));
    }
  }

  Future<void> refresh() async {
    await load();
  }

  TeacherCourseDetailModel _getMockCourseDetail(String id) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    String formatDate(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    return TeacherCourseDetailModel(
      id: id,
      title: 'Thiết kế UI/UX Nâng cao 2024',
      description: '''Khóa học này được thiết kế để giúp bạn làm chủ các kỹ năng cần thiết trong kỷ nguyên số. Chúng tôi tập trung vào việc thực hành thực tế, giải quyết các bài toán thực tế mà một chuyên gia thường gặp phải.

Với lộ trình bài bản từ cơ bản đến nâng cao, bạn sẽ không chỉ học lý thuyết mà còn được tham gia vào các dự án thực tế để củng cố kiến thức và xây dựng portfolio cá nhân ấn tượng.''',
      thumbnail:
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400',
      badge: 'PRO COURSE',
      status: 'published',
      categoryName: 'Design',
      price: 1990000,
      originalPrice: 2990000,
      discountPercent: 33,
      isOnSale: true,
      studentCount: 1240,
      classCount: 12,
      rating: 4.8,
      reviewCount: 256,
      progressPercent: 75,
      totalLessons: 36,
      publishedLessons: 27,
      totalRevenue: 2468600000,
      monthlyRevenue: 198000000,
      learningOutcomes: const [
        'Nắm vững kiến thức nền tảng và tư duy hệ thống chuyên nghiệp.',
        'Thành thạo các công cụ thiết kế hiện đại như Figma, Adobe XD.',
        'Xây dựng portfolio cá nhân ấn tượng với các dự án thực tế.',
        'Hiểu rõ quy trình làm việc với khách hàng và team development.',
        'Áp dụng Design System vào dự án thực tế.',
      ],
      chapters: const [
        TeacherChapterModel(
          id: 'ch1',
          title: 'Chương 1: Giới thiệu UI/UX Design',
          order: 1,
          totalLessons: 5,
          publishedLessons: 5,
          lessons: [
            TeacherLessonModel(
              id: 'l1',
              title: 'Bài 1: UI/UX là gì?',
              duration: '12:30',
              status: TeacherLessonStatus.published,
              viewCount: 1150,
            ),
            TeacherLessonModel(
              id: 'l2',
              title: 'Bài 2: Tư duy thiết kế (Design Thinking)',
              duration: '18:45',
              status: TeacherLessonStatus.published,
              viewCount: 980,
            ),
            TeacherLessonModel(
              id: 'l3',
              title: 'Bài 3: Các nguyên tắc thiết kế cơ bản',
              duration: '22:10',
              status: TeacherLessonStatus.published,
              viewCount: 920,
            ),
            TeacherLessonModel(
              id: 'l4',
              title: 'Bài 4: Công cụ thiết kế phổ biến',
              duration: '15:00',
              status: TeacherLessonStatus.published,
              viewCount: 850,
            ),
            TeacherLessonModel(
              id: 'l5',
              title: 'Bài 5: Quiz & Bài tập chương 1',
              duration: '10:00',
              status: TeacherLessonStatus.published,
              viewCount: 780,
            ),
          ],
        ),
        TeacherChapterModel(
          id: 'ch2',
          title: 'Chương 2: Làm quen với Figma',
          order: 2,
          totalLessons: 8,
          publishedLessons: 8,
          lessons: [
            TeacherLessonModel(
              id: 'l6',
              title: 'Bài 1: Cài đặt và giao diện Figma',
              duration: '14:20',
              status: TeacherLessonStatus.published,
              viewCount: 1050,
            ),
            TeacherLessonModel(
              id: 'l7',
              title: 'Bài 2: Các công cụ cơ bản',
              duration: '20:30',
              status: TeacherLessonStatus.published,
              viewCount: 920,
            ),
            TeacherLessonModel(
              id: 'l8',
              title: 'Bài 3: Auto Layout',
              duration: '25:00',
              status: TeacherLessonStatus.published,
              viewCount: 880,
            ),
          ],
        ),
        TeacherChapterModel(
          id: 'ch3',
          title: 'Chương 3: Components & Design System',
          order: 3,
          totalLessons: 10,
          publishedLessons: 8,
          lessons: [
            TeacherLessonModel(
              id: 'l9',
              title: 'Bài 1: Tạo Components',
              duration: '18:00',
              status: TeacherLessonStatus.published,
              viewCount: 750,
            ),
            TeacherLessonModel(
              id: 'l10',
              title: 'Bài 2: Variants',
              duration: '22:30',
              status: TeacherLessonStatus.published,
              viewCount: 680,
            ),
            TeacherLessonModel(
              id: 'l11',
              title: 'Bài 3: Design Tokens',
              duration: '16:45',
              status: TeacherLessonStatus.draft,
              viewCount: 0,
            ),
            TeacherLessonModel(
              id: 'l12',
              title: 'Bài 4: Xây dựng Design System',
              duration: '30:00',
              status: TeacherLessonStatus.draft,
              viewCount: 0,
            ),
          ],
        ),
        TeacherChapterModel(
          id: 'ch4',
          title: 'Chương 4: Dự án thực tế',
          order: 4,
          totalLessons: 13,
          publishedLessons: 6,
          lessons: [
            TeacherLessonModel(
              id: 'l13',
              title: 'Bài 1: Brief dự án',
              duration: '10:00',
              status: TeacherLessonStatus.published,
              viewCount: 620,
            ),
            TeacherLessonModel(
              id: 'l14',
              title: 'Bài 2: User Research',
              duration: '28:00',
              status: TeacherLessonStatus.published,
              viewCount: 580,
            ),
            TeacherLessonModel(
              id: 'l15',
              title: 'Bài 3: Wireframing',
              duration: '35:00',
              status: TeacherLessonStatus.processing,
              viewCount: 0,
            ),
          ],
        ),
      ],
      classes: [
        ClassModel(
          id: 'cls1',
          name: 'UI/UX Design - Khóa 5',
          courseId: id,
          courseName: 'Thiết kế UI/UX Nâng cao 2024',
          maxStudents: 25,
          studentCount: 22,
          status: 'active',
          nextScheduleDate: formatDate(today),
          nextScheduleTime: '14:00 - 16:00',
          nextScheduleRoom: 'Phòng 105, Tòa C',
        ),
        ClassModel(
          id: 'cls2',
          name: 'UI/UX Design - Khóa 6',
          courseId: id,
          courseName: 'Thiết kế UI/UX Nâng cao 2024',
          maxStudents: 30,
          studentCount: 18,
          status: 'active',
          nextScheduleDate: formatDate(today.add(const Duration(days: 1))),
          nextScheduleTime: '19:00 - 21:00',
          nextScheduleRoom: 'Online - Google Meet',
          isOnline: true,
        ),
        ClassModel(
          id: 'cls3',
          name: 'UI/UX Workshop',
          courseId: id,
          courseName: 'Thiết kế UI/UX Nâng cao 2024',
          maxStudents: 20,
          studentCount: 15,
          status: 'active',
          nextScheduleDate: formatDate(today.add(const Duration(days: 3))),
          nextScheduleTime: '09:00 - 12:00',
          nextScheduleRoom: 'Online - Zoom',
          isOnline: true,
        ),
        const ClassModel(
          id: 'cls4',
          name: 'UI/UX Design - Khóa 4',
          courseName: 'Thiết kế UI/UX Nâng cao 2024',
          maxStudents: 25,
          studentCount: 25,
          status: 'completed',
        ),
        const ClassModel(
          id: 'cls5',
          name: 'UI/UX Design - Khóa 3',
          courseName: 'Thiết kế UI/UX Nâng cao 2024',
          maxStudents: 20,
          studentCount: 20,
          status: 'completed',
        ),
      ],
      recentReviews: const [
        CourseReviewModel(
          id: 'r1',
          studentName: 'Nguyễn Văn An',
          rating: 5,
          comment:
              'Khóa học rất hay và chi tiết. Giảng viên nhiệt tình, dễ hiểu.',
          createdAt: '2 ngày trước',
        ),
        CourseReviewModel(
          id: 'r2',
          studentName: 'Lê Thị Bình',
          rating: 5,
          comment: 'Nội dung thực tế, áp dụng được ngay vào công việc.',
          createdAt: '1 tuần trước',
        ),
        CourseReviewModel(
          id: 'r3',
          studentName: 'Trần Minh Tâm',
          rating: 4,
          comment: 'Tốt nhưng mong có thêm bài tập thực hành.',
          createdAt: '2 tuần trước',
        ),
      ],
      createdAt: '2024-01-15',
      updatedAt: '2026-03-28',
    );
  }
}
