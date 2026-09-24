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
  Future<List<ParentScheduleSession>> getSessionsForDate({
    String? childId,
    required DateTime date,
  }) async {
    final allSessions = _buildMockSessionsForMonth(date);
    var filtered = allSessions.where((s) => _isSameDay(s.startTime, date));

    if (childId != null && childId.isNotEmpty) {
      filtered = filtered.where((s) => s.childId == childId);
    }

    final list = filtered.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  @override
  Future<Map<DateTime, List<String>>> getEventsMapByMonth({
    String? childId,
    required DateTime month,
  }) async {
    final allSessions = _buildMockSessionsForMonth(month);
    final map = <DateTime, Set<String>>{};

    for (final session in allSessions) {
      if (childId != null &&
          childId.isNotEmpty &&
          session.childId != childId) {
        continue;
      }
      final dateKey = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      map.putIfAbsent(dateKey, () => <String>{}).add(session.childId);
    }

    return map.map((key, value) => MapEntry(key, value.toList()));
  }

  @override
  Future<int> getSessionCountForWeek({
    String? childId,
    required DateTime anchorDate,
  }) async {
    final monday = anchorDate.subtract(
      Duration(days: anchorDate.weekday - 1),
    );
    final sunday = monday.add(const Duration(days: 6));
    final allSessions = _buildMockSessionsForMonth(anchorDate);

    final weekSessions = allSessions.where((s) {
      if (childId != null && childId.isNotEmpty && s.childId != childId) {
        return false;
      }
      final sDate = DateTime(
        s.startTime.year,
        s.startTime.month,
        s.startTime.day,
      );
      final mDate = DateTime(monday.year, monday.month, monday.day);
      final suDate = DateTime(sunday.year, sunday.month, sunday.day);
      return !sDate.isBefore(mDate) && !sDate.isAfter(suDate);
    });

    return weekSessions.length;
  }

  @override
  Future<List<ParentScheduleSession>> getScheduleSessions({
    String? childId,
    DateTime? date,
    ParentScheduleTab tab = ParentScheduleTab.week,
  }) async {
    final targetDate = date ?? DateTime.now();
    return getSessionsForDate(childId: childId, date: targetDate);
  }

  @override
  Future<List<DateTime>> getEventDates({
    String? childId,
    required DateTime anchorDate,
  }) async {
    final eventsMap = await getEventsMapByMonth(
      childId: childId,
      month: anchorDate,
    );
    return eventsMap.keys.toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Sinh danh sách mock ca học phong phú theo tháng
  List<ParentScheduleSession> _buildMockSessionsForMonth(DateTime anchorMonth) {
    final now = DateTime.now();
    final y = anchorMonth.year;
    final m = anchorMonth.month;
    final daysInMonth = DateTime(y, m + 1, 0).day;
    final list = <ParentScheduleSession>[];

    // 1. Luôn tạo ca học cho ngày HÔM NAY thực tế (nếu thuộc tháng đang xem)
    if (now.year == y && now.month == m) {
      list.addAll([
        // Ca 1 của Minh hôm nay: 09:00 - 10:00
        ParentScheduleSession(
          id: 'mock_${now.day}_minh_1',
          childId: studentMinhId,
          childName: 'Minh',
          childInitial: 'M',
          childBadgeColor: const Color(0xFFDBEAFE),
          subjectName: 'Toán (Đại số 10)',
          lessonTopic: 'Phương trình bậc hai & Định lý Vi-ét',
          startTime: DateTime(y, m, now.day, 9, 0),
          endTime: DateTime(y, m, now.day, 10, 0),
          instructorName: 'Cô Lan',
          status: ParentSessionStatus.inProgress,
          roomOrPlatform: 'Google Meet',
        ),
        // Ca 2 của Minh hôm nay: 15:30 - 17:00
        ParentScheduleSession(
          id: 'mock_${now.day}_minh_2',
          childId: studentMinhId,
          childName: 'Minh',
          childInitial: 'M',
          childBadgeColor: const Color(0xFFDBEAFE),
          subjectName: 'Vật lý 10',
          lessonTopic: 'Chuyển động thẳng biến đổi đều & Đồ thị vận tốc',
          startTime: DateTime(y, m, now.day, 15, 30),
          endTime: DateTime(y, m, now.day, 17, 0),
          instructorName: 'Thầy Dũng',
          status: ParentSessionStatus.upcoming,
          roomOrPlatform: 'Phòng 204, CS Phan Xích Long',
        ),
        // Ca của Lan hôm nay: 14:00 - 15:30
        ParentScheduleSession(
          id: 'mock_${now.day}_lan_1',
          childId: studentLanId,
          childName: 'Lan',
          childInitial: 'L',
          childBadgeColor: const Color(0xFFFCE7F3),
          subjectName: 'Tiếng Anh giao tiếp',
          lessonTopic: 'Speaking Fluency & Unit 4 Presentation',
          startTime: DateTime(y, m, now.day, 14, 0),
          endTime: DateTime(y, m, now.day, 15, 30),
          instructorName: 'Thầy Nam',
          status: ParentSessionStatus.upcoming,
          roomOrPlatform: 'Phòng 302, CS Phan Xích Long',
        ),
      ]);
    }

    // 2. Mock các ngày khác trong tháng theo mẫu Ảnh 3
    // Các ngày con Minh học:
    // 1, 3, 5, 7, 9, 10, 12, 14, 16, 18, 19, 21, 23, 24, 28, 31
    final minhDays = {
      1, 3, 5, 7, 9, 10, 12, 14, 16, 18, 19, 21, 23, 24, 28, 31,
    };
    for (final day in minhDays) {
      final isCurrentMonthToday =
          now.year == y && now.month == m && day == now.day;
      if (day > daysInMonth || isCurrentMonthToday) {
        continue;
      }
      list.add(
        ParentScheduleSession(
          id: 'mock_${day}_minh',
          childId: studentMinhId,
          childName: 'Minh',
          childInitial: 'M',
          childBadgeColor: const Color(0xFFDBEAFE),
          subjectName: day % 2 == 0 ? 'Tin học 10' : 'Toán (Đại số 10)',
          lessonTopic: day % 2 == 0
              ? 'Lập trình Python cơ bản & Cấu trúc rẽ nhánh'
              : 'Hàm số bậc nhất và đồ thị ứng dụng',
          startTime: DateTime(y, m, day, 9, 0),
          endTime: DateTime(y, m, day, 10, 30),
          instructorName: day % 2 == 0 ? 'Thầy Hoàng' : 'Cô Lan',
          status: day < now.day
              ? ParentSessionStatus.completed
              : ParentSessionStatus.upcoming,
          roomOrPlatform: day % 2 == 0 ? 'Google Meet' : 'Phòng 101, CS Quận 1',
        ),
      );
    }

    // Các ngày con Lan học:
    // 2, 4, 6, 9, 10, 13, 14, 15, 18, 20, 23, 24, 26, 28, 30
    final lanDays = {
      2, 4, 6, 9, 10, 13, 14, 15, 18, 20, 23, 24, 26, 28, 30,
    };
    for (final day in lanDays) {
      final isCurrentMonthToday =
          now.year == y && now.month == m && day == now.day;
      if (day > daysInMonth || isCurrentMonthToday) {
        continue;
      }
      list.add(
        ParentScheduleSession(
          id: 'mock_${day}_lan',
          childId: studentLanId,
          childName: 'Lan',
          childInitial: 'L',
          childBadgeColor: const Color(0xFFFCE7F3),
          subjectName: day % 3 == 0 ? 'Ngữ văn 7' : 'Tiếng Anh giao tiếp',
          lessonTopic: day % 3 == 0
              ? 'Phân tích văn bản nghị luận xã hội'
              : 'Vocabulary in Context & Pronunciation Practice',
          startTime: DateTime(y, m, day, 14, 0),
          endTime: DateTime(y, m, day, 15, 30),
          instructorName: day % 3 == 0 ? 'Cô Mai' : 'Thầy Nam',
          status: day < now.day
              ? ParentSessionStatus.completed
              : ParentSessionStatus.upcoming,
          roomOrPlatform: day % 3 == 0 ? 'Phòng 202' : 'Google Meet',
        ),
      );
    }

    return list;
  }
}
