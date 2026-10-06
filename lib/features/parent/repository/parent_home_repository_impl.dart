import 'dart:async';

import 'package:flutter/material.dart';
import 'package:study/core/logger/app_logger.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';

class ParentHomeRepositoryImpl implements ParentHomeRepository {
  ParentHomeRepositoryImpl({
    ParentHomeApiClient? apiClient,
    this.enablePreviewFallback = true,
  }) : _api = apiClient;

  final ParentHomeApiClient? _api;

  /// Bật fallback data mẫu để demo UI đầy đủ khi backend chưa có data.
  final bool enablePreviewFallback;

  @override
  Future<ParentHomeData> getHomeDashboard({String? childId}) async {
    // 1. Luôn tải danh sách con thật từ backend nếu được
    var realChildren = <FamilyScopeChild>[];
    try {
      realChildren = await _fetchChildren();
    } catch (e, stackTrace) {
      if (!enablePreviewFallback) {
        rethrow;
      }
      AppLogger.w(
        'ParentHome: fetch children failed, falling back to mock children',
        e,
      );
      AppLogger.d('ParentHome children stackTrace', stackTrace);
    }

    if (enablePreviewFallback) {
      final children = _mergeWithMockChildren(realChildren);
      final target = _resolveChild(children, childId);

      // Nếu phụ huynh chọn con thật Mai Hoàng Tùng, ưu tiên dữ liệu
      // thật từ backend
      final isRealChildSelected =
          childId != null &&
          (childId == studentTungId ||
              realChildren.any(
                (c) =>
                    c.id == childId &&
                    c.id != studentMinhId &&
                    c.id != studentLanId,
              ));

      if (isRealChildSelected) {
        List<ParentScheduleItem>? schedules;
        List<ParentAlertItem>? alerts;
        ParentAnalyticsData? analytics;
        try {
          final realResults = await Future.wait([
            _fetchSchedules(childId),
            _fetchAlerts(childId),
            _fetchAnalytics(target),
          ]);
          schedules = realResults[0] as List<ParentScheduleItem>;
          alerts = realResults[1] as List<ParentAlertItem>;
          analytics = realResults[2] as ParentAnalyticsData?;
        } catch (e, st) {
          AppLogger.w(
            'ParentHome: fetch real child details failed, falling back to mock',
            e,
          );
          AppLogger.d('ParentHome real child stackTrace', st);
        }
        return ParentHomeData(
          children: children,
          selectedChildId: childId,
          alerts: alerts ?? _filterFallbackAlerts(childId),
          schedules: schedules ?? _filterFallbackSchedules(childId),
          analytics: analytics ?? _fallbackAnalytics(target),
        );
      }

      final alerts = _filterFallbackAlerts(childId);
      final schedules = _filterFallbackSchedules(childId);
      final analytics = _fallbackAnalytics(target);

      return ParentHomeData(
        children: children,
        selectedChildId: childId,
        alerts: alerts,
        schedules: schedules,
        analytics: analytics,
      );
    }

    // "Tất cả các con" => lấy data của con đầu tiên
    final target = _resolveChild(realChildren, childId);

    // 2. Song song lấy schedule / assignments / grades
    final results = await Future.wait([
      _fetchSchedules(target?.id),
      _fetchAlerts(target?.id),
      _fetchAnalytics(target),
    ]);

    final schedules = results[0] as List<ParentScheduleItem>;
    final alerts = results[1] as List<ParentAlertItem>;
    final analytics = results[2] as ParentAnalyticsData?;

    return ParentHomeData(
      children: realChildren,
      selectedChildId: childId,
      alerts: alerts,
      schedules: schedules,
      analytics: analytics,
    );
  }

  @override
  Future<List<FamilyScopeChild>> getChildren() async {
    var realChildren = <FamilyScopeChild>[];
    try {
      realChildren = await _fetchChildren();
    } catch (e, stackTrace) {
      if (!enablePreviewFallback) {
        rethrow;
      }
      AppLogger.w(
        'ParentHome: fetch children failed, falling back to mock children',
        e,
      );
      AppLogger.d('ParentHome children stackTrace', stackTrace);
    }
    if (enablePreviewFallback) {
      return _mergeWithMockChildren(realChildren);
    }
    return realChildren;
  }

  @override
  Future<List<ParentAlertItem>> getAlerts({String? childId}) async {
    if (enablePreviewFallback) {
      final isRealChild = childId != null &&
          childId != studentMinhId &&
          childId != studentLanId;
      if (isRealChild) {
        try {
          return await _fetchAlerts(childId);
        } catch (e, st) {
          AppLogger.w(
            'ParentHome: getAlerts for real child failed, fallback',
            e,
          );
          AppLogger.d('ParentHome getAlerts stackTrace', st);
          return _filterFallbackAlerts(childId);
        }
      }
      return _filterFallbackAlerts(childId);
    }
    return _fetchAlerts(childId);
  }

  @override
  Future<List<ParentScheduleItem>> getSchedules({String? childId}) async {
    if (enablePreviewFallback) {
      final isRealChild = childId != null &&
          childId != studentMinhId &&
          childId != studentLanId;
      if (isRealChild) {
        try {
          return await _fetchSchedules(childId);
        } catch (e, st) {
          AppLogger.w(
            'ParentHome: getSchedules for real child failed, fallback to mock',
            e,
          );
          AppLogger.d('ParentHome getSchedules stackTrace', st);
          return _filterFallbackSchedules(childId);
        }
      }
      return _filterFallbackSchedules(childId);
    }
    return _fetchSchedules(childId);
  }

  @override
  Future<ParentAnalyticsData?> getAnalytics({String? childId}) async {
    final children = await getChildren();
    final target = _resolveChild(children, childId);
    if (enablePreviewFallback) {
      final isRealChild = target != null &&
          target.id != studentMinhId &&
          target.id != studentLanId;
      if (isRealChild) {
        try {
          final res = await _fetchAnalytics(target);
          if (res != null) return res;
        } catch (e, st) {
          AppLogger.w(
            'ParentHome: getAnalytics for real child failed, fallback',
            e,
          );
          AppLogger.d('ParentHome getAnalytics stackTrace', st);
        }
      }
      return _fallbackAnalytics(target);
    }
    return _fetchAnalytics(target);
  }

  @override
  Future<List<ParentAnalyticsData>> getAnalyticsList({String? childId}) async {
    final children = await getChildren();
    if (childId != null) {
      final target = _resolveChild(children, childId);
      if (target == null) return const [];
      if (enablePreviewFallback) {
        final isRealChild =
            target.id != studentMinhId && target.id != studentLanId;
        if (isRealChild) {
          try {
            final real = await _fetchAnalytics(target);
            if (real != null) return [real];
          } catch (e, st) {
            AppLogger.w(
              'ParentHome: getAnalyticsList for real child failed, fallback',
              e,
            );
            AppLogger.d('ParentHome getAnalyticsList stackTrace', st);
          }
        }
        final single = _fallbackAnalytics(target);
        return [single];
      }
      final single = await _fetchAnalytics(target);
      return single != null ? [single] : const [];
    }
    if (enablePreviewFallback) {
      return children.map(_fallbackAnalytics).toList();
    }
    final results = await Future.wait(
      children.map(_fetchAnalytics),
    );
    return results.whereType<ParentAnalyticsData>().toList();
  }

  // =========================================================================
  // FETCH HELPERS (BỌC TIMEOUT VÀ BÁO LỖI MINH BẠCH KHI GỌI API THẤT BẠI)
  // =========================================================================

  Future<List<FamilyScopeChild>> _fetchChildren() async {
    final api = _api;
    if (api == null) return [];
    try {
      // Giới hạn thời gian chờ tối đa 10 giây; nếu backend phản hồi chậm
      // hoặc mạng lỗi thì ném lỗi để UI hiển thị thông báo lỗi kèm nút Thử lại.
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
      AppLogger.w('ParentHome: fetch children failed', e);
      AppLogger.d('ParentHome children stackTrace', stackTrace);
      // Ném lỗi để Bloc xử lý và hiển thị màn hình báo lỗi,
      // không tự ý dùng mock data khi API thất bại.
      rethrow;
    }
  }

  Future<List<ParentScheduleItem>> _fetchSchedules(String? childId) async {
    final api = _api;
    if (childId == null || api == null) return [];
    try {
      final response = await api.getSchedule(childId).timeout(
            const Duration(seconds: 10),
          );
      final data = _extractData(response.data);
      final list = _extractList(
        data,
        keys: ['upcoming_sessions', 'schedules', 'items'],
      );
      return list
          .map((e) => _mapSchedule(e as Map<String, dynamic>))
          .whereType<ParentScheduleItem>()
          .toList();
    } catch (e, stackTrace) {
      AppLogger.w('ParentHome: fetch schedule failed', e);
      AppLogger.d('ParentHome schedule stackTrace', stackTrace);
      // Ném lỗi để Bloc xử lý khi tải lịch của con thất bại.
      rethrow;
    }
  }

  Future<List<ParentAlertItem>> _fetchAlerts(String? childId) async {
    final api = _api;
    if (childId == null || api == null) return [];
    try {
      final response = await api.getAssignments(childId).timeout(
            const Duration(seconds: 10),
          );
      final data = _extractData(response.data);
      final list = _extractList(data, keys: ['assignments', 'items']);
      final overdue = list
          .map((e) => _mapOverdueAlert(e as Map<String, dynamic>))
          .whereType<ParentAlertItem>()
          .toList();
      return overdue;
    } catch (e, stackTrace) {
      AppLogger.w('ParentHome: fetch alerts failed', e);
      AppLogger.d('ParentHome alerts stackTrace', stackTrace);
      // Ném lỗi để Bloc xử lý khi tải thông báo bài tập của con thất bại.
      rethrow;
    }
  }

  Future<ParentAnalyticsData?> _fetchAnalytics(FamilyScopeChild? target) async {
    final api = _api;
    if (target == null || api == null) return null;
    try {
      final response = await api.getGrades(target.id).timeout(
            const Duration(seconds: 10),
          );
      final data = _extractData(response.data);
      final grades = _extractList(
        data,
        keys: ['final_grades', 'grades', 'items'],
      );
      final average = _extractAverage(grades);
      if (average == null) return null;

      return ParentAnalyticsData(
        childName: target.name,
        className: target.className ?? 'Lớp 10',
        reportLabel: 'Báo cáo tuần 4 • Môn Ngữ Văn',
        subjectName: 'Ngữ Văn',
        progressPercent: 15,
        averageScore: average,
        weeklyTrend: const [0.4, 0.55, 0.7, 0.9],
        insightText: _fallbackInsightText,
        insightHighlight: 'Đọc hiểu',
      );
    } catch (e, stackTrace) {
      AppLogger.w('ParentHome: fetch analytics failed', e);
      AppLogger.d('ParentHome analytics stackTrace', stackTrace);
      // Ném lỗi để Bloc xử lý khi tải phân tích kết quả học tập thất bại.
      rethrow;
    }
  }

  // =========================================================================
  // MAP HELPERS
  // =========================================================================

  ParentScheduleItem? _mapSchedule(Map<String, dynamic> json) {
    final startTime = _formatTime(json['start_time']);
    if (startTime == null) return null;

    final className = json['class_name'] as String? ?? '';
    final room = json['room'] as String? ?? '';
    final isOnline = _isOnline(json);
    final childName = json['child_name'] as String? ?? 'Con';

    return ParentScheduleItem(
      startTime: startTime,
      childName: childName,
      subjectName: className,
      locationOrLink: isOnline ? 'Trực tuyến trên Google Meet' : 'Tại cơ sở',
      teacherOrRoom: isOnline
          ? (json['instructor_name'] as String? ?? 'Giáo viên')
          : (room.isNotEmpty ? 'Phòng học $room' : 'Phòng học'),
      mode: isOnline ? ParentScheduleMode.online : ParentScheduleMode.offline,
      statusLabel: 'Sắp bắt đầu',
    );
  }

  ParentAlertItem? _mapOverdueAlert(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    if (status != 'overdue') return null;

    final title = json['title'] as String? ?? 'Bài tập';
    final dueDate = json['due_date'] as String? ?? '';
    final id = json['id'] as String? ?? json['assignment_id'] as String?;
    final studentId =
        json['student_id'] as String? ?? json['child_id'] as String?;

    return ParentAlertItem(
      tier: ParentAlertTier.emergency,
      type: ParentAlertType.overdue,
      childId: studentId,
      targetId: id,
      childName: json['child_name'] as String? ?? 'Con',
      subjectName: json['course_name'] as String? ?? '',
      detail: '1 bài tập "$title" đã quá hạn nộp',
      metaText: dueDate.isNotEmpty ? 'Hạn chót: $dueDate' : 'Hạn chót đã qua',
      tagLabel: 'Quá hạn',
    );
  }

  bool _isOnline(Map<String, dynamic> json) {
    final raw = [
      json['room'],
      json['location'],
      json['type'],
      json['meeting_url'],
      json['livestream_id'],
    ].whereType<String>().join(' ').toLowerCase();
    return raw.contains('online') ||
        raw.contains('meet') ||
        raw.contains('zoom') ||
        raw.contains('livestream');
  }

  String? _formatTime(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(text);
    if (match == null) return null;
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
  }

  double? _extractAverage(List<dynamic> grades) {
    if (grades.isEmpty) return null;
    var total = 0.0;
    var count = 0;
    for (final g in grades) {
      final json = g as Map<String, dynamic>;
      final value =
          json['weighted_average'] ?? json['average'] ?? json['score'];
      final parsed = double.tryParse(value.toString());
      if (parsed != null) {
        total += parsed;
        count++;
      }
    }
    if (count == 0) return null;
    return double.parse((total / count).toStringAsFixed(1));
  }

  // =========================================================================
  // EXTRACT HELPERS
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

  FamilyScopeChild? _resolveChild(
    List<FamilyScopeChild> children,
    String? childId,
  ) {
    if (children.isEmpty) return null;
    if (childId == null) return children.first;
    return children.where((c) => c.id == childId).firstOrNull ?? children.first;
  }

  // =========================================================================
  // FALLBACK DATA (PREVIEW MOCKUP)
  // =========================================================================

  static const String studentTungId = '31843f49-fd61-47aa-af78-d1badbdcce52';
  static const String studentMinhId = 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732';
  static const String studentLanId = 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad';

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
        FamilyScopeChild.sample(
          id: studentMinhId,
          name: 'Minh',
          className: '10A1',
        ),
      );
    }
    if (!list.any((c) => c.id == studentLanId)) {
      list.add(
        FamilyScopeChild.sample(id: studentLanId, name: 'Lan', className: '7B'),
      );
    }

    return list;
  }

  List<ParentAlertItem> _filterFallbackAlerts(String? childId) {
    final allAlerts = [
      // Tier 1: Khẩn cấp / Quá hạn / Đổi lịch bất thường
      const ParentAlertItem(
        tier: ParentAlertTier.emergency,
        type: ParentAlertType.overdue,
        childId: studentMinhId,
        childName: 'Minh',
        subjectName: 'Hình học 10',
        detail: '1 bài tập trắc nghiệm đã quá hạn nộp',
        metaText: 'Hạn chót: 23:59 hôm qua',
        tagLabel: 'Quá hạn',
      ),
      const ParentAlertItem(
        tier: ParentAlertTier.emergency,
        type: ParentAlertType.scheduleChange,
        childId: studentLanId,
        childName: 'Lan',
        subjectName: 'Anh văn giao tiếp',
        detail: 'Lớp đổi giờ bắt đầu sang 17:00 (lùi 30 phút)',
        metaText: 'Giáo viên vừa cập nhật',
        tagLabel: 'Đổi lịch',
      ),
      // Tier 2: Đến hạn trong hôm nay
      const ParentAlertItem(
        tier: ParentAlertTier.dueToday,
        type: ParentAlertType.dueToday,
        childId: studentMinhId,
        childName: 'Minh',
        subjectName: 'Ngữ văn 10',
        detail: 'Bài viết luận văn học đến hạn nộp tối nay',
        metaText: 'Hạn chót: 23:59 hôm nay',
        tagLabel: 'Đến hạn hôm nay',
      ),
      // Tier 3: Sự kiện tiếp theo (Sắp tới)
      const ParentAlertItem(
        tier: ParentAlertTier.nextEvent,
        type: ParentAlertType.upcomingExam,
        childId: studentLanId,
        childName: 'Lan',
        subjectName: 'Toán 7',
        detail: 'Bài kiểm tra giữa kỳ vào Thứ Năm tuần này',
        metaText: 'Chuẩn bị máy tính Casio & thước kẻ',
        tagLabel: 'Sắp tới',
      ),
      // Tier 4: Tổng quan / Thông tin chung
      const ParentAlertItem(
        tier: ParentAlertTier.generalInfo,
        type: ParentAlertType.announcement,
        childId: studentMinhId,
        childName: 'Minh',
        subjectName: 'Vật lý 10',
        detail: 'Giáo viên nhận xét: Nắm vững kiến thức động học',
        metaText: 'Đã hoàn thành 5/5 bài tập tuần 4',
        tagLabel: 'Thông tin',
      ),
    ];

    final filtered = (childId == null
            ? allAlerts
            : allAlerts.where((a) => a.childId == childId).toList())
      ..sort((a, b) => a.tier.index.compareTo(b.tier.index));
    return filtered;
  }

  List<ParentScheduleItem> _filterFallbackSchedules(String? childId) {
    const allSchedules = [
      ParentScheduleItem(
        id: 'home_sched_minh_1',
        childId: studentMinhId,
        startTime: '09:00',
        endTime: '10:00',
        childName: 'Minh',
        childInitial: 'M',
        childBadgeColor: Color(0xFFDBEAFE),
        subjectName: 'Toán (Đại số 10)',
        lessonTopic: 'Phương trình bậc hai & Định lý Vi-ét',
        locationOrLink: 'Google Meet',
        teacherOrRoom: 'Cô Lan',
        mode: ParentScheduleMode.online,
        status: ParentSessionStatus.inProgress,
        statusLabel: 'Đang diễn ra',
        durationMinutes: 60,
      ),
      ParentScheduleItem(
        id: 'home_sched_lan_1',
        childId: studentLanId,
        startTime: '14:00',
        endTime: '15:30',
        childName: 'Lan',
        childInitial: 'L',
        childBadgeColor: Color(0xFFFCE7F3),
        subjectName: 'Tiếng Anh giao tiếp',
        lessonTopic: 'Speaking Fluency & Unit 4 Presentation',
        locationOrLink: 'Phòng 302, CS Phan Xích Long',
        teacherOrRoom: 'Thầy Nam',
        mode: ParentScheduleMode.offline,
        status: ParentSessionStatus.upcoming,
        statusLabel: 'Sắp diễn ra',
        durationMinutes: 90,
      ),
      ParentScheduleItem(
        id: 'home_sched_minh_2',
        childId: studentMinhId,
        startTime: '07:30',
        endTime: '08:45',
        childName: 'Minh',
        childInitial: 'M',
        childBadgeColor: Color(0xFFDBEAFE),
        subjectName: 'Khoa học tự nhiên',
        lessonTopic: 'Cấu tạo phân tử & Phản ứng hoá học cơ bản',
        locationOrLink: 'Phòng 101, CS Quận 1',
        teacherOrRoom: 'Thầy Hùng',
        mode: ParentScheduleMode.offline,
        status: ParentSessionStatus.completed,
        statusLabel: 'Đã kết thúc',
        durationMinutes: 75,
      ),
    ];
    if (childId == studentMinhId) {
      return allSchedules.where((s) => s.childName == 'Minh').toList();
    }
    if (childId == studentLanId) {
      return allSchedules.where((s) => s.childName == 'Lan').toList();
    }
    return allSchedules;
  }

  ParentAnalyticsData _fallbackAnalytics(FamilyScopeChild? target) {
    final isLan = target?.id == studentLanId;
    final name = target?.name ?? (isLan ? 'Lan' : 'Minh');
    final className = target?.className ?? (isLan ? 'Lớp 7B' : 'Lớp 10A1');
    final subject = isLan ? 'Tiếng Anh' : 'Toán';
    final reportLabel = 'Báo cáo tuần 42 • Môn $subject';
    final averageScore = isLan ? 8.8 : 8.4;
    final weeklyTrend = isLan
        ? const [0.5, 0.6, 0.7, 0.85, 0.95]
        : const [0.35, 0.5, 0.65, 0.8, 0.95];

    return ParentAnalyticsData(
      childId: target?.id ?? (isLan ? studentLanId : studentMinhId),
      childBadgeColor: target?.badgeColor,
      childName: name,
      className: className,
      reportLabel: reportLabel,
      subjectName: subject,
      progressPercent: isLan ? 18 : 15,
      averageScore: averageScore,
      weeklyTrend: weeklyTrend,
      insightText: isLan
          ? 'Tiến bộ vượt bậc ở dạng Viết luận môn Tiếng Anh. '
              'Hoàn thành 100% bài tập giao về nhà đúng hạn.'
          : _fallbackInsightText,

      insightHighlight: isLan ? 'Viết luận' : 'Đọc hiểu',
    );
  }

  static const _fallbackInsightText =
      'Cải thiện rõ ở dạng Đọc hiểu so với 3 buổi gần đây. '
      'Tốc độ làm bài trắc nghiệm nhanh hơn 22%.';
}
