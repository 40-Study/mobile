import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';

/// Dữ liệu mẫu (Mock Data) hoàn chỉnh cho chi tiết khóa học, buổi học và bài học.
/// Dùng để test thông suốt toàn bộ UI Student mà không phụ thuộc vào Backend API / Database.
class MockCourseDetailData {
  const MockCourseDetailData._();

  static bool isMockId(String? id) {
    if (id == null || id.isEmpty) return true;
    return id.startsWith('course_') ||
        id.startsWith('mock_') ||
        id.startsWith('demo_') ||
        !id.contains('-');
  }

  static bool isMockLessonId(String? id) {
    if (id == null || id.isEmpty) return true;
    return id.startsWith('lesson_') ||
        id.startsWith('mock_') ||
        !id.contains('-');
  }

  static CourseDetailSuccess getMockCourseDetail(
    String id, {
    bool isEnrollment = true,
  }) {
    final meta = _mockCourseCatalog[id] ?? _defaultCourseMeta(id);

    final isEnrolled = isEnrollment || meta.isEnrolled;
    final progressPercentage = isEnrolled ? meta.progress : 0.0;
    final isCompleted = progressPercentage >= 100.0;

    final sections = _buildSections(id, isCompleted: isCompleted, progress: progressPercentage);
    final totalLessons = sections.fold<int>(0, (sum, s) => sum + (s.lessons?.length ?? 0));
    final completedLessons = isCompleted
        ? totalLessons
        : (totalLessons * (progressPercentage / 100)).round();

    final course = CourseModel(
      id: id,
      title: meta.title,
      slug: 'mock-$id',
      shortDescription: meta.shortDescription,
      description: meta.description,
      instructorId: 'instructor_tran_minh_tam',
      instructorName: meta.instructorName,
      categoryName: meta.category,
      level: meta.level,
      price: meta.price,
      discountPrice: meta.discountPrice,
      averageRating: meta.rating,
      totalRatings: meta.totalRatings,
      totalStudents: meta.studentCount,
      totalLessons: totalLessons,
      totalSections: sections.length,
      totalDurationMins: meta.durationMins,
      isEnrolled: isEnrolled,
      isFree: meta.price == 0,
      sections: sections,
      objectives: [
        'Nắm vững toàn diện quy trình và tư duy thiết kế sản phẩm số.',
        'Làm chủ công cụ thực chiến và kỹ năng làm việc nhóm Agile.',
        'Xây dựng Portfolio đồ án thực tế đạt tiêu chuẩn doanh nghiệp.',
      ],
      requirements: [
        'Thiết bị máy tính có kết nối Internet ổn định.',
        'Tinh thần học hỏi, không yêu cầu kinh nghiệm trước.',
      ],
      targetAudience: [
        'Học sinh, sinh viên yêu thích thiết kế và công nghệ.',
        'Người mới bắt đầu muốn chuyển hướng sự nghiệp.',
      ],
    );

    final certificate = isCompleted
        ? createMockCertificate(id, meta.title, meta.instructorName)
        : null;

    final enrollment = EnrollmentModel(
      id: isEnrolled ? 'enrollment_$id' : '',
      courseId: id,
      course: course,
      status: isEnrolled ? (isCompleted ? 'completed' : 'active') : 'preview',
      progressPercentage: progressPercentage,
      completedLessons: completedLessons,
      totalLessons: totalLessons,
      enrolledAt: DateTime.now().subtract(const Duration(days: 30)),
      completedAt: isCompleted ? DateTime.now().subtract(const Duration(days: 2)) : null,
      lastAccessedAt: DateTime.now(),
    );

    return CourseDetailSuccess(
      enrollment: enrollment,
      expandedSections: sections.isNotEmpty ? {sections.first.id} : {},
      isBookmarked: false,
      certificate: certificate,
    );
  }

  static CertificateModel createMockCertificate(
    String courseId,
    String? courseTitle, [
    String? instructorName,
  ]) {
    return CertificateModel(
      id: 'cert_$courseId',
      certificateNumber: 'CERT-40STUDY-${DateTime.now().year}-8899',
      userId: 'mock_student_user',
      userName: 'Học viên 40Study',
      courseId: courseId,
      courseTitle: courseTitle ?? 'Khóa học Thiết kế Chuyên nghiệp',
      instructorName: instructorName ?? 'Trần Minh Tâm',
      issueDate: DateTime.now().subtract(const Duration(days: 3)),
      certificateUrl: 'https://example.com/certificates/sample.pdf',
      isValid: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    );
  }

  static LessonModel getMockLesson(String lessonId) {
    return LessonModel(
      id: lessonId,
      title: 'Bài học mẫu: Hướng dẫn thực hành & Lý thuyết',
      description:
          'Bài học chi tiết cung cấp nền tảng lý thuyết, ví dụ trực quan và bài tập thực hành áp dụng ngay.',
      durationMinutes: 18,
      isPreview: true,
      isMandatory: true,
      progress: const LessonProgressModel(
        status: 'completed',
        progressPercentage: 100,
      ),
    );
  }

  static List<SectionModel> _buildSections(
    String courseId, {
    required bool isCompleted,
    required double progress,
  }) {
    return [
      SectionModel(
        id: '${courseId}_sec_1',
        courseId: courseId,
        title: 'Chương 1: Tổng quan & Khởi động tư duy',
        displayOrder: 1,
        totalLessons: 3,
        totalDurationMins: 45,
        lessons: [
          LessonModel(
            id: '${courseId}_les_1_1',
            sectionId: '${courseId}_sec_1',
            title: '1.1 Giới thiệu tổng quan và lộ trình học tập',
            durationMinutes: 10,
            isPreview: true,
            isMandatory: true,
            progress: const LessonProgressModel(
              status: 'completed',
              progressPercentage: 100,
            ),
          ),
          LessonModel(
            id: '${courseId}_les_1_2',
            sectionId: '${courseId}_sec_1',
            title: '1.2 Cài đặt môi trường và làm quen giao diện',
            durationMinutes: 15,
            isPreview: true,
            isMandatory: true,
            progress: LessonProgressModel(
              status: isCompleted || progress >= 20 ? 'completed' : 'in_progress',
              progressPercentage: isCompleted || progress >= 20 ? 100 : 50,
            ),
          ),
          LessonModel(
            id: '${courseId}_les_1_3',
            sectionId: '${courseId}_sec_1',
            title: '1.3 Các nguyên tắc cốt lõi không thể bỏ qua',
            durationMinutes: 20,
            isPreview: false,
            isMandatory: true,
            progress: LessonProgressModel(
              status: isCompleted || progress >= 35 ? 'completed' : 'not_started',
              progressPercentage: isCompleted || progress >= 35 ? 100 : 0,
            ),
          ),
        ],
      ),
      SectionModel(
        id: '${courseId}_sec_2',
        courseId: courseId,
        title: 'Chương 2: Thực hành kỹ năng chuyên sâu',
        displayOrder: 2,
        totalLessons: 3,
        totalDurationMins: 70,
        lessons: [
          LessonModel(
            id: '${courseId}_les_2_1',
            sectionId: '${courseId}_sec_2',
            title: '2.1 Kỹ thuật thực hành căn bản và quy chuẩn',
            durationMinutes: 20,
            isPreview: false,
            isMandatory: true,
            progress: LessonProgressModel(
              status: isCompleted || progress >= 50 ? 'completed' : 'not_started',
              progressPercentage: isCompleted || progress >= 50 ? 100 : 0,
            ),
          ),
          LessonModel(
            id: '${courseId}_les_2_2',
            sectionId: '${courseId}_sec_2',
            title: '2.2 Xử lý các tình huống phức tạp thực tế',
            durationMinutes: 25,
            isPreview: false,
            isMandatory: true,
            progress: LessonProgressModel(
              status: isCompleted || progress >= 75 ? 'completed' : 'not_started',
              progressPercentage: isCompleted || progress >= 75 ? 100 : 0,
            ),
          ),
          LessonModel(
            id: '${courseId}_les_2_3',
            sectionId: '${courseId}_sec_2',
            title: '2.3 Đánh giá và tối ưu hiệu suất',
            durationMinutes: 25,
            isPreview: false,
            isMandatory: true,
            progress: LessonProgressModel(
              status: isCompleted || progress >= 90 ? 'completed' : 'not_started',
              progressPercentage: isCompleted || progress >= 90 ? 100 : 0,
            ),
          ),
        ],
      ),
      SectionModel(
        id: '${courseId}_sec_3',
        courseId: courseId,
        title: 'Chương 3: Đồ án tốt nghiệp & Tổng kết',
        displayOrder: 3,
        totalLessons: 2,
        totalDurationMins: 60,
        lessons: [
          LessonModel(
            id: '${courseId}_les_3_1',
            sectionId: '${courseId}_sec_3',
            title: '3.1 Hoàn thiện đồ án thực chiến',
            durationMinutes: 40,
            isPreview: false,
            isMandatory: true,
            progress: LessonProgressModel(
              status: isCompleted ? 'completed' : 'not_started',
              progressPercentage: isCompleted ? 100 : 0,
            ),
          ),
          LessonModel(
            id: '${courseId}_les_3_2',
            sectionId: '${courseId}_sec_3',
            title: '3.2 Tổng kết khóa học và cấp chứng chỉ',
            durationMinutes: 20,
            isPreview: false,
            isMandatory: true,
            progress: LessonProgressModel(
              status: isCompleted ? 'completed' : 'not_started',
              progressPercentage: isCompleted ? 100 : 0,
            ),
          ),
        ],
      ),
    ];
  }

  static const Map<String, _MockMeta> _mockCourseCatalog = {
    'course_1': _MockMeta(
      title: 'UI/UX Design Fundamentals',
      category: 'UI/UX Design',
      shortDescription: 'Khóa học nền tảng thiết kế UI/UX bài bản cho người mới bắt đầu.',
      description:
          'Khóa học trang bị cho bạn toàn bộ kiến thức nền tảng về tư duy thẩm mỹ, cấu trúc thông tin (Information Architecture), quy trình Wireframe, Prototyping và kiểm thử khả năng sử dụng (Usability Testing).',
      instructorName: 'Trần Minh Tâm',
      level: 'Cơ bản',
      price: 0,
      rating: 4.9,
      totalRatings: 342,
      studentCount: 1250,
      durationMins: 400,
      progress: 100.0,
      isEnrolled: true,
    ),
    'course_2': _MockMeta(
      title: 'Product Design Masterclass',
      category: 'Product Design',
      shortDescription: 'Chinh phục tư duy thiết kế sản phẩm số toàn diện và chuyên sâu.',
      description:
          'Khóa học hướng dẫn bạn từ khâu phân tích bài toán kinh doanh, thấu cảm người dùng đến thiết kế trải nghiệm sản phẩm số quy mô lớn và chuẩn hóa quy trình giao tiếp với đội ngũ kỹ sư.',
      instructorName: 'Trần Minh Tâm',
      level: 'Nâng cao',
      price: 0,
      rating: 4.8,
      totalRatings: 215,
      studentCount: 940,
      durationMins: 500,
      progress: 40.0,
      isEnrolled: true,
    ),
    'course_3': _MockMeta(
      title: 'Design Thinking for UX',
      category: 'UI/UX Design',
      shortDescription: 'Phương pháp luận tư duy đổi mới sáng tạo ứng dụng trong UX.',
      description:
          'Khám phá 5 bước tiêu chuẩn của Design Thinking: Empathize, Define, Ideate, Prototype, Test cùng các case study thực tế từ các tập đoàn công nghệ hàng đầu.',
      instructorName: 'Trần Minh Tâm',
      level: 'Thực chiến',
      price: 499000,
      discountPrice: 399000,
      rating: 4.7,
      totalRatings: 180,
      studentCount: 680,
      durationMins: 255,
      progress: 0.0,
      isEnrolled: false,
    ),
    'course_4': _MockMeta(
      title: 'User Research Methods',
      category: 'User Research',
      shortDescription: 'Phương pháp nghiên cứu định tính và định lượng hành vi người dùng.',
      description:
          'Nắm vững kỹ năng phỏng vấn sâu, khảo sát người dùng, phân tích dữ liệu hành vi và biến insight nghiên cứu thành các quyết định thiết kế sắc bén.',
      instructorName: 'Trần Minh Tâm',
      level: 'Chuyên sâu',
      price: 599000,
      rating: 4.8,
      totalRatings: 130,
      studentCount: 520,
      durationMins: 330,
      progress: 0.0,
      isEnrolled: false,
    ),
    'course_5': _MockMeta(
      title: 'Design System & Component Library',
      category: 'Product Design',
      shortDescription: 'Xây dựng và vận hành Design System quy mô lớn với Figma.',
      description:
          'Hướng dẫn xây dựng Tokens, Components, Auto Layout, Variables và tài liệu hướng dẫn sử dụng Design System đồng bộ giữa Designer và Developer.',
      instructorName: 'Trần Minh Tâm',
      level: 'Nâng cao',
      price: 699000,
      rating: 4.9,
      totalRatings: 195,
      studentCount: 810,
      durationMins: 430,
      progress: 0.0,
      isEnrolled: false,
    ),
  };

  static _MockMeta _defaultCourseMeta(String id) {
    return _MockMeta(
      title: 'Khóa học mẫu ($id)',
      category: 'Chuyên ngành',
      shortDescription: 'Nội dung khóa học mẫu phục vụ kiểm thử giao diện và trải nghiệm.',
      description:
          'Khóa học cung cấp kiến thức thực tiễn và bài tập thực hành hoàn chỉnh giúp người học nâng cao trình độ.',
      instructorName: 'Giảng viên hướng dẫn',
      level: 'Tiêu chuẩn',
      price: 0,
      rating: 4.9,
      totalRatings: 120,
      studentCount: 450,
      durationMins: 360,
      progress: 100.0,
      isEnrolled: true,
    );
  }
}

class _MockMeta {
  const _MockMeta({
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.instructorName,
    required this.level,
    required this.price,
    this.discountPrice,
    required this.rating,
    required this.totalRatings,
    required this.studentCount,
    required this.durationMins,
    required this.progress,
    required this.isEnrolled,
  });

  final String title;
  final String category;
  final String shortDescription;
  final String description;
  final String instructorName;
  final String level;
  final double price;
  final double? discountPrice;
  final double rating;
  final int totalRatings;
  final int studentCount;
  final int durationMins;
  final double progress;
  final bool isEnrolled;
}
