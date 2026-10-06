import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/network/dio_error_mapper.dart';

void main() {
  group('DioErrorMapper', () {
    test('maps transport errors without a response', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          DioErrorMapper.map(
            DioException(requestOptions: RequestOptions(), type: type),
          ),
          isA<NetworkFailure>(),
        );
      }
      expect(
        DioErrorMapper.map(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        ),
        isA<NetworkFailure>(),
      );
      expect(
        DioErrorMapper.map(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.cancel,
          ),
        ),
        isA<UnknownFailure>(),
      );
    });

    test('maps auth and validation response edge cases', () {
      Failure mapResponse(int status, Object? body) => DioErrorMapper.map(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: RequestOptions(),
            statusCode: status,
            data: body,
          ),
        ),
      );

      expect(mapResponse(401, null), isA<UnauthorizedFailure>());
      final malformed = mapResponse(422, ['unexpected']) as ServerFailure;
      expect(malformed.statusCode, 422);
      expect(malformed.message, 'Dữ liệu không hợp lệ');
      expect(malformed.errors, isNull);

      final validation =
          mapResponse(422, {
                'message': 'Invalid input',
                'code': 'VALIDATION_ERROR',
                'errors': [
                  {'param': 'email', 'message': 'Required'},
                  'Malformed validation entry',
                ],
              })
              as ServerFailure;
      expect(validation.message, 'Invalid input');
      expect(validation.code, 'VALIDATION_ERROR');
      expect(validation.errors, const [
        ValidationError(field: 'email', message: 'Required'),
        ValidationError(field: '', message: 'Malformed validation entry'),
      ]);

      expect(mapResponse(503, null), isA<ServerFailure>());
      expect((mapResponse(503, null) as ServerFailure).statusCode, 503);
    });
  });
}
