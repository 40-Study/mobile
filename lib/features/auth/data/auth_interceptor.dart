import 'dart:async';

import 'package:dio/dio.dart';
import 'package:study/core/logger/app_logger.dart';
import 'package:study/core/network/network_error_interceptor.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/session_expired_notifier.dart';

/// Tự động gắn token vào request, tự refresh khi 401.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required AuthStorage authStorage,
    required Dio dio,
    required SessionExpiredNotifier sessionNotifier,
    Dio? retryDio,
  }) : _authStorage = authStorage,
       _sessionNotifier = sessionNotifier,
       _retryDio = retryDio ?? _defaultRetryDio(dio);

  final AuthStorage _authStorage;
  final SessionExpiredNotifier _sessionNotifier;

  // Dio riêng (không có AuthInterceptor) cho refresh + retry,
  // tránh đi lại vào queue của QueuedInterceptor → deadlock
  final Dio _retryDio;

  static const _refreshPath = '/api/auth/refresh-token';
  static const _logoutPath = '/api/auth/logout';

  // So khớp chính xác path, không dùng contains
  static const _publicPaths = {
    '/api/auth/login',
    '/api/auth/register/request',
    '/api/auth/register/resend-otp',
    '/api/auth/register',
    // Backend: select-role nằm trong nhóm public (dùng session_token của luồng login)
    '/api/auth/select-role',
    _refreshPath,
    '/api/auth/reset-password/request',
    '/api/auth/reset-password',
    '/api/auth/system-roles',
  };

  static Dio _defaultRetryDio(Dio dio) {
    return Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: dio.options.connectTimeout,
        receiveTimeout: dio.options.receiveTimeout,
        sendTimeout: dio.options.sendTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )..interceptors.add(NetworkErrorInterceptor());
  }

  // Bỏ query, không ghép baseUrl để path prefix của baseUrl không ảnh hưởng
  static String _pathOf(RequestOptions options) =>
      Uri.parse(options.path).path;

  static bool _isPublic(String path) => _publicPaths.contains(path);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(_pathOf(options))) {
      final token = await _authStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
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

    final path = _pathOf(err.requestOptions);
    if (path == _refreshPath || path == _logoutPath) {
      AppLogger.auth('401 on $path, clearing session');
      await _clearSession();
      return handler.next(err);
    }
    if (_isPublic(path)) {
      return handler.next(err);
    }

    final opts = err.requestOptions;
    final currentToken = await _authStorage.getAccessToken();
    final sentHeader = opts.headers['Authorization'];

    // Session đã bị clear bởi request trước trong queue → không refresh/notify lại
    if (currentToken == null && sentHeader != null) {
      return handler.next(err);
    }

    // Token đã được refresh bởi request trước trong queue → retry luôn
    final tokenChanged =
        currentToken != null && sentHeader != 'Bearer $currentToken';
    if (!tokenChanged) {
      AppLogger.auth('401 on $path, attempting token refresh...');
      final refreshAtStart = await _authStorage.getRefreshToken();
      switch (await _tryRefreshToken()) {
        case _RefreshResult.refreshed:
          break;
        case _RefreshResult.sessionChanged:
          // Đã logout / login phiên mới trong lúc refresh → không xoá phiên mới
          return handler.next(err);
        case _RefreshResult.failed:
          AppLogger.auth('Token refresh failed, clearing session');
          await _clearSessionIfUnchanged(refreshAtStart);
          return handler.next(err);
      }
    }

    final newToken = await _authStorage.getAccessToken();
    final refreshForRetry = await _authStorage.getRefreshToken();
    opts.headers['Authorization'] = 'Bearer $newToken';

    try {
      final response = await _retryDio.fetch<dynamic>(opts);
      handler.resolve(response);
    } on DioException catch (e) {
      // Retry vẫn 401 → token mới cũng bị từ chối, không refresh lại
      if (e.response?.statusCode == 401) {
        await _clearSessionIfUnchanged(refreshForRetry);
      }
      handler.next(e);
    }
  }

  // Chỉ clear khi session vẫn là session gây 401, không xoá phiên mới login
  Future<void> _clearSessionIfUnchanged(String? refreshToken) async {
    if (await _authStorage.getRefreshToken() != refreshToken) return;
    await _clearSession();
  }

  // Không để exception làm treo queue của QueuedInterceptor
  Future<void> _clearSession() async {
    try {
      await _authStorage.clearAll();
    } catch (e) {
      AppLogger.w('Clear session failed', e);
    } finally {
      _sessionNotifier.notify();
    }
  }

  Future<_RefreshResult> _tryRefreshToken() async {
    final refreshToken = await _authStorage.getRefreshToken();
    if (refreshToken == null) return _RefreshResult.failed;

    try {
      final response = await _retryDio.post<Map<String, dynamic>>(
        _refreshPath,
        data: {'refresh_token': refreshToken},
      );

      // User đã logout / login phiên khác trong lúc refresh → không ghi token cũ
      if (await _authStorage.getRefreshToken() != refreshToken) {
        return _RefreshResult.sessionChanged;
      }

      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) return _RefreshResult.failed;

      await _authStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      return _RefreshResult.refreshed;
    } catch (e, stackTrace) {
      AppLogger.w('Failed to refresh auth token', e);
      AppLogger.d('Token refresh stackTrace', stackTrace);
      return _RefreshResult.failed;
    }
  }
}

enum _RefreshResult { refreshed, failed, sessionChanged }
