import 'dart:async';

import 'package:flutter/material.dart';
import 'package:study/core/logger/app_logger.dart';
import 'package:study/features/auth/data/models/user_model.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_class_detail_model.dart';
import 'package:study/features/parent/data/models/parent_course_progress_model.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';
import 'package:study/features/parent/data/models/parent_learning_hub_data.dart';
import 'package:study/features/parent/data/models/parent_learning_insights_model.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';

class ParentLearningRepositoryImpl implements ParentLearningRepository {
  ParentLearningRepositoryImpl({
    ParentHomeApiClient? apiClient,
    this.enablePreviewFallback = true,
  }) : _apiClient = apiClient;

  final ParentHomeApiClient? _apiClient;
  final bool enablePreviewFallback;

  static const String studentTungId = '31843f49-fd61-47aa-af78-d1badbdcce52';
  static const String studentMinhId = 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732';
  static const String studentLanId = 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad';

  bool _isMockChild(String? childId) =>
      childId == studentMinhId || childId == studentLanId;

  @override
  Future<List<FamilyScopeChild>> getChildren() async {
    // 1. Tải danh sách con thật từ backend API
    var realChildren = <FamilyScopeChild>[];
    try {
      realChildren = await _fetchRealChildren();
    } catch (e, stackTrace) {
      if (!enablePreviewFallback) {
        rethrow;
      }
      AppLogger.w(
        'ParentLearning: fetch real children failed, fallback to mock',
        e,
      );
      AppLogger.d('ParentLearning children stackTrace', stackTrace);
    }

    // 2. Nếu bật fallback, gộp với con mẫu Minh & Lan
    // giống như trang Home và Lịch
    if (enablePreviewFallback) {
      return _mergeWithMockChildren(realChildren);
    }
    return realChildren;
  }

  Future<List<FamilyScopeChild>> _fetchRealChildren() async {
    final api = _apiClient;
    if (api == null) return [];
    try {
      final response = await api.getChildren().timeout(
            const Duration(seconds: 10),
          );
      final data = _extractData(response.data);
      final list = _extractList(data, keys: ['children', 'items']);
      return list
          .asMap()
          .entries
          .map(
            (e) => FamilyScopeChild.fromUserModel(
              UserModel.fromJson(e.value as Map<String, dynamic>),
              index: e.key,
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      AppLogger.w('ParentLearning: fetch real children failed', e);
      AppLogger.d('ParentLearning children stackTrace', stackTrace);
      rethrow;
    }
  }

  List<FamilyScopeChild> _mergeWithMockChildren(List<FamilyScopeChild> real) {
    final list = <FamilyScopeChild>[];

    // 1. Luôn giữ nguyên tài khoản con thật ở đầu danh sách
    if (real.isNotEmpty) {
      list.addAll(real);
    } else {
      list.add(
        FamilyScopeChild.sample(
          id: studentTungId,
          name: 'Mai Hoàng Tùng',
          className: '12A',
        ),
      );
    }

    // 2. Bổ sung Minh & Lan vào danh sách để trải nghiệm đầy đủ Family Scope
    if (!list.any((c) => c.id == studentMinhId)) {
      list.add(
        const FamilyScopeChild(
          id: studentMinhId,
          name: 'Minh',
          className: '10A1',
          initialLetter: 'M',
          badgeColor: Color(0xFFDBEAFE),
        ),
      );
    }
    if (!list.any((c) => c.id == studentLanId)) {
      list.add(
        const FamilyScopeChild(
          id: studentLanId,
          name: 'Lan',
          className: '7B',
          initialLetter: 'L',
          badgeColor: Color(0xFFFCE7F3),
        ),
      );
    }

    return list;
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  List<dynamic> _extractList(dynamic data, {List<String> keys = const []}) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        if (data[key] is List) return data[key] as List<dynamic>;
      }
      if (data['items'] is List) return data['items'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<ParentLearningHubData?> getLearningHubData(String childId) async {
    final allData = await getAllLearningHubData();
    return allData[childId];
  }

  @override
  Future<Map<String, ParentLearningHubData>> getAllLearningHubData() async {
    final sampleMap = _getSampleHubDataMap();
    final children = await getChildren();
    final result = Map<String, ParentLearningHubData>.from(sampleMap);

    for (final child in children) {
      if (_isMockChild(child.id)) {
        continue;
      }

      // Với học sinh thật: thử lấy dữ liệu từ API overview / assignments
      ParentLearningHubData? realHubData;
      final api = _apiClient;
      if (api != null) {
        try {
          final response = await api.getOverview(child.id).timeout(
                const Duration(seconds: 5),
              );
          final data = _extractData(response.data);
          if (data is Map<String, dynamic>) {
            final enrolledCourses =
                (data['enrolled_courses'] as num?)?.toInt() ?? 0;
            final completedCourses =
                (data['completed_courses'] as num?)?.toInt() ?? 0;
            final progress = enrolledCourses > 0
                ? (completedCourses / enrolledCourses).clamp(0.0, 1.0)
                : 0.0;

            var pendingHw = 0;
            var overdueHw = 0;
            try {
              final hwRes = await api.getAssignments(child.id).timeout(
                    const Duration(seconds: 5),
                  );
              final hwData = _extractData(hwRes.data);
              if (hwData is Map<String, dynamic> &&
                  hwData['stats'] is Map<String, dynamic>) {
                final stats = hwData['stats'] as Map<String, dynamic>;
                final inProgress =
                    (stats['in_progress'] as num?)?.toInt() ?? 0;
                final notStarted =
                    (stats['not_started'] as num?)?.toInt() ?? 0;
                pendingHw = inProgress + notStarted;
                overdueHw = (stats['overdue'] as num?)?.toInt() ?? 0;
              }
            } catch (_) {
              // Bỏ qua lỗi bài tập
            }

            realHubData = ParentLearningHubData(
              childId: child.id,
              childName: child.name,
              className: child.className,
              newInsightsCount: 0,
              activeClassCount: enrolledCourses,
              activeClassNames: const [],
              pendingHomeworkCount: pendingHw,
              overdueHomeworkCount: overdueHw,
              courseProgressPercent: progress,
              recommendedTopic: null,
            );
          }
        } catch (e) {
          AppLogger.d(
            'ParentLearning: fetch overview for child ${child.id} failed, '
            'using empty data: $e',
          );
        }
      }

      // Trả về Empty Data cho con thật nếu không có dữ liệu thật
      result[child.id] = realHubData ??
          ParentLearningHubData(
            childId: child.id,
            childName: child.name,
            className: child.className,
            newInsightsCount: 0,
            activeClassCount: 0,
            activeClassNames: const [],
            pendingHomeworkCount: 0,
            overdueHomeworkCount: 0,
            courseProgressPercent: 0.0,
            recommendedTopic: null,
          );
    }

    return result;
  }

  @override
  Future<ParentClassDetailModel?> getClassDetail(
    String classId, {
    String? childId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Với con thật chưa có dữ liệu lớp học: trả về null để hiển thị Empty UI
    if (childId != null && !_isMockChild(childId)) {
      return null;
    }

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
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (!_isMockChild(childId)) {
      return null;
    }

    final map = _getSampleInsightsMap();
    return map[childId];
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
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (!_isMockChild(childId)) {
      return const [];
    }

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

  @override
  Future<List<ParentHomeworkItem>> getHomeworkList(String childId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Mock theo Ảnh 0 & 1 cho Lan
    if (childId == studentLanId) {
      return const [
        ParentHomeworkItem(
          id: 'hw-lan-van-1',
          title: 'Soạn bài: Luyện tập viết đoạn văn nghị luận',
          subjectCode: '文',
          subjectName: 'NGỮ VĂN 7B',
          teacherName: 'Thầy Hưng',
          dueTagLabel: 'HẠN NGÀY MAI',
          dueTagTextColor: Color(0xFFD97706),
          dueTagBgColor: Color(0xFFFEF3C7),
          timeRemainingText: 'Còn 1 ngày',
          status: ParentHomeworkStatus.inProgress,
        ),
      ];
    }

    // Mock theo Ảnh 0 & 1 cho Minh
    if (childId == studentMinhId) {
      return const [
        ParentHomeworkItem(
          id: 'hw-minh-toan-1',
          title: 'Bài tập 1: Phân số cơ bản & Rút gọn',
          subjectCode: 'Σ',
          subjectName: 'TOÁN NÂNG CAO 10',
          teacherName: 'Cô Lan',
          dueTagLabel: 'CẦN NỘP HÔM NAY',
          dueTagTextColor: Color(0xFFDC2626),
          dueTagBgColor: Color(0xFFFEE2E2),
          timeRemainingText: 'Còn 6 giờ',
          status: ParentHomeworkStatus.urgent,
          isUrgent: true,
        ),
        ParentHomeworkItem(
          id: 'hw-minh-anh-1',
          title: 'Unit 4 Reading: Climate Change & Summary',
          subjectCode: 'En',
          subjectName: 'TIẾNG ANH 10',
          teacherName: 'Thầy David Nam',
          dueTagLabel: 'HẠN NGÀY MAI',
          dueTagTextColor: Color(0xFFD97706),
          dueTagBgColor: Color(0xFFFEF3C7),
          timeRemainingText: 'Còn 1 ngày',
          status: ParentHomeworkStatus.inProgress,
        ),
        ParentHomeworkItem(
          id: 'hw-minh-ly-1',
          title: 'Báo cáo thực hành: Đo gia tốc rơi tự do',
          subjectCode: 'Sc',
          subjectName: 'VẬT LÝ 10',
          teacherName: 'Thầy Hưng',
          dueTagLabel: 'HẠN THỨ 6',
          dueTagTextColor: Color(0xFF2563EB),
          dueTagBgColor: Color(0xFFEFF6FF),
          timeRemainingText: 'Còn 3 ngày',
          status: ParentHomeworkStatus.inProgress,
        ),
      ];
    }

    // Với con thật: Thử gọi API backend assignments
    final api = _apiClient;
    if (api != null) {
      try {
        final res = await api.getAssignments(childId).timeout(
              const Duration(seconds: 5),
            );
        final data = _extractData(res.data);
        final rawAssignments =
            _extractList(data, keys: ['assignments', 'items']);
        if (rawAssignments.isNotEmpty) {
          return rawAssignments.map((raw) {
            final item = raw as Map<String, dynamic>;
            final id = item['id']?.toString() ?? '';
            final title = item['title']?.toString() ?? 'Bài tập';
            final className = item['class_name']?.toString() ?? 'Lớp học';
            final statusStr = item['status']?.toString() ?? 'not_started';
            final isOverdue = statusStr == 'overdue';

            ParentHomeworkStatus status;
            if (isOverdue) {
              status = ParentHomeworkStatus.overdue;
            } else if (statusStr == 'completed') {
              status = ParentHomeworkStatus.graded;
            } else if (statusStr == 'in_progress') {
              status = ParentHomeworkStatus.inProgress;
            } else {
              status = ParentHomeworkStatus.urgent;
            }

            return ParentHomeworkItem(
              id: id,
              title: title,
              subjectCode: className.isNotEmpty ? className[0] : 'Bài',
              subjectName: className.toUpperCase(),
              teacherName: 'Giáo viên bộ môn',
              dueTagLabel: isOverdue ? 'ĐÃ QUÁ HẠN' : 'CẦN HOÀN THÀNH',
              dueTagTextColor: isOverdue
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFD97706),
              dueTagBgColor: isOverdue
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFFEF3C7),
              timeRemainingText: isOverdue ? 'Quá hạn' : 'Sắp đến hạn',
              status: status,
              isUrgent: isOverdue || status == ParentHomeworkStatus.urgent,
            );
          }).toList();
        }
      } catch (e) {
        AppLogger.d(
          'ParentLearning: fetch assignments for child $childId failed: $e',
        );
      }
    }

    // Không có bài tập thật -> trả về rỗng để hiển thị Empty UI
    return const [];
  }

  @override
  Future<ParentHomeworkDetailModel?> getHomeworkDetail(
    String homeworkId, {
    String? childId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (homeworkId == 'hw-minh-toan-1') {
      return const ParentHomeworkDetailModel(
        id: 'hw-minh-toan-1',
        title: 'Bài tập 1: Phân số cơ bản & Rút gọn',
        subjectName: 'Toán nâng cao 10',
        teacherName: 'Cô Lan (ThS. Toán học)',
        dueDateText: '23:59 Hôm nay (Thứ 4, 02/10)',
        timeRemainingText: 'Còn khoảng 6 giờ để nộp',
        status: ParentHomeworkStatus.urgent,
        statusLabel: 'Cần nộp gấp hôm nay',
        description:
            'Hoàn thành các bài tập từ Bài 1 đến Bài 5 trong phiếu học '
            'tập số 8. Chú ý trình bày rõ các bước quy đồng mẫu số và '
            'điều kiện xác định của phân thức đại số trước khi rút gọn.',
        attachments: [
          'Phieu_bai_tap_so_8_Phan_so_Rut_gon.pdf',
          'Huong_dan_trinh_bay_mau.pdf',
        ],
        studentSubmissionNote: null,
        submittedFiles: [],
        submittedAtText: null,
      );
    }

    if (homeworkId == 'hw-minh-anh-1') {
      return const ParentHomeworkDetailModel(
        id: 'hw-minh-anh-1',
        title: 'Unit 4 Reading: Climate Change & Summary',
        subjectName: 'Tiếng Anh 10',
        teacherName: 'Thầy David Nam',
        dueDateText: '20:00 Ngày mai (Thứ 5, 03/10)',
        timeRemainingText: 'Còn 1 ngày',
        status: ParentHomeworkStatus.inProgress,
        statusLabel: 'Đang làm',
        description:
            'Đọc bài đọc trang 45 sách học viên và viết tóm tắt khoảng 120 từ '
            'về các giải pháp giảm phát thải rác thải nhựa trong trường học.',
        attachments: [
          'Unit4_Reading_Materials.pdf',
        ],
      );
    }

    if (homeworkId.startsWith('recent-math')) {
      return const ParentHomeworkDetailModel(
        id: 'recent-math-1',
        title: 'Bài tập tuần 11: Phương trình bậc hai & Vi-ét',
        subjectName: 'Toán nâng cao 10',
        teacherName: 'Cô Lan',
        dueDateText: '23:59 Thứ 6, 27/09',
        timeRemainingText: 'Đã hoàn thành',
        status: ParentHomeworkStatus.graded,
        statusLabel: 'Đã chấm điểm',
        description:
            'Áp dụng định lý Vi-ét để giải các hệ thức đối xứng và '
            'tìm giá trị tham số m.',
        attachments: ['De_kiem_tra_15p_Viet.pdf'],
        studentSubmissionNote:
            'Em đã giải đầy đủ cả 4 câu và vẽ kèm bảng biến thiên minh họa ạ.',
        submittedFiles: ['Bai_lam_Nguyen_Nhat_Minh.pdf'],
        submittedAtText: '19:42 Thứ 6, 27/09/2024',
        teacherFeedback:
            'Minh làm bài rất cẩn thận, lập luận chặt chẽ và chọn '
            'nghiệm chính xác. Tiếp tục phát huy nhé!',
        score: 9.5,
        maxScore: 10.0,
      );
    }

    // Default fallback
    return const ParentHomeworkDetailModel(
      id: 'hw-generic',
      title: 'Báo cáo thực hành: Đo gia tốc rơi tự do',
      subjectName: 'Vật lý 10',
      teacherName: 'Thầy Hưng',
      dueDateText: '23:59 Thứ 6 tuần này',
      timeRemainingText: 'Còn 3 ngày',
      status: ParentHomeworkStatus.inProgress,
      statusLabel: 'Đang làm',
      description:
          'Xử lý số liệu từ thí nghiệm đồng hồ đo thời gian hiện số '
          'và vẽ đồ thị v theo t.',
      attachments: ['Mau_bao_cao_thuc_hanh.docx'],
    );
  }

  @override
  Future<ParentGradedSummaryModel?> getGradedSummary(String childId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Khối kết quả tuần gần nhất mock cho Minh theo đúng Ảnh 4 & 5
    if (childId == studentMinhId) {
      return const ParentGradedSummaryModel(
        submissionRatio: '3/3 bài nộp',
        assessmentLabel: 'Tất cả đều đạt loại Giỏi',
        ratingBadge: 'Xuất sắc',
        averageScore: 8.8,
        maxScore: 10.0,
        recentGradedItems: [
          RecentGradedItem(
            id: 'recent-math-1',
            title: 'Toán nâng cao',
            gradedDateText: 'Thứ 6, 27/09',
            score: 9.5,
            iconData: Icons.functions,
            iconColor: Color(0xFF2563EB),
            iconBgColor: Color(0xFFEFF6FF),
          ),
          RecentGradedItem(
            id: 'recent-literature-1',
            title: 'Ngữ văn',
            gradedDateText: 'Thứ 4, 25/09',
            score: 8.5,
            iconData: Icons.menu_book,
            iconColor: Color(0xFF9333EA),
            iconBgColor: Color(0xFFFAF5FF),
          ),
          RecentGradedItem(
            id: 'recent-english-1',
            title: 'Tiếng Anh',
            gradedDateText: 'Thứ 2, 23/09',
            score: 8.5,
            iconData: Icons.language,
            iconColor: Color(0xFF0D9488),
            iconBgColor: Color(0xFFF0FDFA),
          ),
        ],
      );
    }

    // Lan và con thật không có graded summary tuần này -> trả về null
    return null;
  }

  @override
  Future<ParentProgressScreenData?> getProgressOverview(String childId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Mock chuẩn xác theo Ảnh 2 & 3 cho Lan
    if (childId == studentLanId) {
      return const ParentProgressScreenData(
        overview: ParentProgressOverviewModel(
          activeCourseCount: 2,
          studyingCourseCount: 2,
          completedCourseCount: 0,
          averageProgressPercent: 0.45,
          progressStatusText: 'Tiến độ học tập ổn định',
        ),
        courses: [
          ParentCourseProgressItem(
            courseId: 'course-lan-van-7',
            courseName: 'Ngữ văn 7 nâng cao',
            subjectCode: '文',
            subjectColor: Color(0xFF9333EA),
            subjectBgColor: Color(0xFFFAF5FF),
            teacherName: 'Thầy Hưng',
            locationText: 'Phòng 204',
            statusLabel: 'Đang học',
            statusTextColor: Color(0xFF2563EB),
            statusBgColor: Color(0xFFEFF6FF),
            completedSessions: 5,
            totalSessions: 10,
            progressPercent: 0.50,
            progressColor: Color(0xFF9333EA),
            remainingSessionsText: 'Còn 5 buổi',
            progressNote: 'Đang học đúng lộ trình chuyên đề văn học',
          ),
        ],
        homeroomNote: TeacherHomeroomNote(
          title: 'Ghi chú từ Giáo viên chủ nhiệm (Cô Lan Hương)',
          content:
              'Lan có tinh thần tự giác rất cao. Em luôn chủ động chuẩn bị '
              'bài trước khi đến lớp và tích cực hỗ trợ bạn bè trong các '
              'hoạt động nhóm.',
        ),
      );
    }

    // Minh: đúng theo thiết kế 3 thẻ
    if (childId == studentMinhId) {
      return const ParentProgressScreenData(
        overview: ParentProgressOverviewModel(
          activeCourseCount: 3,
          studyingCourseCount: 2,
          completedCourseCount: 1,
          averageProgressPercent: 0.65,
          progressStatusText: 'Đúng lộ trình đề ra',
        ),
        courses: [
          // Thẻ 1: Toán nâng cao (Ảnh 2)
          ParentCourseProgressItem(
            courseId: 'class-toan-10',
            courseName: 'Toán nâng cao 10',
            subjectCode: 'Σ',
            subjectColor: Color(0xFF2563EB),
            subjectBgColor: Color(0xFFEFF6FF),
            teacherName: 'Cô Lan',
            locationText: 'Phòng 302',
            statusLabel: 'Đang học',
            statusTextColor: Color(0xFF2563EB),
            statusBgColor: Color(0xFFEFF6FF),
            completedSessions: 8,
            totalSessions: 12,
            progressPercent: 0.67,
            progressColor: Color(0xFF2563EB),
            remainingSessionsText: 'Còn 4 buổi',
            progressNote: 'Đúng tiến độ · Buổi tiếp theo thứ 2 (18:00)',
          ),
          // Thẻ 2: Tiếng Anh IELTS (Ảnh 2)
          ParentCourseProgressItem(
            courseId: 'course-ielts-junior',
            courseName: 'Tiếng Anh IELTS Junior',
            subjectCode: '文A',
            subjectColor: Color(0xFFEA580C),
            subjectBgColor: Color(0xFFFFF7ED),
            teacherName: 'Thầy David Nam',
            locationText: 'Trực tuyến Zoom',
            statusLabel: 'Đang học',
            statusTextColor: Color(0xFF2563EB),
            statusBgColor: Color(0xFFEFF6FF),
            completedSessions: 5,
            totalSessions: 10,
            progressPercent: 0.50,
            progressColor: Color(0xFFEA580C),
            remainingSessionsText: 'Còn 5 buổi',
            warningNote: 'Cần chú ý bài tập viết luận',
          ),
          // Thẻ 3: STEM Robotics (Ảnh 3)
          ParentCourseProgressItem(
            courseId: 'course-stem-robotics',
            courseName: 'STEM Robotics cơ bản',
            subjectCode: 'STEM',
            subjectColor: Color(0xFF0D9488),
            subjectBgColor: Color(0xFFF0FDFA),
            teacherName: 'Thầy Hoàng Minh',
            locationText: 'Lab STEM A2',
            statusLabel: 'Xong',
            statusTextColor: Color(0xFF0D9488),
            statusBgColor: Color(0xFFF0FDFA),
            completedSessions: 12,
            totalSessions: 12,
            progressPercent: 1.0,
            progressColor: Color(0xFF0D9488),
            remainingSessionsText: 'Đã hoàn thành',
            isCompleted: true,
            certificateText: 'Đã hoàn thành · Đạt chứng nhận Xuất sắc',
          ),
        ],
        homeroomNote: TeacherHomeroomNote(
          title: 'Ghi chú từ Giáo viên chủ nhiệm (Cô Mai Linh)',
          content:
              'Minh duy trì thái độ học tập rất nghiêm túc và có nhiều '
              'tiến bộ ở các môn tự nhiên. Cần tiếp tục duy trì đà học tập '
              'môn Tiếng Anh và hoàn thành bài viết luận đúng hạn để đạt '
              'kết quả tốt nhất.',
        ),
      );
    }

    // Với con thật: Thử gọi API backend
    final api = _apiClient;
    if (api != null) {
      try {
        final res = await api.getOverview(childId).timeout(
              const Duration(seconds: 5),
            );
        final data = _extractData(res.data);
        if (data is Map<String, dynamic>) {
          final enrolled = (data['enrolled_courses'] as num?)?.toInt() ?? 0;
          final completed = (data['completed_courses'] as num?)?.toInt() ?? 0;
          final studying = (enrolled - completed).clamp(0, enrolled);
          final progress =
              enrolled > 0 ? (completed / enrolled).clamp(0.0, 1.0) : 0.0;

          return ParentProgressScreenData(
            overview: ParentProgressOverviewModel(
              activeCourseCount: enrolled,
              studyingCourseCount: studying,
              completedCourseCount: completed,
              averageProgressPercent: progress,
              progressStatusText: enrolled > 0
                  ? 'Tiến độ học tập ghi nhận'
                  : 'Chưa tham gia khóa học nào',
            ),
            courses: const [],
            homeroomNote: null,
          );
        }
      } catch (e) {
        AppLogger.d(
          'ParentLearning: getProgressOverview for child $childId failed: $e',
        );
      }
    }

    return const ParentProgressScreenData(
      overview: ParentProgressOverviewModel(
        activeCourseCount: 0,
        studyingCourseCount: 0,
        completedCourseCount: 0,
        averageProgressPercent: 0.0,
        progressStatusText: 'Chưa tham gia khóa học nào',
      ),
      courses: <ParentCourseProgressItem>[],
      homeroomNote: null,
    );
  }
}


