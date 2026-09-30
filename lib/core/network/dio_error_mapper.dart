import 'package:dio/dio.dart';
import 'package:study/core/error/failures.dart';

abstract final class DioErrorMapper {
  static Failure map(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Kết nối quá chậm, vui lòng thử lại');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Không thể kết nối đến server');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Chứng chỉ kết nối không hợp lệ');
      case DioExceptionType.badResponse:
        return _mapResponse(error.response);
      case DioExceptionType.cancel:
        return const UnknownFailure('Request đã bị hủy');
      case DioExceptionType.unknown:
        return UnknownFailure(error.message);
    }
  }

  static Failure _mapResponse(Response<dynamic>? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;
    final parsed = _parseErrorBody(data);

    return switch (statusCode) {
      401 => const UnauthorizedFailure(),
      403 => ServerFailure(
        message: parsed.message ?? 'Bạn không có quyền thực hiện hành động này',
        code: parsed.code,
        statusCode: statusCode,
        errors: parsed.errors,
      ),
      404 => ServerFailure(
        message: parsed.message ?? 'Không tìm thấy dữ liệu',
        code: parsed.code,
        statusCode: statusCode,
        errors: parsed.errors,
      ),
      422 => ServerFailure(
        message: parsed.message ?? 'Dữ liệu không hợp lệ',
        code: parsed.code,
        statusCode: statusCode,
        errors: parsed.errors,
      ),
      >= 500 => ServerFailure(
        message: parsed.message ?? 'Lỗi server, vui lòng thử lại sau',
        code: parsed.code,
        statusCode: statusCode,
        errors: parsed.errors,
      ),
      _ => ServerFailure(
        message: parsed.message ?? 'Đã có lỗi xảy ra',
        code: parsed.code,
        statusCode: statusCode,
        errors: parsed.errors,
      ),
    };
  }

  static _ParsedErrorBody _parseErrorBody(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return const _ParsedErrorBody();
    }

    final message = _firstString(data['error'], data['message']);
    final code = data['code'] is String ? data['code'] as String : null;
    final errors = _parseValidationErrors(data['errors']);

    return _ParsedErrorBody(message: message, code: code, errors: errors);
  }

  static List<ValidationError>? _parseValidationErrors(dynamic errors) {
    if (errors is! List || errors.isEmpty) return null;

    return errors.map((error) {
      if (error is Map<String, dynamic>) {
        return ValidationError(
          field: _firstString(error['field'], error['param']) ?? '',
          message:
              _firstString(error['error'], error['message']) ??
              'Validation error',
        );
      }

      return ValidationError(field: '', message: error.toString());
    }).toList();
  }

  static String? _firstString(Object? first, Object? second) {
    if (first is String && first.isNotEmpty) return first;
    if (second is String && second.isNotEmpty) return second;
    return null;
  }
}

final class _ParsedErrorBody {
  const _ParsedErrorBody({this.message, this.code, this.errors});

  final String? message;
  final String? code;
  final List<ValidationError>? errors;
}
