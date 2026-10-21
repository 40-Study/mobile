import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/teacher_api.dart';

/// Temporary dev preview, enabled by default while the Teacher UI is reviewed.
class TeacherPreviewApi extends TeacherApi {
  TeacherPreviewApi()
    : super(dio: Dio(BaseOptions(baseUrl: 'https://preview.invalid')));

  static const enabled =
      !kReleaseMode &&
      bool.fromEnvironment(
        'TEACHER_UI_PREVIEW',
        defaultValue:
            String.fromEnvironment('ENV', defaultValue: 'dev') == 'dev',
      );
  static const _writeError = FormatException(
    'Dữ liệu mẫu chỉ dùng để xem giao diện, không lưu thay đổi.',
  );
  String get _today => DateTime.now().toIso8601String().substring(0, 10);
  String get _timestamp => '${_today}T08:00:00+07:00';

  List<Map<String, dynamic>> get _classes => [
    for (final row in [
      ('python', 'Python cơ bản · PY26A', 'Python cho người mới bắt đầu', 24),
      ('web', 'Thiết kế Web · WEB26B', 'HTML, CSS & tư duy giao diện', 18),
      ('scratch', 'Sáng tạo với Scratch · SC26', 'Lập trình qua trò chơi', 16),
    ])
      {
        'id': row.$1,
        'name': row.$2,
        'course_id': row.$1,
        'course_name': row.$3,
        'description': row.$3,
        'organization_id': null,
        'status': 'active',
        'can_manage': true,
        'can_assign_teachers': true,
        'teacher_role': 'main',
        'student_count': row.$4,
        'teacher_count': 1,
        'total_students': row.$4,
        'start_date': '2026-09-01',
        'end_date': '2026-12-31',
      },
  ];

  List<Map<String, dynamic>> get _sessions => [
    for (final row in [
      ('python', '09:00', '10:30', 'completed', 'Biến và kiểu dữ liệu'),
      ('web', '14:00', '15:30', 'in_progress', 'Xây dựng giao diện đầu tiên'),
      ('scratch', '19:00', '20:30', 'scheduled', 'Tạo trò chơi mê cung'),
    ])
      {
        'id': 'session-${row.$1}',
        'session_id': 'session-${row.$1}',
        'class_id': row.$1,
        'date': _today,
        'start_time': row.$2,
        'end_time': row.$3,
        'status': row.$4,
        'topic': row.$5,
        'room': 'Phòng học trực tuyến',
        'notes': 'Chuẩn bị học liệu trước buổi học.',
      },
  ];

  List<Map<String, dynamic>> get _courses => [
    for (final row in [
      ('python', 'Python cho người mới bắt đầu', 'published', 12, 48, 490000),
      ('web', 'Thiết kế Web từ con số 0', 'draft', 8, 0, 390000),
      (
        'scratch',
        'Lập trình sáng tạo với Scratch',
        'pending_review',
        10,
        0,
        290000,
      ),
    ])
      {
        'id': row.$1,
        'title': row.$2,
        'status': row.$3,
        'total_lessons': row.$4,
        'total_students': row.$5,
        'price': row.$6,
        'is_free': false,
        'level': 'beginner',
        'language': 'vi',
        'description':
            'Học từng bước qua ví dụ thực tế và các dự án nhỏ. Phù hợp với học viên bắt đầu hành trình lập trình.',
        'short_description':
            'Kiến thức nền tảng, bài học dễ hiểu và thực hành có hướng dẫn.',
        if (row.$1 == 'python')
          'thumbnail_asset': 'assets/images/python-course-cover.png',
        'updated_at': _timestamp,
        'min_video_pct': 80,
        'sequential': false,
      },
  ];

  List<Map<String, dynamic>> get _students => [
    for (final row in [
      ('minh', 'Nguyễn Hoàng Minh'),
      ('anh', 'Trần Ngọc Anh'),
      ('khanh', 'Lê Gia Khánh'),
    ])
      {
        'id': row.$1,
        'student_id': row.$1,
        'user_id': row.$1,
        'full_name': row.$2,
        'user_name': row.$2,
        'student_name': row.$2,
        'email': '${row.$1}@example.invalid',
        'enrolled_at': _timestamp,
      },
  ];

  dynamic _data(dynamic data) => {'data': data};
  dynamic _page(
    List<Map<String, dynamic>> items,
    String key,
    Map<String, dynamic>? query,
  ) {
    final page = int.tryParse('${query?['page']}') ?? 1;
    final size =
        (int.tryParse('${query?['page_size'] ?? query?['limit']}') ?? 20)
            .clamp(1, 100)
            .toInt();
    final start = (page - 1) * size;
    return _data({
      key: start < 0 || start >= items.length
          ? <Map<String, dynamic>>[]
          : items.skip(start).take(size).toList(),
      'total': items.length,
      'total_count': items.length,
      'page': page,
      'page_size': size,
      'total_pages': (items.length / size).ceil(),
    });
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final route = path
        .replaceFirst(RegExp(r'^/api'), '')
        .replaceFirst(RegExp(r'/$'), '');
    final parts = route.split('/').where((s) => s.isNotEmpty).toList();
    if (route == '/classes/me' || route == '/classes')
      return _page(_classes, 'classes', query);
    if (route == '/me/timetable')
      return _data({
        'entries': _sessions,
        'cancelled_occurrences': <dynamic>[],
      });
    if (route == '/courses/mine') {
      final keyword = '${query?['keyword'] ?? ''}'.toLowerCase();
      final status = '${query?['status'] ?? ''}';
      return _page(
        _courses
            .where(
              (c) =>
                  (status.isEmpty || c['status'] == status) &&
                  '${c['title']}'.toLowerCase().contains(keyword),
            )
            .toList(),
        'courses',
        query,
      );
    }
    if (parts.length >= 2 && parts.first == 'classes') {
      final detail = _classes.where((c) => c['id'] == parts[1]).firstOrNull;
      if (detail == null)
        throw const FormatException('Lớp này chưa có trong dữ liệu mẫu.');
      if (parts.length == 2) return _data(detail);
      final sessions = _sessions
          .where((s) => s['class_id'] == parts[1])
          .toList();
      if (parts[2] == 'students') return _page(_students, 'students', query);
      if (parts[2] == 'sessions')
        return parts.length == 3
            ? _page(sessions, 'data', query)
            : _data(sessions.first);
      if (parts[2] == 'teachers')
        return _data([
          {
            'teacher_id': 'preview-teacher',
            'teacher': {'id': 'preview-teacher', 'full_name': 'Nguyễn Thu'},
            'role': 'primary',
          },
        ]);
      if (parts[2] == 'schedules')
        return _data([
          {
            'id': 'weekly-${parts[1]}',
            'class_id': parts[1],
            'day_of_week': DateTime.now().weekday % 7,
            'start_time': sessions.first['start_time'],
            'end_time': sessions.first['end_time'],
            'room': 'Phòng học trực tuyến',
            'is_active': true,
          },
        ]);
      if (parts[2] == 'assignments')
        return _page(
          [
            {
              'id': 'practice-${parts[1]}',
              'title': 'Bài thực hành tuần 3',
              'description':
                  'Vận dụng kiến thức để hoàn thành một sản phẩm nhỏ.',
              'status': 'published',
              'max_score': 10,
              'due_date': '${_today}T23:00:00+07:00',
              'created_at': _timestamp,
            },
            {
              'id': 'review-${parts[1]}',
              'title': 'Ôn tập kiến thức nền tảng',
              'description': 'Củng cố nội dung đã học trước buổi tiếp theo.',
              'status': 'draft',
              'max_score': 10,
              'created_at': _timestamp,
            },
          ],
          'assignments',
          query,
        );
      if (parts[2] == 'grades')
        return _data({
          'columns': [
            {
              'id': 'practice',
              'name': 'Thực hành',
              'grade_type': 'assignment',
              'max_score': 10,
              'weight': 1,
            },
          ],
          'students': [
            for (var i = 0; i < _students.length; i++)
              {
                ..._students[i],
                'grades': [
                  {
                    'id': 'grade-$i',
                    'title': 'Thực hành',
                    'grade_type': 'assignment',
                    'score': 8 + i * .5,
                    'max_score': 10,
                    'weight': 1,
                    'feedback': 'Nắm tốt kiến thức nền tảng.',
                  },
                ],
              },
          ],
        });
      if (parts[2] == 'final-grades') return _data(<dynamic>[]);
    }
    if (parts.length >= 2 && parts.first == 'courses') {
      final course = _courses.where((c) => c['id'] == parts[1]).firstOrNull;
      if (course == null)
        throw const FormatException('Khóa học này chưa có trong dữ liệu mẫu.');
      if (parts.length == 2) return _data(course);
      if (parts[2] == 'enrollments')
        return _page(
          [
            for (var i = 0; i < _students.length; i++)
              {..._students[i], 'progress_percentage': 45 + i * 15},
          ],
          'enrollments',
          query,
        );
      if (parts[2] == 'sections')
        return _data([
          for (final section in [
            (
              'intro',
              'Bắt đầu hành trình',
              ['Làm quen với môi trường học', 'Tư duy giải quyết vấn đề'],
            ),
            (
              'foundation',
              'Kiến thức nền tảng',
              ['Thực hành từng bước', 'Các lỗi thường gặp', 'Bài tập củng cố'],
            ),
            (
              'project',
              'Dự án cuối khóa',
              ['Lên ý tưởng sản phẩm', 'Hoàn thiện và chia sẻ'],
            ),
          ])
            {
              'id': section.$1,
              'title': section.$2,
              'display_order': [
                'intro',
                'foundation',
                'project',
              ].indexOf(section.$1),
              'lessons': [
                for (var i = 0; i < section.$3.length; i++)
                  {
                    'id': i == 0 && section.$1 == 'intro'
                        ? 'intro-lesson'
                        : '${section.$1}-lesson-$i',
                    'title': section.$3[i],
                    'duration_minutes': 15 + i * 5,
                    'display_order': i,
                    'is_preview': section.$1 == 'intro' && i == 0,
                  },
              ],
            },
        ]);
    }
    if (parts.length == 3 &&
        parts.first == 'lessons' &&
        parts.last == 'contents')
      return _data([
        {
          'id': 'intro-article',
          'type': 'article',
          'title': 'Chào mừng bạn',
          'article_body':
              '<p>Cùng bắt đầu hành trình lập trình qua những bài tập nhỏ.</p>',
        },
      ]);
    if (parts.length == 3 &&
        parts.first == 'sessions' &&
        parts.last == 'attendances')
      return _data([
        for (var i = 0; i < _students.length; i++)
          {
            'student_id': _students[i]['student_id'],
            'status': i == 2 ? 'late' : 'present',
            'note': '',
          },
      ]);
    if (route == '/wallet/teacher/me')
      return _data({
        'available_balance': '3250000',
        'total_earnings': '12450000',
        'total_paid_out': '8700000',
        'pending_withdrawal': '500000',
        'min_withdrawal_amount': '100000',
        'has_open_withdrawal': true,
        'bank_name': 'Vietcombank',
        'bank_account_name': 'NGUYEN THU',
        'bank_account_number': '0123456789',
      });
    if (route == '/wallet/teacher/transactions')
      return _page(
        [
          {
            'id': 'income-python',
            'amount': '490000',
            'course_name': 'Python cho người mới bắt đầu',
            'status': 'completed',
            'type': 'income',
            'created_at': _timestamp,
            'order_number': 'PREVIEW-1024',
            'buyer_name': 'Nguyễn Hoàng Minh',
          },
        ],
        'transactions',
        query,
      );
    if (route == '/wallet/teacher/withdrawals')
      return _page(
        [
          {
            'id': 'withdraw-preview',
            'amount': '500000',
            'status': 'pending',
            'created_at': _timestamp,
            'bank_name': 'Vietcombank',
            'bank_account_name': 'NGUYEN THU',
            'bank_account_number': '0123456789',
          },
        ],
        'items',
        query,
      );
    if (route == '/teacher-profiles/me')
      return _data({
        'id': 'preview-teacher',
        'status': 'approved',
        'approval_status': 'approved',
        'headline': 'Giảng viên lập trình',
        'bio': 'Đồng hành cùng học viên qua những dự án nhỏ.',
        'teaching_experience': 5,
        'specializations': <String>[],
        'specialization': 'Lập trình & công nghệ',
        'education': 'Cử nhân Công nghệ thông tin',
        'experience_years': 5,
        'department': 'Khoa học máy tính',
        'certificate_info': 'Chứng chỉ giảng dạy lập trình',
      });
    if (route == '/conversations')
      return _page(
        [
          {
            'id': 'class-python',
            'name': 'Lớp Python · Trao đổi học tập',
            'unread_count': 2,
            'last_message': {
              'content': 'Cô ơi, em đã hoàn thành bài thực hành rồi ạ.',
            },
          },
        ],
        'conversations',
        query,
      );
    if (route == '/categories')
      return _data([
        {'id': 'programming', 'name': 'Lập trình'},
      ]);
    if (route == '/tags')
      return _page(
        [
          {'id': 'beginner', 'name': 'Cho người mới'},
        ],
        'tags',
        query,
      );
    if (route == '/reminders/settings')
      return _data([
        {
          'event_type': 'class_session',
          'remind_before_minutes': 15,
          'channels': ['push'],
          'is_enabled': true,
        },
      ]);
    if (route == '/me/permissions')
      return _data({
        'permissions': ['COURSES_UPDATE_OWN', 'COURSES_CREATE'],
      });
    throw FormatException(
      'Màn này chưa có dữ liệu mẫu ($route). Không kết nối máy chủ thật trong chế độ xem thử.',
    );
  }

  @override
  Future<dynamic> post(String path, {dynamic data}) async => throw _writeError;
  @override
  Future<dynamic> put(String path, {dynamic data}) async => throw _writeError;
  @override
  Future<dynamic> patch(String path, {dynamic data}) async => throw _writeError;
  @override
  Future<dynamic> delete(String path, {dynamic data}) async =>
      throw _writeError;
}
