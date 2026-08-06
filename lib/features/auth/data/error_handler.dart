import 'package:dio/dio.dart';
import 'package:study/core/error/failures.dart';

/// Centralized error extraction from DioException.
/// Used by all auth blocs/cubits to maintain consistent error handling.
class AuthErrorHandler {
  const AuthErrorHandler._();

  /// Extracts user-friendly error message from DioException.
  ///
  /// Checks for:
  /// 1. Validation errors array (from API)
  /// 2. Message field
  /// 3. Error field
  /// 4. Falls back to DioException message
  static String extractMessage(DioException e) {
    final failure = e.error;
    if (failure is Failure) {
      return _failureMessage(failure);
    }

    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      // Check for validation errors array
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first;
        if (firstError is Map<String, dynamic>) {
          return firstError['error'] as String? ??
              firstError['message'] as String? ??
              'Validation error';
        }
        if (firstError is String) return firstError;
      }

      // Prefer the specific backend error over the generic response message.
      final message = data['error'] ?? data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    // Fallback to DioException message or default
    return e.message ?? 'Đã có lỗi xảy ra';
  }

  static String _failureMessage(Failure failure) {
    if (failure is ServerFailure) {
      final errors = failure.errors;
      if (errors != null && errors.isNotEmpty) {
        return errors.first.message;
      }
    }

    return failure.message ?? 'Đã có lỗi xảy ra';
  }

  /// Extracts error message with custom default.
  static String extractMessageOr(DioException e, String defaultMessage) {
    final message = extractMessage(e);
    return message.isEmpty ? defaultMessage : message;
  }
}
