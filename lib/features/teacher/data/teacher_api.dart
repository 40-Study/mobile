import 'package:dio/dio.dart';
import 'package:study/di/di_container.dart';

/// Reuses the application's authenticated Dio and token-refresh lifecycle.
class TeacherApi {
  TeacherApi({Dio? dio}) : dio = dio ?? diContainer<Dio>();
  final Dio dio;

  String _path(String path) => path.startsWith('/api/')
      ? path
      : '/api${path.startsWith('/') ? path : '/$path'}';

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async =>
      (await dio.get<dynamic>(_path(path), queryParameters: query)).data;
  Future<dynamic> post(String path, {dynamic data}) async =>
      (await dio.post<dynamic>(_path(path), data: data)).data;
  Future<dynamic> put(String path, {dynamic data}) async =>
      (await dio.put<dynamic>(_path(path), data: data)).data;
  Future<dynamic> patch(String path, {dynamic data}) async =>
      (await dio.patch<dynamic>(_path(path), data: data)).data;
  Future<dynamic> delete(String path, {dynamic data}) async =>
      (await dio.delete<dynamic>(_path(path), data: data)).data;
}

Map<String, dynamic> teacherMap(dynamic value) {
  if (value is! Map) return <String, dynamic>{};
  final map = Map<String, dynamic>.from(value);
  if (map['data'] is Map && !map.containsKey('id')) {
    return Map<String, dynamic>.from(map['data'] as Map);
  }
  return map;
}

List<Map<String, dynamic>> teacherList(
  dynamic value, {
  List<String> keys = const [],
}) {
  if (value is List)
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  if (value is! Map) return [];
  for (final key in [...keys, 'data', 'items']) {
    final child = value[key];
    if (child is List) return teacherList(child);
    if (child is Map) {
      final result = teacherList(child, keys: keys);
      if (result.isNotEmpty) return result;
    }
  }
  return [];
}

String teacherErrorMessage(Object error) {
  if (error is DioException) {
    final body = error.response?.data;
    if (body is Map) {
      final detail = body['error'];
      final message = body['message'];
      if (detail is String &&
          detail.isNotEmpty &&
          (error.response?.statusCode ?? 500) < 500)
        return detail;
      if (message is String &&
          message.isNotEmpty &&
          (error.response?.statusCode ?? 500) < 500)
        return message;
    }
    if ([
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ].contains(error.type)) {
      return 'Kết nối quá thời gian. Kiểm tra dữ liệu đã lưu trước khi thử lại.';
    }
    return switch (error.response?.statusCode) {
      401 => 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      403 => 'Bạn không có quyền thực hiện thao tác này.',
      404 => 'Nội dung không còn khả dụng hoặc bạn không có quyền xem.',
      409 => 'Trạng thái đã thay đổi. Tải lại dữ liệu trước khi tiếp tục.',
      _ => 'Chưa kết nối được máy chủ. Vui lòng thử lại.',
    };
  }
  if (error is FormatException) return error.message;
  return 'Chưa thực hiện được thao tác. Vui lòng thử lại.';
}
