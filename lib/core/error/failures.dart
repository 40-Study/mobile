import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure({this.message, this.code});

  final String? message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([String? message])
    : super(message: message ?? 'Không có kết nối mạng');
}

final class ServerFailure extends Failure {
  const ServerFailure({
    super.message,
    super.code,
    this.statusCode,
    this.errors,
  });

  final int? statusCode;
  final List<ValidationError>? errors;

  @override
  List<Object?> get props => [message, code, statusCode, errors];
}

final class ValidationError extends Equatable {
  const ValidationError({required this.field, required this.message});

  final String field;
  final String message;

  @override
  List<Object?> get props => [field, message];
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super(message: 'Phiên đăng nhập hết hạn');
}

final class CacheFailure extends Failure {
  const CacheFailure([String? message]) : super(message: message);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([String? message])
    : super(message: message ?? 'Đã có lỗi xảy ra');
}
