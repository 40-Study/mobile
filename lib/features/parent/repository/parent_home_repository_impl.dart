import 'package:study/core/logger/app_logger.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';

class ParentHomeRepositoryImpl implements ParentHomeRepository {
  ParentHomeRepositoryImpl({
    required ParentHomeApiClient apiClient,
    this.enablePreviewFallback = false,
  }) : _api = apiClient;

  final ParentHomeApiClient _api;

  /// Bật fallback data mẫu để demo UI đầy đủ khi backend chưa có data.
  final bool enablePreviewFallback;

  @override
  Future<ParentHomeData> getHomeDashboard({String? childId}) async {
    // 1. Danh sách con (ưu tiên data thật)
    var children = await _fetchChildren();
    if (enablePreviewFallback && children.isEmpty) {
      children = _fallbackChildren();
    }

    // "Tất cả các con" => lấy data của con đầu tiên
    final target = _resolveChild(children, childId);

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
      children: children,
      selectedChildId: childId,
      alerts: enablePreviewFallback && alerts.isEmpty
          ? _fallbackAlerts()
          : alerts,
      schedules: enablePreviewFallback && schedules.isEmpty
          ? _fallbackSchedules()
          : schedules,
      analytics: enablePreviewFallback && analytics == null
          ? _fallbackAnalytics(target)
          : analytics,
    );
  }

  // ============================================================================
  // FETCH HELPERS
  // ============================================================================

  Future<List<FamilyScopeChild>> _fetchChildren() async {
    try {
      final response = await _api.getChildren();
      final data = _extractData(response.data);
      final list = _extractList(data, keys: ['children', 'items']);
      return list
          .asMap()
          .entries
          .map((e) => FamilyScopeChild.fromUserModel(
                UserModel.fromJson(e.value as Map<String, dynamic>),
                index: e.key,
              ))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.w('ParentHome: fetch children failed', e);
      AppLogger.d('ParentHome children stackTrace', stackTrace);
      return [];
    }
  }

  Future<List<ParentScheduleItem>> _fetchSchedules(String? childId) async {
    if (childId == null) return [];
    try {
      final response = await _api.getSchedule(childId);
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
      return [];
    }
  }

  Future<List<ParentAlertItem>> _fetchAlerts(String? childId) async {
    if (childId == null) return [];
    try {
      final response = await _api.getAssignments(childId);
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
      return [];
    }
  }

  Future<ParentAnalyticsData?> _fetchAnalytics(FamilyScopeChild? target) async {
    if (target == null) return null;
    try {
      final response = await _api.getGrades(target.id);
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
      return null;
    }
  }

  // ============================================================================
  // MAP HELPERS
  // ============================================================================

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

    return ParentAlertItem(
      type: ParentAlertType.overdue,
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

  // ============================================================================
  // EXTRACT HELPERS
  // ============================================================================

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
    return children.where((c) => c.id == childId).firstOrNull ??
        children.first;
  }

  // ============================================================================
  // FALLBACK DATA
  // ============================================================================

  List<FamilyScopeChild> _fallbackChildren() => [
        FamilyScopeChild.sample(
          id: 'child-minh',
          name: 'Minh Anh',
          className: 'Lớp 10A1',
        ),
        FamilyScopeChild.sample(
          id: 'child-lan',
          name: 'Lan Phương',
          className: 'Lớp 8A2',
        ),
      ];

  List<ParentAlertItem> _fallbackAlerts() => const [
        ParentAlertItem(
          type: ParentAlertType.overdue,
          childName: 'Minh',
          subjectName: 'Hình học 10',
          detail: '1 bài tập trắc nghiệm đã quá hạn nộp',
          metaText: 'Hạn chót: 23:59 hôm qua',
          tagLabel: 'Quá hạn',
        ),
        ParentAlertItem(
          type: ParentAlertType.scheduleChange,
          childName: 'Lan',
          subjectName: 'Anh văn giao tiếp',
          detail: 'Lớp đổi giờ bắt đầu sang 17:00 (lùi 30 phút)',
          metaText: 'Giáo viên vừa xác nhận',
          tagLabel: 'Thay đổi',
        ),
      ];

  List<ParentScheduleItem> _fallbackSchedules() => const [
        ParentScheduleItem(
          startTime: '14:00',
          childName: 'Minh',
          subjectName: 'Đại số 10',
          locationOrLink: 'Trực tuyến trên Google Meet',
          teacherOrRoom: 'Thầy Hoàng Long',
          mode: ParentScheduleMode.online,
          statusLabel: 'Sắp bắt đầu',
        ),
        ParentScheduleItem(
          startTime: '16:30',
          childName: 'Lan',
          subjectName: 'Tiếng Anh',
          locationOrLink: 'Cơ sở Phan Xích Long',
          teacherOrRoom: 'Phòng học 302',
          mode: ParentScheduleMode.offline,
          statusLabel: 'Trực tiếp',
        ),
      ];

  ParentAnalyticsData _fallbackAnalytics(FamilyScopeChild? target) {
    final name = target?.name ?? 'Minh';
    final className = target?.className ?? 'Lớp 10A1';
    return ParentAnalyticsData(
      childName: name,
      className: className,
      reportLabel: 'Báo cáo tuần 4 • Môn Ngữ Văn',
      subjectName: 'Ngữ Văn',
      progressPercent: 15,
      averageScore: 8.4,
      weeklyTrend: const [0.4, 0.55, 0.7, 0.9],
      insightText: _fallbackInsightText,
      insightHighlight: 'Đọc hiểu',
    );
  }

  static const _fallbackInsightText =
      'Cải thiện rõ ở dạng Đọc hiểu so với 3 buổi gần đây. '
      'Tốc độ làm bài trắc nghiệm nhanh hơn 22%.';
}
