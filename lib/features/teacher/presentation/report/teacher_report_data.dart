import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';

enum TeacherReportStatus {
  confirmed('Đã xác nhận'),
  pending('Chờ xác nhận'),
  needsInfo('Cần bổ sung'),
  unknown('Chưa có thông tin xác nhận');

  const TeacherReportStatus(this.label);
  final String label;

  static TeacherReportStatus fromApi(Object? value) => switch (value) {
    'confirmed' => confirmed,
    'pending' => pending,
    'needs_info' => needsInfo,
    _ => unknown,
  };
}

class TeacherReportSession {
  TeacherReportSession(this.occurrence)
    : confirmation = TeacherReportStatus.fromApi(
        occurrence.json['hour_confirmation_status'],
      ),
      minutes = _duration(
        occurrence.json['start_time'],
        occurrence.json['end_time'],
      );

  final TeacherOccurrence occurrence;
  final TeacherReportStatus confirmation;
  final int? minutes;

  static final _clock = RegExp(
    r'^([01][0-9]|2[0-3]):([0-5][0-9])(?::[0-5][0-9])?$',
  );

  static int? _minute(Object? value) {
    final match = _clock.firstMatch(value?.toString().trim() ?? '');
    return match == null
        ? null
        : int.parse(match[1]!) * 60 + int.parse(match[2]!);
  }

  static int? _duration(Object? start, Object? end) {
    final from = _minute(start);
    final to = _minute(end);
    return from != null && to != null && to > from ? to - from : null;
  }
}

class TeacherReportData {
  const TeacherReportData(this.classes, this.sessions);

  final List<TeacherClassData> classes;
  final List<TeacherReportSession> sessions;

  List<TeacherReportSession> group(
    String? classId,
    TeacherReportStatus? status,
  ) => [
    for (final row in sessions)
      if ((classId == null || row.occurrence.classId == classId) &&
          (status == null || row.confirmation == status))
        row,
  ];

  static Future<TeacherReportData> load(
    TeacherApi api,
    String? organizationId,
    DateTime month,
  ) async {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final results = await Future.wait([
      teacherAssignedClasses(api),
      api.get(
        '/me/timetable',
        query: {
          'sessions_from': month.toIso8601String().substring(0, 10),
          'sessions_to': lastDay.toIso8601String().substring(0, 10),
          if (organizationId == null)
            'scope': 'personal'
          else
            'organization_id': organizationId,
        },
      ),
    ]);
    final classes = (results[0] as List<TeacherClassData>)
        .where((row) => row.inScope(organizationId))
        .toList();
    final classesById = {for (final row in classes) row.id: row};
    final seenIds = <String>{};
    final sessions = <TeacherReportSession>[];
    for (final row in teacherList(
      teacherPayload(results[1]),
      keys: const ['entries'],
    )) {
      final id = row['session_id']?.toString();
      final date = DateTime.tryParse(row['date']?.toString() ?? '');
      final classData = classesById[row['class_id']?.toString()];
      if (row['status'] != 'completed' ||
          id == null ||
          id.isEmpty ||
          date == null ||
          date.year != month.year ||
          date.month != month.month ||
          classData == null ||
          !seenIds.add(id))
        continue;
      sessions.add(
        TeacherReportSession(
          TeacherOccurrence(json: row, date: date, classData: classData),
        ),
      );
    }
    sessions.sort((a, b) {
      final left = a.occurrence;
      final right = b.occurrence;
      final byDate = right.date.compareTo(left.date);
      if (byDate != 0) return byDate;
      final byTime = right.start.compareTo(left.start);
      return byTime != 0 ? byTime : left.sessionId!.compareTo(right.sessionId!);
    });
    return TeacherReportData(classes, sessions);
  }
}

String teacherReportDuration(int? minutes) {
  if (minutes == null) return 'Chưa có thời lượng';
  if (minutes < 60) return '$minutes phút';
  final remainder = minutes % 60;
  return '${minutes ~/ 60} giờ${remainder == 0 ? '' : ' $remainder phút'}';
}

int? teacherReportTotalMinutes(List<TeacherReportSession> sessions) {
  final values = sessions.map((row) => row.minutes).whereType<int>();
  return values.isEmpty
      ? null
      : values.fold<int>(0, (total, minutes) => total + minutes);
}

String teacherReportMonthLabel(DateTime month) =>
    'Tháng ${month.month}/${month.year}';
