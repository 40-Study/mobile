import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:study/features/teacher/data/teacher_api.dart';

/// Storage requests deliberately use a separate client, without auth interceptors.
class TeacherVideoUploadController extends ChangeNotifier {
  TeacherVideoUploadController({required this.api, Dio? storageClient})
    : storageClient = storageClient ?? Dio();
  final TeacherApi api;
  final Dio storageClient;
  Map<String, dynamic>? session;
  Map<String, dynamic>? result;
  bool busy = false;
  double progress = 0;
  Object? error;
  CancelToken? _cancel;
  bool _disposed = false;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> upload({
    required File file,
    required String fileName,
    required String resourceId,
    String? resumeId,
  }) async {
    if (busy) return;
    busy = true;
    error = null;
    result = null;
    _cancel = CancelToken();
    _notify();
    try {
      final size = await file.length();
      final ext = fileName.split('.').last.toLowerCase();
      final contentType = switch (ext) {
        'mov' => 'video/quicktime',
        'webm' => 'video/webm',
        'm4v' => 'video/x-m4v',
        _ => 'video/mp4',
      };
      if (resumeId != null) {
        session = teacherMap(await api.get('/videos/upload/$resumeId/resume'));
        if (session!['can_resume'] != true ||
            session!['file_name'] != fileName ||
            session!['file_size'] != size) {
          throw const FormatException(
            'Cần chọn lại đúng video gốc (tên và dung lượng trùng khớp).',
          );
        }
      } else {
        session = teacherMap(
          await api.post(
            '/videos/upload/init',
            data: {
              'resource_id': resourceId,
              'resource_type': 'course',
              'original_file_name': fileName,
              'content_type': contentType,
              'file_size': size,
            },
          ),
        );
      }
      final id = '${session!['upload_id']}';
      final chunkSize = (session!['chunk_size'] as num?)?.toInt() ?? 0;
      final total = (session!['total_chunks'] as num?)?.toInt() ?? 0;
      if (chunkSize <= 0 || total <= 0 || id == 'null')
        throw const FormatException('Phiên tải video không hợp lệ.');
      final completed = (session!['completed_chunks'] as List? ?? [])
          .whereType<num>()
          .map((e) => e.toInt())
          .toSet();
      for (var chunk = 1; chunk <= total; chunk++) {
        if (_cancel!.isCancelled) break;
        if (completed.contains(chunk)) continue;
        final urls = teacherMap(
          await api.post(
            '/videos/upload/presigned-urls',
            data: {
              'upload_id': id,
              'chunk_numbers': [chunk],
            },
          ),
        );
        final entry = teacherList(urls, keys: const ['urls']).first;
        final url = Uri.parse('${entry['url']}');
        if (!['http', 'https'].contains(url.scheme))
          throw const FormatException('Địa chỉ lưu trữ không hợp lệ.');
        final start = (chunk - 1) * chunkSize;
        final end = (start + chunkSize).clamp(0, size);
        final response = await storageClient.put<dynamic>(
          url.toString(),
          data: file.openRead(start, end),
          cancelToken: _cancel,
          options: Options(
            headers: {
              HttpHeaders.contentLengthHeader: end - start,
              HttpHeaders.contentTypeHeader: contentType,
            },
          ),
          onSendProgress: (sent, _) {
            progress = ((completed.length + sent / (end - start)) / total)
                .clamp(0, 1);
            _notify();
          },
        );
        final etag = response.headers.value('etag');
        if (etag == null || etag.isEmpty)
          throw const FormatException(
            'Máy chủ lưu trữ chưa xác nhận phần video. Có thể tiếp tục phiên này.',
          );
        await api.post(
          '/videos/upload/chunk-complete',
          data: {
            'upload_id': id,
            'chunk_number': chunk,
            'etag': etag,
            'size': end - start,
          },
        );
        completed.add(chunk);
        progress = completed.length / total;
        _notify();
      }
      if (!_cancel!.isCancelled) {
        result = teacherMap(
          await api.post('/videos/upload/complete', data: {'upload_id': id}),
        );
      }
    } catch (e) {
      if (e is! DioException || e.type != DioExceptionType.cancel) error = e;
    } finally {
      busy = false;
      _notify();
    }
  }

  void pause() {
    _cancel?.cancel('paused');
  }

  Future<void> abort() async {
    pause();
    if (busy) return;
    final id = session?['upload_id'];
    if (id == null) return;
    await api.delete('/videos/upload/$id');
    session = null;
    result = null;
    progress = 0;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    pause();
    storageClient.close();
    super.dispose();
  }
}
