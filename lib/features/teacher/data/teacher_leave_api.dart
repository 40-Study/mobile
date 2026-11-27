import 'package:dio/dio.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';

/// Uses the real timetable and switches only the leave workflow to local data
/// when the dev server explicitly indicates that the leave route is missing.
class TeacherLeaveApi extends TeacherApi {
  TeacherLeaveApi(this.backend) : super(dio: backend.dio);

  final TeacherApi backend;
  final _requests = <Map<String, dynamic>>[];
  bool simulated = false;
  static const _path = '/me/leave-requests';

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    if (path != _path || !simulated) {
      try {
        return await backend.get(path, query: query);
      } on DioException catch (error) {
        if (path != _path ||
            !teacherDevSamplesEnabled ||
            !const [404, 405, 501].contains(error.response?.statusCode)) {
          rethrow;
        }
        simulated = true;
        final now = DateTime.now();
        final date = teacherDate(now.add(const Duration(days: 3)));
        _requests.add({
          'id': 'sample-leave',
          'from_date': date,
          'to_date': date,
          'reason': 'Ví dụ đơn xin nghỉ cá nhân',
          'status': 'pending',
          'created_at': now.toIso8601String(),
        });
      }
    }
    final page = query?['page'] as int? ?? 1;
    final size = query?['page_size'] as int? ?? 100;
    return {
      'data': {
        'leave_requests': _requests.skip((page - 1) * size).take(size).toList(),
        'total': _requests.length,
      },
    };
  }

  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    if (!simulated) return backend.post(path, data: data);
    if (path == _path) {
      final now = DateTime.now();
      final request = {
        ...teacherMap(data),
        'id': 'sample-${now.microsecondsSinceEpoch}',
        'status': 'pending',
        'created_at': now.toIso8601String(),
      };
      _requests.insert(0, request);
      return {'data': request};
    }
    for (final request in _requests) {
      if (path == '$_path/${request['id']}/withdraw' &&
          request['status'] == 'pending') {
        request['status'] = 'withdrawn';
        return {'data': request};
      }
    }
    if (path.startsWith('$_path/')) {
      throw const FormatException(
        'Đơn mẫu này không còn ở trạng thái chờ duyệt.',
      );
    }
    return backend.post(path, data: data);
  }
}

bool teacherUsingSampleLeave(TeacherApi api) =>
    api is TeacherLeaveApi && api.simulated;
