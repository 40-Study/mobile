import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart' hide Environment;
import 'package:study/config/app_config.dart';
import 'package:study/config/environment.dart';
import 'package:study/core/network/network_error_interceptor.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/data/auth_api_client.dart';
import 'package:study/features/auth/data/auth_interceptor.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/session_expired_notifier.dart';
import 'package:study/features/course/data/course_api_client.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

// Logger debug-only, không log header (Bearer) và request body (password)
TalkerDioLogger _debugLogger() => TalkerDioLogger(
  settings: const TalkerDioLoggerSettings(
    printRequestHeaders: false,
    printResponseHeaders: false,
    printRequestData: false,
    // Response login/refresh chứa token
    printResponseData: false,
    printResponseMessage: true,
  ),
);

@module
abstract class NetworkModule {
  @lazySingleton
  Dio provideDio() {
    final config = Environment<AppConfig>.instance().config;
    const timeout = Duration(seconds: 30);

    final dio = Dio(
      BaseOptions(
        baseUrl: config.url,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Dio riêng cho refresh/retry, không gắn AuthInterceptor
    final retryDio = Dio(dio.options.copyWith());
    if (kDebugMode) retryDio.interceptors.add(_debugLogger());
    retryDio.interceptors.add(NetworkErrorInterceptor());

    dio.interceptors.add(
      AuthInterceptor(
        authStorage: diContainer.get<AuthStorage>(),
        dio: dio,
        sessionNotifier: diContainer.get<SessionExpiredNotifier>(),
        retryDio: retryDio,
      ),
    );

    if (kDebugMode) dio.interceptors.add(_debugLogger());

    dio.interceptors.add(NetworkErrorInterceptor());

    return dio;
  }

  @lazySingleton
  AuthApiClient provideAuthApiClient(Dio dio) => AuthApiClient(dio);

  @lazySingleton
  CourseApiClient provideCourseApiClient(Dio dio) => CourseApiClient(dio);
}
