import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_workplace_controller.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_advanced_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_contests_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_discussions_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_room_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_sessions_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_messages_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_video_upload_screen.dart';

import 'teacher_phase_b_fixtures.dart';
import 'teacher_phase_c_fixtures.dart';
import 'teacher_phase_d_fixtures.dart';

class _Storage extends Mock implements AuthStorage {}

class _Auth extends Mock implements AuthRepository {}

class TeacherFixtureWorkplace extends TeacherWorkplaceController {
  TeacherFixtureWorkplace(TeacherApi api)
    : super(api: api, storage: _Storage(), authRepository: _Auth());
  @override
  Future<void> initialize() async {
    initialized = true;
    error = null;
    notifyListeners();
  }
}

/// Strict in-memory API for rendering. Unexpected writes fail instead of
/// producing success-looking fixtures.
class TeacherFixtureApi extends TeacherApi {
  TeacherFixtureApi()
    : super(dio: Dio(BaseOptions(baseUrl: 'https://fixture.invalid')));
  final gradeColumns = <Map<String, dynamic>>[
    {
      'id': 'grade-column',
      'name': 'Bài tập tuần 1',
      'grade_type': 'assignment',
      'max_score': 10,
      'weight': 1,
    },
  ];
  final classData = <String, dynamic>{
    'id': 'teacher-class',
    'name': 'Toán tư duy · Lớp 6',
    'status': 'active',
    'can_manage': true,
    'can_assign_teachers': true,
    'organization_id': null,
  };
  final course = <String, dynamic>{
    'id': 'course',
    'title': 'Toán tư duy cho học sinh lớp 6',
    'status': 'draft',
    'price': 150000,
    'description': 'Cùng khám phá cách giải bài toán qua ví dụ gần gũi.',
    'level': 'beginner',
    'language': 'vi',
    'total_lessons': 2,
    'total_students': 12,
  };
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    dynamic data;
    if (path == '/classes/me' || path == '/classes') {
      data = {
        'classes': [classData],
        'total': 1,
      };
    } else if (path == '/classes/teacher-class') {
      data = classData;
    } else if (path == '/me/timetable') {
      data = {
        'entries': [
          {
            'class_id': 'teacher-class',
            'session_id': 'teacher-session',
            'date': teacherDate(DateTime.now()),
            'start_time': '23:00',
            'end_time': '23:45',
            'status': 'scheduled',
            'topic': 'Phân số và ứng dụng',
          },
        ],
        'cancelled_occurrences': <dynamic>[],
      };
    } else if (path.endsWith('/students') || path == '/teachers/me/students') {
      data = {
        'students': [
          {
            'id': 'student',
            'student_id': 'student',
            'full_name': 'Nguyễn Minh An',
            'name': 'Nguyễn Minh An',
            'user_name': 'minhan',
            'class_name': classData['name'],
          },
        ],
        'total': 1,
      };
    } else if (path.endsWith('/sessions/teacher-session')) {
      data = {
        'id': 'teacher-session',
        'class_id': 'teacher-class',
        'date': teacherDate(DateTime.now()),
        'start_time': '23:00',
        'end_time': '23:45',
        'topic': 'Phân số và ứng dụng',
        'status': 'scheduled',
      };
    } else if (path.endsWith('/sessions')) {
      data = {'data': <dynamic>[], 'total': 0};
    } else if (path.endsWith('/timetable')) {
      data = {'entries': <dynamic>[], 'cancelled_occurrences': <dynamic>[]};
    } else if (path == '/courses/mine') {
      data = {
        'courses': [course],
        'total': 1,
      };
    } else if (path == '/courses/course') {
      data = course;
    } else if (path.contains('/sections')) {
      data = [
        {
          'id': 'section',
          'title': 'Bắt đầu học toán tư duy',
          'lessons': <dynamic>[],
        },
      ];
    } else if (path == '/teacher-profiles/me') {
      data = {
        'id': 'profile',
        'approval_status': 'pending',
        'headline': 'Giáo viên Toán',
        'bio': 'Đồng hành cùng học sinh xây dựng tư duy toán học.',
        'teaching_experience': 3,
        'specializations': <String>[],
      };
    } else if (path == '/wallet/teacher/me') {
      data = {
        'available_balance': '1500000',
        'total_earnings': '2500000',
        'total_paid_out': '1000000',
        'pending_withdrawal': '0',
        'min_withdrawal_amount': '100000',
        'has_open_withdrawal': false,
        'bank_name': 'Vietcombank',
        'bank_account_number': '0123456789',
        'bank_account_name': 'NGUYEN THU',
      };
    } else if (path.endsWith('/grades')) {
      data = {
        'columns': gradeColumns,
        'students': [
          {
            'student_id': 'student',
            'student_name': 'Nguyễn Minh An',
            'grades': [
              {
                'id': 'grade',
                'title': 'Bài tập tuần 1',
                'grade_type': 'assignment',
                'score': 8,
                'max_score': 10,
                'weight': 1,
                'feedback': 'Nắm tốt cách so sánh phân số.',
                'graded_by_name': 'Nguyễn Thu',
                'graded_at': '2026-10-17T07:00:00Z',
              },
            ],
          },
          {
            'student_id': 'student-2',
            'student_name': 'Trần Bảo Ngọc',
            'grades': <dynamic>[],
          },
        ],
      };
    } else if (path.endsWith('/grade-columns')) {
      data = gradeColumns;
    } else if (path == '/conversations') {
      data = {
        'conversations': [
          {
            'id': 'conversation',
            'name': 'Nguyễn Minh An',
            'last_message': {'content': 'Em đã làm xong bài tập rồi ạ.'},
            'unread_count': 1,
          },
        ],
        'total_count': 1,
      };
    } else if (path == '/conversations/conversation') {
      data = {'id': 'conversation', 'is_blocked': false};
    } else if (path.endsWith('/messages')) {
      data = {'messages': <dynamic>[], 'total_count': 0};
    } else if (path == '/discussions') {
      data = {
        'posts': [
          {
            'id': 'discussion',
            'slug': 'phan-so',
            'title': 'Cách hướng dẫn học sinh so sánh phân số?',
            'author_name': 'Minh An',
            'reply_count': 2,
          },
        ],
        'total': 1,
      };
    } else if (path == '/discussions/phan-so') {
      data = {
        'id': 'discussion',
        'title': 'Cách so sánh phân số?',
        'content': 'Em cần gợi ý khi hai phân số có mẫu số khác nhau.',
        'author_name': 'Minh An',
        'comments': <dynamic>[],
      };
    } else if (path == '/livestream') {
      data = {
        'data': [
          {
            'id': 'live',
            'title': 'Ôn tập phân số',
            'class_id': 'teacher-class',
            'status': 'scheduled',
          },
        ],
        'total': 1,
      };
    } else if (path == '/livestream/live') {
      data = {
        'id': 'live',
        'title': 'Ôn tập phân số',
        'status': 'scheduled',
        'host_id': 'fixture-user',
      };
    } else if (path == '/contests/manage') {
      data = {
        'items': [
          {
            'id': 'contest',
            'title': 'Thử thách Toán tháng 10',
            'status': 'DRAFT',
            'participant_count': 0,
          },
        ],
        'total_count': 1,
      };
    } else if (path == '/contests/manage/contest') {
      data = {
        'id': 'contest',
        'title': 'Thử thách Toán tháng 10',
        'status': 'DRAFT',
        'duration_minutes': 30,
        'question_count': 10,
      };
    } else {
      data = <dynamic>[];
    }
    return {'data': data};
  }

  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    if (path.endsWith('/read')) return {'data': true};
    throw StateError('Unexpected fixture write: $path');
  }
}

List<Widget> createTeacherScreenFixtures() {
  final api = TeacherFixtureApi();
  return [
    ...createTeacherPhaseBFixtures(api, TeacherFixtureWorkplace(api)),
    ...createTeacherPhaseCFixtures(api),
    ...createTeacherPhaseDFixtures(api),
    TeacherAdvancedScreen(api: api),
    TeacherVideoUploadScreen(api: api, courseId: 'course'),
    TeacherMessagesScreen(api: api),
    TeacherContactPickerScreen(api: api),
    TeacherConversationScreen(
      api: api,
      conversationId: 'conversation',
      realtime: false,
    ),
    TeacherDiscussionsScreen(api: api),
    TeacherDiscussionScreen(api: api, slug: 'phan-so'),
    TeacherContestsScreen(api: api),
    TeacherContestScreen(api: api, contestId: 'contest'),
    TeacherLiveSessionsScreen(api: api),
    TeacherLiveSessionScreen(api: api, sessionId: 'live'),
    TeacherLiveRoomScreen(
      api: api,
      sessionId: 'live',
      joinData: const {'role': 'teacher'},
    ),
    TeacherLiveParticipantsScreen(api: api, sessionId: 'live', canManage: true),
  ];
}
