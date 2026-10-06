import 'package:flutter_test/flutter_test.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';

void main() {
  group('Result', () {
    test('maps success and preserves failure', () {
      const ApiResult<int> success = Result.success(4);
      const ApiResult<int> failure = Result.failure(NetworkFailure());

      expect(success.map((value) => value * 2).valueOrNull, 8);
      expect(success.mapFailure((error) => error.message).valueOrNull, 4);
      expect(
        failure.map((value) => value * 2),
        isA<FailureResult<int, Failure>>(),
      );
      expect(
        failure.mapFailure((error) => error.message).errorOrNull,
        'Không có kết nối mạng',
      );
    });

    test('exposes exactly one side and dispatches to the matching branch', () {
      const Result<String, Failure> success = Result.success('ok');
      const Result<String, Failure> failure = Result.failure(
        UnauthorizedFailure(),
      );

      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.valueOrNull, 'ok');
      expect(success.errorOrNull, isNull);
      expect(
        success.when(success: (value) => value, failure: (_) => 'wrong'),
        'ok',
      );
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
      expect(failure.valueOrNull, isNull);
      expect(failure.errorOrNull, isA<UnauthorizedFailure>());
      expect(
        failure.when(
          success: (_) => 'wrong',
          failure: (error) => error.message,
        ),
        'Phiên đăng nhập hết hạn',
      );
    });
  });
}
