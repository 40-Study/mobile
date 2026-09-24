import 'package:flutter/material.dart';

import 'package:study/core/logger/app_logger.dart';
import 'package:study/features/auth/data/models/user_model.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/repository/parent_schedule_repository.dart';

class ParentScheduleRepositoryImpl implements ParentScheduleRepository {
  ParentScheduleRepositoryImpl({
    ParentHomeApiClient? apiClient,
    this.enablePreviewFallback = true,
  }) : _apiClient = apiClient;

  final ParentHomeApiClient? _apiClient;
  final bool enablePreviewFallback;

  static const String studentTungId = '31843f49-fd61-47aa-af78-d1badbdcce52';
  static const String studentMinhId = 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732';
  static const String studentLanId = 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad';

  @override
  Future<List<FamilyScopeChild>> getChildren() async {
    // 1. Tải danh sách con thật từ backend API
    final realChildren = await _fetchRealChildren();

    // 2. Nếu bật fallback, gộp với con mẫu Minh & Lan giống như trang Home
    if (enablePreviewFallback) {
      return _mergeWithMockChildren(realChildren);
    }
    return realChildren;
  }

  @override
  Future<List<ParentScheduleSession>> getSessionsForDate({
    String? childId,
    required DateTime date,
  }) async {
    final allSessions = await _getAllSessionsForTarget(
      childId: childId,
      anchorDate: date,
    );

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
    final allSessions = await _getAllSessionsForTarget(
      childId: childId,
      anchorDate: month,
    );
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
    final allSessions = await _getAllSessionsForTarget(
      childId: childId,
      anchorDate: anchorDate,
    );

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

  // =========================================================================
  // API FETCH & SYNC HELPERS
  // =========================================================================

  Future<List<FamilyScopeChild>> _fetchRealChildren() async {
    if (_apiClient == null) return [];
    try {
      final response = await _apiClient.getChildren();
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
      AppLogger.w('ParentSchedule: fetch real children failed', e);
      AppLogger.d('ParentSchedule children stackTrace', stackTrace);
      return [];
    }
  }

  Future<List<ParentScheduleSession>> _fetchRealSchedules(
    String childId,
    String childName,
    Color childBadgeColor,
  ) async {
    if (_apiClient == null) return [];
    try {
      final response = await _apiClient.getSchedule(childId);
      final data = _extractData(response.data);
      final list = _extractList(
        data,
        keys: ['upcoming_sessions', 'schedules', 'items'],
      );
      return list
          .map(
            (e) => _mapRealSchedule(
              e as Map<String, dynamic>,
              childId: childId,
              childName: childName,
              childBadgeColor: childBadgeColor,
            ),
          )
          .whereType<ParentScheduleSession>()
          .toList();
    } catch (e, stackTrace) {
      AppLogger.w('ParentSchedule: fetch real schedule failed', e);
      AppLogger.d('ParentSchedule schedule stackTrace', stackTrace);
      return [];
    }
  }

  ParentScheduleSession? _mapRealSchedule(
    Map<String, dynamic> json, {
    required String childId,
    required String childName,
    required Color childBadgeColor,
  }) {
    final rawStart = json['start_time'] ?? json['start_date'];
    final rawEnd = json['end_time'] ?? json['end_date'];
    final startDt = _parseDateTime(rawStart);
    if (startDt == null) return null;

    final endDt =
        _parseDateTime(rawEnd) ?? startDt.add(const Duration(minutes: 90));
    final className = json['class_name'] as String? ??
        json['subject'] as String? ??
        'Lớp học';
    final topic = json['lesson_topic'] as String? ??
        json['title'] as String? ??
        'Chưa cập nhật nội dung bài học';
    final instructor = json['instructor_name'] as String? ??
        json['teacher'] as String? ??
        'Giáo viên';
    final room = json['room'] as String? ??
        (json['meeting_url'] != null ? 'Google Meet' : 'Tại cơ sở');

    return ParentScheduleSession(
      id: json['id']?.toString() ?? 'real_${startDt.millisecondsSinceEpoch}',
      childId: childId,
      childName: childName,
      childInitial: childName.isNotEmpty ? childName[0].toUpperCase() : 'C',
      childBadgeColor: childBadgeColor,
      subjectName: className,
      lessonTopic: topic,
      startTime: startDt,
      endTime: endDt,
      instructorName: instructor,
      status: startDt.isBefore(DateTime.now())
          ? ParentSessionStatus.completed
          : ParentSessionStatus.upcoming,
      roomOrPlatform: room,
    );
  }

  Future<List<ParentScheduleSession>> _getAllSessionsForTarget({
    String? childId,
    required DateTime anchorDate,
  }) async {
    final list = <ParentScheduleSession>[];
    final realChildren = await _fetchRealChildren();

    // 1. Tải lịch của con thật từ backend
    if (realChildren.isNotEmpty) {
      for (final child in realChildren) {
        if (childId == null || childId == child.id) {
          final realSessions = await _fetchRealSchedules(
            child.id,
            child.name,
            child.badgeColor,
          );
          if (realSessions.isNotEmpty) {
            list.addAll(realSessions);
          } else if (enablePreviewFallback) {
            // Nếu backend chưa có lịch cho con thật, sinh mock mẫu cho con thật
            list.addAll(_buildMockSessionsForTung(anchorDate, child));
          }
        }
      }
    } else if (enablePreviewFallback &&
        (childId == null || childId == studentTungId)) {
      // Mock con thật Mai Hoàng Tùng
      final tungChild = FamilyScopeChild.sample(
        id: studentTungId,
        name: 'Mai Hoàng Tùng',
        className: '12A',
      );
      list.addAll(_buildMockSessionsForTung(anchorDate, tungChild));
    }

    // 2. Gộp mock sessions của Minh & Lan khi enablePreviewFallback
    if (enablePreviewFallback) {
      if (childId == null ||
          childId == studentMinhId ||
          childId == studentLanId) {
        list.addAll(_buildMockSessionsForMonth(anchorDate));
      }
    }

    return list;
  }

  // =========================================================================
  // MOCK DATA GENERATORS (DEMO FULL TÍNH NĂNG NHIỀU CON)
  // =========================================================================

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

  List<ParentScheduleSession> _buildMockSessionsForTung(
    DateTime anchorMonth,
    FamilyScopeChild tung,
  ) {
    final now = DateTime.now();
    final y = anchorMonth.year;
    final m = anchorMonth.month;
    final daysInMonth = DateTime(y, m + 1, 0).day;
    final list = <ParentScheduleSession>[];

    // Ca học hôm nay của Tùng
    if (now.year == y && now.month == m) {
      list.add(
        ParentScheduleSession(
          id: 'mock_${now.day}_tung_1',
          childId: tung.id,
          childName: tung.name,
          childInitial: tung.initialLetter,
          childBadgeColor: tung.badgeColor,
          subjectName: 'Toán nâng cao 12',
          lessonTopic: 'Chuyên đề Nguyên hàm & Tích phân từng phần',
          startTime: DateTime(y, m, now.day, 7, 30),
          endTime: DateTime(y, m, now.day, 9, 0),
          instructorName: 'Thầy Hưng',
          status: ParentSessionStatus.completed,
          roomOrPlatform: 'Phòng 401, CS Quận 1',
        ),
      );
    }

    // Các ngày con Tùng học trong tháng: 4, 8, 12, 16, 20, 24, 28
    final tungDays = {4, 8, 12, 16, 20, 24, 28};
    for (final day in tungDays) {
      final isToday = now.year == y && now.month == m && day == now.day;
      if (day > daysInMonth || isToday) continue;
      list.add(
        ParentScheduleSession(
          id: 'mock_${day}_tung',
          childId: tung.id,
          childName: tung.name,
          childInitial: tung.initialLetter,
          childBadgeColor: tung.badgeColor,
          subjectName: day % 2 == 0 ? 'Toán 12' : 'Vật lý 12',
          lessonTopic: day % 2 == 0
              ? 'Khảo sát hàm số & Ứng dụng đạo hàm'
              : 'Dao động điều hoà & Con lắc lò xo',
          startTime: DateTime(y, m, day, 18, 0),
          endTime: DateTime(y, m, day, 19, 30),
          instructorName: 'Thầy Hưng',
          status: day < now.day
              ? ParentSessionStatus.completed
              : ParentSessionStatus.upcoming,
          roomOrPlatform: 'Google Meet',
        ),
      );
    }

    return list;
  }

  List<ParentScheduleSession> _buildMockSessionsForMonth(DateTime anchorMonth) {
    final now = DateTime.now();
    final y = anchorMonth.year;
    final m = anchorMonth.month;
    final daysInMonth = DateTime(y, m + 1, 0).day;
    final list = <ParentScheduleSession>[];

    // 1. Luôn tạo ca học cho ngày HÔM NAY thực tế
    if (now.year == y && now.month == m) {
      list.addAll([
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
    final minhDays = {
      1, 3, 5, 7, 9, 10, 12, 14, 16, 18, 19, 21, 23, 24, 28, 31,
    };
    for (final day in minhDays) {
      final isToday = now.year == y && now.month == m && day == now.day;
      if (day > daysInMonth || isToday) continue;
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

    final lanDays = {
      2, 4, 6, 9, 10, 13, 14, 15, 18, 20, 23, 24, 26, 28, 30,
    };
    for (final day in lanDays) {
      final isToday = now.year == y && now.month == m && day == now.day;
      if (day > daysInMonth || isToday) continue;
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

  // =========================================================================
  // UTILITIES
  // =========================================================================

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
      if (data['data'] is List) return data['data'] as List<dynamic>;
    }
    return [];
  }

  DateTime? _parseDateTime(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    try {
      return DateTime.parse(text);
    } catch (_) {
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(text);
      if (match != null) {
        final now = DateTime.now();
        final h = int.parse(match.group(1)!);
        final m = int.parse(match.group(2)!);
        return DateTime(now.year, now.month, now.day, h, m);
      }
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
