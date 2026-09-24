import 'package:flutter/material.dart';

import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/repository/parent_schedule_repository.dart';

class ParentScheduleRepositoryImpl implements ParentScheduleRepository {
  ParentScheduleRepositoryImpl({
    ParentHomeApiClient? apiClient,
    this.enablePreviewFallback = true,
  }) : _apiClient = apiClient;

  // ignore: unused_field
  final ParentHomeApiClient? _apiClient;
  final bool enablePreviewFallback;

  static const String studentTungId = '31843f49-fd61-47aa-af78-d1badbdcce52';
  static const String studentMinhId = 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732';
  static const String studentLanId = 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad';

  @override
  Future<List<FamilyScopeChild>> getChildren() async {
    return [
      const FamilyScopeChild(
        id: studentMinhId,
        name: 'Minh',
        className: '10A1',
        initialLetter: 'M',
        badgeColor: Color(0xFFDBEAFE),
      ),
      const FamilyScopeChild(
        id: studentLanId,
        name: 'Lan',
        className: '7B',
        initialLetter: 'L',
        badgeColor: Color(0xFFFCE7F3),
      ),
    ];
  }

  @override
  Future<List<ParentScheduleSession>> getScheduleSessions({
    String? childId,
    DateTime? date,
    ParentScheduleTab tab = ParentScheduleTab.week,
  }) async {
    final targetDate = date ?? DateTime.now();
    final allSessions = _buildMockSessions(targetDate);

    // 1. Lọc theo con
    var filtered = allSessions;
    if (childId != null && childId.isNotEmpty) {
      filtered = filtered.where((s) => s.childId == childId).toList();
    }

    // 2. Lọc theo ngày nếu xem hôm nay hoặc chọn ngày cụ thể
    if (tab == ParentScheduleTab.today) {
      filtered = filtered
          .where((s) => _isSameDay(s.startTime, targetDate))
          .toList();
    } else if (tab == ParentScheduleTab.week && date != null) {
      // Khi ở tab Tuần này: nếu người dùng chọn ngày cụ thể
    }

    return filtered;
  }

  @override
  Future<List<DateTime>> getEventDates({
    String? childId,
    required DateTime anchorDate,
  }) async {
    final now = anchorDate;
    // Tạo danh sách các ngày trong tuần có ca học (T2 đến CN)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<ParentScheduleSession> _buildMockSessions(DateTime baseDate) {
    final today = baseDate;
    final tomorrow = baseDate.add(const Duration(days: 1));

    return [
      // 1. Ca học Đang diễn ra của Minh hôm nay
      ParentScheduleSession(
        id: 'session_minh_math_today',
        childId: studentMinhId,
        childName: 'Minh',
        childInitial: 'M',
        childBadgeColor: const Color(0xFFDBEAFE),
        subjectName: 'Toán (Đại số 10)',
        lessonTopic: 'Phương trình bậc hai & Định lý Vi-ét',
        startTime: DateTime(today.year, today.month, today.day, 9, 0),
        endTime: DateTime(today.year, today.month, today.day, 10, 0),
        instructorName: 'Cô Lan',
        status: ParentSessionStatus.inProgress,
        roomOrPlatform: 'Google Meet',
      ),

      // 2. Ca học Sắp diễn ra của Lan hôm nay
      ParentScheduleSession(
        id: 'session_lan_eng_today',
        childId: studentLanId,
        childName: 'Lan',
        childInitial: 'L',
        childBadgeColor: const Color(0xFFFCE7F3),
        subjectName: 'Tiếng Anh giao tiếp',
        lessonTopic: 'Speaking Fluency & Unit 4 Presentation',
        startTime: DateTime(today.year, today.month, today.day, 14, 0),
        endTime: DateTime(today.year, today.month, today.day, 15, 30),
        instructorName: 'Thầy Nam',
        status: ParentSessionStatus.upcoming,
        roomOrPlatform: 'Phòng 302, CS Phan Xích Long',
      ),

      // 3. Ca học Đã kết thúc của Minh sáng sớm hôm nay
      ParentScheduleSession(
        id: 'session_minh_science_today',
        childId: studentMinhId,
        childName: 'Minh',
        childInitial: 'M',
        childBadgeColor: const Color(0xFFDBEAFE),
        subjectName: 'Khoa học tự nhiên',
        lessonTopic: 'Cấu tạo phân tử & Phản ứng hoá học cơ bản',
        startTime: DateTime(today.year, today.month, today.day, 7, 30),
        endTime: DateTime(today.year, today.month, today.day, 8, 45),
        instructorName: 'Thầy Hùng',
        status: ParentSessionStatus.completed,
        roomOrPlatform: 'Phòng 101, CS Quận 1',
      ),

      // 4. Ca học Sắp diễn ra của Lan ngày mai
      ParentScheduleSession(
        id: 'session_lan_math_tomorrow',
        childId: studentLanId,
        childName: 'Lan',
        childInitial: 'L',
        childBadgeColor: const Color(0xFFFCE7F3),
        subjectName: 'Toán tư duy',
        lessonTopic: 'Phép nhân chia phân số & Ứng dụng thực tế',
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 30),
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
        instructorName: 'Cô Hương',
        status: ParentSessionStatus.upcoming,
        roomOrPlatform: 'Google Meet',
      ),

      // 5. Ca học Sắp diễn ra của Minh ngày mai
      ParentScheduleSession(
        id: 'session_minh_physics_tomorrow',
        childId: studentMinhId,
        childName: 'Minh',
        childInitial: 'M',
        childBadgeColor: const Color(0xFFDBEAFE),
        subjectName: 'Vật lý 10',
        lessonTopic: 'Chuyển động thẳng biến đổi đều & Đồ thị vận tốc',
        startTime: DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          14,
          30,
        ),
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 0),
        instructorName: 'Thầy Dũng',
        status: ParentSessionStatus.upcoming,
        roomOrPlatform: 'Phòng 204, CS Phan Xích Long',
      ),
    ];
  }
}
