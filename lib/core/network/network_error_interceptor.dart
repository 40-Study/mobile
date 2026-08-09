import 'package:dio/dio.dart';
import 'package:study/core/logger/app_logger.dart';
import 'package:study/core/network/dio_error_mapper.dart';

class NetworkErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = DioErrorMapper.map(err);

    AppLogger.e(
      'API error: ${err.requestOptions.method} ${err.requestOptions.path}',
      failure,
      err.stackTrace,
    );

    handler.next(err.copyWith(error: failure));
  }
}
