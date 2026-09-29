import 'dart:async';

import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_class_detail_model.dart';
import 'package:study/features/parent/data/models/parent_learning_hub_data.dart';
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
