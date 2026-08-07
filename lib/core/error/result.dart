import 'package:study/core/error/failures.dart';

sealed class Result<T, E> {
  const Result();

  const factory Result.success(T value) = Success<T, E>;

  const factory Result.failure(E error) = FailureResult<T, E>;

  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  });

  Result<R, E> map<R>(R Function(T value) transform);

  Result<T, R> mapFailure<R>(R Function(E error) transform);

  T? get valueOrNull;

  E? get errorOrNull;

  bool get isSuccess;

  bool get isFailure;
}

final class Success<T, E> extends Result<T, E> {
  const Success(this.value);

  final T value;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) {
    return success(value);
  }

  @override
  Result<R, E> map<R>(R Function(T value) transform) {
    return Result.success(transform(value));
  }

  @override
  Result<T, R> mapFailure<R>(R Function(E error) transform) {
    return Result.success(value);
  }

  @override
  T? get valueOrNull => value;

  @override
  E? get errorOrNull => null;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;
}

final class FailureResult<T, E> extends Result<T, E> {
  const FailureResult(this.error);

  final E error;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) {
    return failure(error);
  }

  @override
  Result<R, E> map<R>(R Function(T value) transform) {
    return Result.failure(error);
  }

  @override
  Result<T, R> mapFailure<R>(R Function(E error) transform) {
    return Result.failure(transform(error));
  }

  @override
  T? get valueOrNull => null;

  @override
  E? get errorOrNull => error;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;
}

typedef ApiResult<T> = Result<T, Failure>;
