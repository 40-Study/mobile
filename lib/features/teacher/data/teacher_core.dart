import 'package:study/features/teacher/data/teacher_api.dart';

String teacherDate(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String teacherTime(dynamic value) {
  final text = value?.toString() ?? '';
  return text.length >= 5 ? text.substring(0, 5) : text;
}

Map<String, dynamic> teacherPayload(dynamic value) {
  final map = teacherMap(value);
  return map['data'] is Map ? teacherMap(map['data']) : map;
}

class TeacherClassData {
  TeacherClassData(this.json);
  final Map<String, dynamic> json;
  String get id => json['id']?.toString() ?? '';
  String get name => json['name']?.toString() ?? 'Lớp học';
  String? get organizationId => json['organization_id']?.toString();
  bool get archived => json['status'] == 'archived';
  bool get canManage => json['can_manage'] == true && !archived;
  bool get canAssignTeachers =>
      json['can_assign_teachers'] == true && !archived;
  bool inScope(String? organizationId) => this.organizationId == organizationId;
}

Future<List<TeacherClassData>> teacherAssignedClasses(TeacherApi api) async {
  final response = await api.get('/classes/me');
  return teacherList(
    response,
    keys: const ['classes'],
  ).map((row) => TeacherClassData(teacherMap(row))).toList();
}

/// These APIs paginate inside data. Fetch every page before scoping or editing
/// attendance so an unloaded student is never mistaken for an absent student.
Future<List<Map<String, dynamic>>> teacherAllPages(
  TeacherApi api,
  String path,
  String key,
) async {
  final result = <Map<String, dynamic>>[];
  for (var page = 1; ; page++) {
    final payload = teacherPayload(
      await api.get(path, query: {'page': page, 'page_size': 100}),
    );
    final rows = teacherList(payload, keys: [key]);
    result.addAll(rows.map(teacherMap));
    final total = payload['total'];
    if (rows.isEmpty ||
        (total is num && result.length >= total) ||
        (total == null && rows.length < 100)) {
      break;
    }
  }
  return result;
}

class TeacherOccurrence {
  TeacherOccurrence({
    required this.json,
    required this.date,
    required this.classData,
  });
  final Map<String, dynamic> json;
  final DateTime date;
  final TeacherClassData classData;
  String? get sessionId => json['session_id']?.toString();
  String get classId => classData.id;
  String get topic => json['topic']?.toString() ?? '';
  String get start => teacherTime(json['start_time']);
  String get end => teacherTime(json['end_time']);
  String get status => json['status']?.toString() ?? 'scheduled';
  bool get projected => sessionId == null;
}

/// Materialize weekly schedules without duplicating generated or cancelled
/// occurrences. Dates and HH:mm are local wall-clock values, not UTC instants.
List<TeacherOccurrence> teacherOccurrences({
  required Map<String, dynamic> timetable,
  required List<TeacherClassData> classes,
  required DateTime from,
  required DateTime to,
}) {
  final byId = {for (final c in classes) c.id: c};
  final rows = teacherList(
    timetable,
    keys: const ['entries'],
  ).map(teacherMap).toList();
  final cancelled = teacherList(
    timetable,
    keys: const ['cancelled_occurrences'],
  ).map(teacherMap);
  final excluded = <String>{
    for (final row in cancelled) '${row['schedule_id']}/${row['date']}',
    for (final row in rows)
      if (row['session_id'] != null && row['schedule_id'] != null)
        '${row['schedule_id']}/${row['date']}',
  };
  final result = <TeacherOccurrence>[];
  for (final row in rows) {
    final classData = byId[row['class_id']];
    if (classData == null || row['status'] == 'cancelled') continue;
    final rawDate = row['date']?.toString();
    if (rawDate != null) {
      final date = DateTime.tryParse(rawDate);
      if (date != null && !date.isBefore(from) && !date.isAfter(to)) {
        result.add(
          TeacherOccurrence(json: row, date: date, classData: classData),
        );
      }
      continue;
    }
    final effectiveFrom = DateTime.tryParse('${row['effective_from']}');
    final effectiveUntil = DateTime.tryParse('${row['effective_until']}');
    for (
      var day = from;
      !day.isAfter(to);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      if (day.weekday % 7 != row['day_of_week'] ||
          (effectiveFrom != null && day.isBefore(effectiveFrom)) ||
          (effectiveUntil != null && day.isAfter(effectiveUntil)) ||
          excluded.contains('${row['schedule_id']}/${teacherDate(day)}')) {
        continue;
      }
      result.add(TeacherOccurrence(json: row, date: day, classData: classData));
    }
  }
  result.sort((a, b) {
    final date = a.date.compareTo(b.date);
    return date != 0 ? date : a.start.compareTo(b.start);
  });
  return result;
}

Future<List<TeacherOccurrence>> teacherLoadTimetable(
  TeacherApi api,
  String? organizationId,
  DateTime from,
  DateTime to,
) async {
  final classes = await teacherAssignedClasses(api);
  final raw = teacherPayload(
    await api.get(
      '/me/timetable',
      query: {
        'sessions_from': teacherDate(from),
        'sessions_to': teacherDate(to),
      },
    ),
  );
  final ids = {for (final c in classes) c.id};
  if (teacherList(
    raw,
    keys: const ['entries'],
  ).map(teacherMap).any((row) => !ids.contains(row['class_id']))) {
    throw StateError(
      'Chưa xác định được phạm vi của lịch dạy. Vui lòng tải lại.',
    );
  }
  return teacherOccurrences(
    timetable: raw,
    classes: classes.where((c) => c.inScope(organizationId)).toList(),
    from: from,
    to: to,
  );
}

String teacherStatus(dynamic value) => switch (value) {
  'scheduled' => 'Đã lên lịch',
  'in_progress' => 'Đang diễn ra',
  'completed' => 'Hoàn thành',
  'cancelled' => 'Đã hủy',
  'draft' => 'Nháp',
  'active' => 'Đang hoạt động',
  'archived' => 'Đã lưu trữ',
  'pending' => 'Chờ duyệt',
  'approved' => 'Đã duyệt',
  'rejected' => 'Bị từ chối',
  _ => value?.toString() ?? '',
};
