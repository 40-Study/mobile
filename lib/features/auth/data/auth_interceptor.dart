import 'dart:async';

import 'package:dio/dio.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/session_expired_notifier.dart';

/// Tự động gắn token vào request, tự refresh khi 401.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required AuthStorage authStorage,
    required Dio dio,
    required SessionExpiredNotifier sessionNotifier,
  })  : _authStorage = authStorage,
        _dio = dio,
        _sessionNotifier = sessionNotifier;

  final AuthStorage _authStorage;
  final Dio _dio;
  final SessionExpiredNotifier _sessionNotifier;

  static const _publicPaths = [
    '/api/auth/login',
    '/api/auth/register/request',
    '/api/auth/register',
    '/api/auth/select-profile',
    '/api/auth/select-org',
    '/api/auth/refresh-token',
    '/api/auth/reset-password/request',
    '/api/auth/reset-password',
    '/api/system-roles',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic =
        _publicPaths.any((p) => options.path.contains(p));

    if (!isPublic) {
      final token = await _authStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] =
            'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final isRefreshCall = err.requestOptions.path
        .contains('/api/auth/refresh-token');
    if (isRefreshCall) {
      await _authStorage.clearAll();
      _sessionNotifier.notify();
      return handler.next(err);
    }

    final refreshed = await _tryRefreshToken();
    if (!refreshed) {
      await _authStorage.clearAll();
      _sessionNotifier.notify();
      return handler.next(err);
    }

    final newToken = await _authStorage.getAccessToken();
    final opts = err.requestOptions;
    opts.headers['Authorization'] = 'Bearer $newToken';

    try {
      final response = await _dio.fetch<dynamic>(opts);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken =
        await _authStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response =
          await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data?['data']
          as Map<String, dynamic>?;
      if (data == null) return false;

      await _authStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
