import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart' hide Environment;
import 'package:study/config/app_config.dart';
import 'package:study/config/environment.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/data/auth_api_client.dart';
import 'package:study/features/auth/data/auth_interceptor.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/session_expired_notifier.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio provideDio() {
    final config =
        Environment<AppConfig>.instance().config;

    final dio = Dio(BaseOptions(baseUrl: config.url));

    dio.interceptors.add(
      AuthInterceptor(
        authStorage: diContainer.get<AuthStorage>(),
        dio: dio,
        sessionNotifier:
            diContainer.get<SessionExpiredNotifier>(),
      ),
    );

    dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
      ),
    );

    return dio;
  }

  @lazySingleton
  AuthApiClient provideAuthApiClient(Dio dio) =>
      AuthApiClient(dio);
}
