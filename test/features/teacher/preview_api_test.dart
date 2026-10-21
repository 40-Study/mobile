import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';

void main() {
  test('preview reads through the real timetable and course filters', () async {
    final api = TeacherPreviewApi();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rows = await teacherLoadTimetable(api, null, today, today);
    expect(rows, hasLength(3));
    expect(
      await teacherAllPages(api, '/classes/python/sessions', 'data'),
      hasLength(1),
    );
    expect(rows.map((row) => row.status), [
      'completed',
      'in_progress',
      'scheduled',
    ]);
    final courses = teacherMap(
      await api.get(
        '/courses/mine',
        query: {'keyword': 'Python', 'status': 'published'},
      ),
    );
    expect(teacherList(courses, keys: ['courses']), hasLength(1));
    final empty = teacherMap(
      await api.get('/courses/mine', query: {'keyword': 'không tìm thấy'}),
    );
    expect(teacherList(empty, keys: ['courses']), isEmpty);
  });

  test(
    'preview never reports successful writes or falls back to the real API',
    () async {
      final api = TeacherPreviewApi();
      var networkCalls = 0;
      api.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            networkCalls++;
            handler.reject(DioException(requestOptions: options));
          },
        ),
      );
      for (final action in [
        () => api.post('/wallet/teacher/withdrawals', data: {'amount': 100000}),
        () => api.put('/classes/python'),
        () => api.patch('/courses/python'),
        () => api.delete('/classes/python'),
        () => api.get('/not-a-preview-route'),
      ]) {
        await expectLater(action(), throwsFormatException);
      }
      expect(networkCalls, 0);
    },
  );
}
