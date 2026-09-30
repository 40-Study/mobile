import 'dart:async';

import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_class_detail_model.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';
import 'package:study/features/parent/data/models/parent_learning_hub_data.dart';
import 'package:study/features/parent/data/models/parent_learning_insights_model.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';

class ParentLearningRepositoryImpl implements ParentLearningRepository {
  ParentLearningRepositoryImpl({
    this.enablePreviewFallback = true,
  });

  final bool enablePreviewFallback;

  static const String studentMinhId = 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732';
  static const String studentLanId = 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad';

  @override
  Future<List<FamilyScopeChild>> getChildren() async {
    // Giả lập độ trễ mạng nhẹ
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return [
      FamilyScopeChild.sample(
        id: studentMinhId,
        name: 'Minh',
        className: '10A1',
      ),
      FamilyScopeChild.sample(
        id: studentLanId,
        name: 'Lan',
        className: '7B',
      ),
    ];
  }

  @override
  Future<ParentLearningHubData?> getLearningHubData(String childId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final allData = _getSampleHubDataMap();
    return allData[childId] ?? allData[studentMinhId];
  }

  @override
  Future<Map<String, ParentLearningHubData>> getAllLearningHubData() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return _getSampleHubDataMap();
  }

  @override
  Future<ParentClassDetailModel?> getClassDetail(
    String classId, {
    String? childId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return const ParentClassDetailModel(
      classId: 'class-toan-10',
      className: 'Toán nâng cao 10',
      childName: 'Minh',
      childId: studentMinhId,
      semester: 'Lớp 10A1 — Học kỳ I (2024–2025)',
      teacherName: 'Cô Lan',
      teacherTitle: 'ThS. Toán học - THPT Hà Nội Amsterdam',
      teacherInitials: 'CL',
      scheduleFixed: 'T2 · T4 · T6 (09:00 - 10:00)',
      roomOrPlatform: 'Google Meet / Phòng 302',
      completedSessions: 8,
      totalSessions: 12,
      attendanceRatePercent: 100,
      averageGrade: 8.6,
      lessons: [
        ClassLessonItem(
          sessionNumber: 8,
          title: 'Buổi 8: Phân số cơ bản & Rút gọn',
          timeSubtitle: 'Hôm nay, 09:00',
          quizScoreText: '3/5',
          status: ClassLessonStatus.completedToday,
          statusLabel: 'Vừa hoàn thành',
          canViewLesson: true,
        ),
        ClassLessonItem(
          sessionNumber: 7,
          title: 'Buổi 7: Số thập phân & Định lý Vi-ét',
          timeSubtitle: 'Hôm qua',
          quizScoreText: '5/5',
          hasVideoRecording: true,
          status: ClassLessonStatus.completed,
          statusLabel: 'Đã học',
          canViewLesson: true,
        ),
        ClassLessonItem(
          sessionNumber: 6,
          title: 'Buổi 6: Phương trình bậc hai',
          timeSubtitle: 'Tuần trước',
          noteText: 'Hoàn thành bài tập về nhà',
          status: ClassLessonStatus.completed,
          statusLabel: 'Đã học',
          canViewLesson: true,
        ),
        ClassLessonItem(
          sessionNumber: 9,
          title: 'Buổi 9: Hệ phương trình bậc nhất hai ẩn',
          timeSubtitle: 'Thứ 2 tuần tới, 09:00',
          status: ClassLessonStatus.upcoming,
          statusLabel: 'Sắp diễn ra',
          canViewLesson: false,
        ),
      ],
    );
  }

  @override
  Future<ParentLearningInsightsModel?> getLearningInsights(
      String childId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final map = _getSampleInsightsMap();
    return map[childId] ?? map[studentMinhId];
  }

  Map<String, ParentLearningInsightsModel> _getSampleInsightsMap() {
    return {
      studentMinhId: const ParentLearningInsightsModel(
        childId: studentMinhId,
        childName: 'Nguyễn Nhật Minh',
        childInitials: 'M',
        className: '10A1',
        semester: 'Lớp 10A1 · Học kỳ I 2024–2025',
        updateStatus: 'Đang cập nhật tuần 12',
        overviewTitle: 'Tổng quan kỳ I (12 tuần)',
        weekBadge: 'Tuần 12',
        attendanceRatePercent: 92,
        attendanceDeltaText: '+4% (23/25 buổi)',
        homeworkCompletionPercent: 85,
        homeworkDeltaText: 'Đúng hạn (17/20)',
        averageGrade: 8.6,
        gradeDeltaText: '+0.8 với đầu kỳ',
        focusAndInteractionPercent: 88,
        focusAndInteractionStatus: 'Rất tích cực',
        focusTrendAverageDelta: '+12% trung bình',
        focusTrendPoints: [
          FocusTrendDataPoint(week: 1, score: 72, label: 'T1'),
          FocusTrendDataPoint(week: 2, score: 76, label: 'T2'),
          FocusTrendDataPoint(week: 3, score: 74, label: 'T3'),
          FocusTrendDataPoint(week: 4, score: 80, label: 'T4'),
          FocusTrendDataPoint(week: 5, score: 83, label: 'T5'),
          FocusTrendDataPoint(week: 6, score: 81, label: 'T6'),
          FocusTrendDataPoint(week: 7, score: 86, label: 'T7'),
          FocusTrendDataPoint(week: 8, score: 84, label: 'T8'),
          FocusTrendDataPoint(week: 9, score: 89, label: 'T9'),
          FocusTrendDataPoint(week: 10, score: 87, label: 'T10'),
          FocusTrendDataPoint(week: 11, score: 92, label: 'T11'),
          FocusTrendDataPoint(week: 12, score: 88, label: 'T12'),
        ],
        focusTrendNote:
            'Minh duy trì độ tập trung trên 85% vào các buổi cuối tuần '
            '(T6–CN), tương tác đều đặn trong các phần thảo luận và bài tập '
            'nhóm.',
        improvementFocusBadge: '1 trọng tâm',
        observationContent:
            'Minh hoàn thành 3/5 bài dạng phân số & rút gọn biểu thức trong 2 '
            'buổi gần nhất (tỷ lệ đúng 60%).',
        interpretationContent:
            'Thấp hơn mức trung bình đại số của Minh (85%+). Em thường vấp lỗi '
            'nhầm dấu khi quy đồng đa thức phức tạp.',
        actionContent:
            'Nhắc Minh xem lại bài giảng Buổi 8; kết nối trực tiếp với Cô Lan '
            '(GV Toán) để nhận 3 bài tập củng cố cá nhân hoá.',
        evidenceActionText:
            'Xem bài tập và bài kiểm tra chi tiết (Evidence) →',
        strengthBadge: 'Phát huy tốt',
        strengthTitle: 'Tư duy không gian & Ứng dụng thực tế',
        strengthContent:
            'Phản xạ xuất sắc ở đồ thị hàm số và bài toán liên môn (đạt 95% '
            'điểm tuyệt đối trong đợt kiểm tra 15 phút vừa qua).',
        teacherName: 'Cô Lan',
        teacherSubject: 'GV Toán',
      ),
      studentLanId: const ParentLearningInsightsModel(
        childId: studentLanId,
        childName: 'Nguyễn Mai Lan',
        childInitials: 'L',
        className: '7B',
        semester: 'Lớp 7B · Học kỳ I 2024–2025',
        updateStatus: 'Đang cập nhật tuần 12',
        overviewTitle: 'Tổng quan kỳ I (12 tuần)',
        weekBadge: 'Tuần 12',
        attendanceRatePercent: 96,
        attendanceDeltaText: '+2% (24/25 buổi)',
        homeworkCompletionPercent: 90,
        homeworkDeltaText: 'Đúng hạn (19/20)',
        averageGrade: 8.9,
        gradeDeltaText: '+0.5 với đầu kỳ',
        focusAndInteractionPercent: 92,
        focusAndInteractionStatus: 'Xuất sắc',
        focusTrendAverageDelta: '+8% trung bình',
        focusTrendPoints: [
          FocusTrendDataPoint(week: 1, score: 80, label: 'T1'),
          FocusTrendDataPoint(week: 2, score: 82, label: 'T2'),
          FocusTrendDataPoint(week: 3, score: 85, label: 'T3'),
          FocusTrendDataPoint(week: 4, score: 87, label: 'T4'),
          FocusTrendDataPoint(week: 5, score: 86, label: 'T5'),
          FocusTrendDataPoint(week: 6, score: 89, label: 'T6'),
          FocusTrendDataPoint(week: 7, score: 91, label: 'T7'),
          FocusTrendDataPoint(week: 8, score: 90, label: 'T8'),
          FocusTrendDataPoint(week: 9, score: 93, label: 'T9'),
          FocusTrendDataPoint(week: 10, score: 92, label: 'T10'),
          FocusTrendDataPoint(week: 11, score: 95, label: 'T11'),
          FocusTrendDataPoint(week: 12, score: 92, label: 'T12'),
        ],
        focusTrendNote:
            'Lan duy trì độ tập trung ổn định và phát biểu đóng góp tích cực '
            'trong giờ Ngữ văn và Tiếng Anh.',
        improvementFocusBadge: '1 trọng tâm',
        observationContent:
            'Lan cần chú ý thêm ở phần lập luận phản biện trong bài viết luận '
            'văn học kỳ này.',
        interpretationContent:
            'Em diễn đạt lưu loát nhưng đôi lúc thiếu dẫn chứng định lượng để '
            'bảo vệ luận điểm.',
        actionContent:
            'Khuyến khích Lan đọc thêm tài liệu mở rộng và thảo luận cùng giáo '
            'viên hướng dẫn.',
        evidenceActionText:
            'Xem bài tập và bài kiểm tra chi tiết (Evidence) →',
        strengthBadge: 'Phát huy tốt',
        strengthTitle: 'Cảm thụ ngôn ngữ & Diễn đạt',
        strengthContent:
            'Khả năng hành văn mượt mà, giàu cảm xúc, đạt 9.5 điểm bài kiểm '
            'tra định kỳ.',
        teacherName: 'Thầy Hưng',
        teacherSubject: 'GV Ngữ văn',
      ),
    };
  }

  @override
  Future<List<ParentRecommendedCourseItem>> getRecommendedCourses(
    String childId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return const [
      ParentRecommendedCourseItem(
        id: 'course-algebra-10',
        title: 'Algebra & Hàm số cơ bản đến nâng cao',
        reasonDescription:
            'Phù hợp vì Minh đã hoàn thành Đại số căn bản và cần bổ trợ tư '
            'duy phương trình bậc hai & định lý Vi-ét nâng cao.',
        tagLabel: '★ Gợi ý cho Minh · Bổ trợ phương trình',
        tagTextColor: Color(0xFF2563EB),
        tagBgColor: Color(0xFFEFF6FF),
        matchPercent: 98,
        sessionInfo: '8 buổi · T3 & T5 (15:00)',
        teacherName: 'ThS. Hoàng Minh Tuấn',
        tuitionFee: 1600000,
        originalFee: 2200000,
        categoryFilter: 'toan',
        isPersonalized: true,
      ),
      ParentRecommendedCourseItem(
        id: 'course-ielts-junior',
        title: 'Tiếng Anh giao tiếp & IELTS Junior Foundation',
        reasonDescription:
            'Được nhiều phụ huynh và học sinh lựa chọn chuẩn bị nền tảng IELTS '
            'và tăng cường phản xạ thuyết trình tự tin.',
        tagLabel: '🔥 Phổ biến cho học sinh Lớp 10',
        tagTextColor: Color(0xFFEA580C),
        tagBgColor: Color(0xFFFFF7ED),
        matchPercent: 92,
        sessionInfo: '10 buổi · T4 & T7 (18:00)',
        teacherName: 'Thầy David Nam (IELTS 8.5)',
        tuitionFee: 2200000,
        originalFee: 2800000,
        categoryFilter: 'tieng_anh',
        isPersonalized: false,
      ),
      ParentRecommendedCourseItem(
        id: 'course-hinh-hoc-10',
        title: 'Hình học không gian & Ứng dụng thực tế',
        reasonDescription:
            'Phát huy điểm mạnh tư duy trực quan không gian của Minh đã thể '
            'hiện rất xuất sắc trong kỳ kiểm tra giữa kỳ (9.5/10).',
        tagLabel: '⚡ Bổ trợ thế mạnh tư duy không gian',
        tagTextColor: Color(0xFF0D9488),
        tagBgColor: Color(0xFFF0FDFA),
        matchPercent: 88,
        sessionInfo: '6 buổi · Thứ 7 (09:00 – 11:00)',
        teacherName: 'Cô Nguyễn Phương Thảo',
        tuitionFee: 1200000,
        originalFee: 1500000,
        categoryFilter: 'toan',
        isPersonalized: true,
      ),
    ];
  }

  @override
  Future<ParentRecommendedCourseDetailModel?> getRecommendedCourseDetail(
    String courseId, {
    String? childId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return const ParentRecommendedCourseDetailModel(
      courseId: 'course-algebra-10',
      courseName: 'Algebra & Đại số nâng cao',
      subtitle: 'Chuyên đề Vi-ét, Biến đổi đa thức & Phân số thức mở rộng',
      childName: 'Minh',
      subjectTag: 'TOÁN HỌC NÂNG CAO',
      personalizedTag: 'Gợi ý riêng cho Minh',
      rating: 4.9,
      reviewCount: 128,
      studentCount: 340,
      whyRecommendedReason:
          'Khóa học này tập trung vào dạng bài mà Minh đang có tỷ lệ làm '
          'đúng 60% ở 2 buổi học gần nhất. Giúp củng cố phương pháp giải và '
          'tăng tốc độ làm bài thi.',
      tuitionFee: 1600000,
      originalFee: 2200000,
      discountLabel: 'Tiết kiệm 27%',
      feeSupportText:
          'Hỗ trợ chia kỳ đóng phí linh hoạt · Hoàn 100% nếu không hài lòng',
      targetGrade: 'Lớp 10 (Nâng cao & Chuyên Toán)',
      durationText: '8 buổi (90 phút/buổi)',
      scheduleFixed: 'Thứ 3 & Thứ 5 · 15:00 - 16:30',
      formatText: 'Online trực tiếp tương tác (Sĩ số ≤ 12 HS)',
      materialsText: 'Tập sách bản cứng + Trợ giảng 1-1',
      teacherName: 'ThS. Hoàng Minh Tuấn',
      isTeacherVerified: true,
      syllabusModules: [
        CourseSyllabusModule(
          order: 1,
          title: 'Ôn tập & Rút gọn mẫu thức phân số phức hợp',
          description:
              'Phân tích đa thức thành nhân tử, quy đồng và khử căn bậc 2 '
              'phức tạp.',
          sessionCountLabel: '2 buổi',
        ),
        CourseSyllabusModule(
          order: 2,
          title: 'Ứng dụng định lý Vi-ét cho phương trình bậc cao',
          description:
              'Kỹ thuật giải hệ đối xứng loại 1, loại 2 và phân tích nghiệm '
              'nguyên.',
          sessionCountLabel: '2 buổi',
        ),
        CourseSyllabusModule(
          order: 3,
          title: 'Bất đẳng thức Cauchy & Schwarz ứng dụng',
          description:
              'Kỹ thuật chọn điểm rơi, dồn biến và cân bằng hệ số trong đề '
              'thi HSG.',
          sessionCountLabel: '2 buổi',
        ),
        CourseSyllabusModule(
          order: 4,
          title: 'Kiểm tra sát hạch & Báo cáo phân tích năng lực',
          description:
              'Làm bài thi thử chuẩn cấu trúc và gửi hồ sơ đánh giá chi tiết '
              'cho phụ huynh.',
          sessionCountLabel: '2 buổi',
        ),
      ],
      guaranteeNote:
          'Đảm bảo quyền lợi hoàn 100% học phí nếu phụ huynh và con cảm thấy '
          'không phù hợp sau 2 buổi đầu.',
    );
  }

  Map<String, ParentLearningHubData> _getSampleHubDataMap() {
    return {
      // Dữ liệu cho Minh (Đúng chuẩn theo Ảnh 1)
      studentMinhId: const ParentLearningHubData(
        childId: studentMinhId,
        childName: 'Minh',
        className: '10A1',
        newInsightsCount: 2,
        activeClassCount: 3,
        activeClassNames: ['Toán nâng cao', 'Tiếng Anh', 'Vật Lý'],
        pendingHomeworkCount: 2,
        overdueHomeworkCount: 1,
        courseProgressPercent: 0.68,
        recommendedTopic: 'Chuyên đề bổ trợ hình học không gian',
      ),

      // Dữ liệu cho Lan
      studentLanId: const ParentLearningHubData(
        childId: studentLanId,
        childName: 'Lan',
        className: '7B',
        newInsightsCount: 1,
        activeClassCount: 2,
        activeClassNames: ['Ngữ văn chuyên sâu', 'Tiếng Anh cơ bản'],
        pendingHomeworkCount: 1,
        overdueHomeworkCount: 0,
        courseProgressPercent: 0.45,
        recommendedTopic: 'Lộ trình bổ trợ phương pháp viết luận',
      ),
    };
  }
}

