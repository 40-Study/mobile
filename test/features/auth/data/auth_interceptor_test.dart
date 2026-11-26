import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/network/network_error_interceptor.dart';
import 'package:study/features/auth/data/auth_interceptor.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/session_expired_notifier.dart';

class _Storage extends Mock implements AuthStorage {}

class _Notifier extends Mock implements SessionExpiredNotifier {}

// Fake adapter: mỗi path có queue status code, hết queue thì lặp lại phần tử cuối
class _FakeAdapter implements HttpClientAdapter {
  final Map<String, List<int>> statuses = {};
  final Map<String, int> _calls = {};
  final Map<String, Map<String, dynamic>> _headers = {};

  int calls(String path) => _calls[path] ?? 0;
  Map<String, dynamic> lastHeaders(String path) => _headers[path] ?? {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    _calls[path] = calls(path) + 1;
    _headers[path] = {
      for (final e in options.headers.entries) e.key.toLowerCase(): e.value,
    };
    // Delay nhỏ để các request song song cùng nhận 401 trước khi refresh xong
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final queue = statuses[path] ?? [200];
    final status = queue.length > 1 ? queue.removeAt(0) : queue.first;
    final body = path == '/api/auth/refresh-token' && status == 200
        ? {
            'data': {'access_token': 'new', 'refresh_token': 'r2'},
          }
        : {'ok': status == 200};
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AuthInterceptor', () {
    late _Storage storage;
    late _Notifier notifier;
    late _FakeAdapter adapter;
    late Dio dio;
    late String? accessToken;

    setUp(() {
      storage = _Storage();
      notifier = _Notifier();
      adapter = _FakeAdapter();
      accessToken = 'old';

      when(() => storage.getAccessToken()).thenAnswer((_) async => accessToken);
      when(() => storage.getRefreshToken()).thenAnswer((_) async => 'r1');
      when(
        () => storage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((inv) async {
        accessToken = inv.namedArguments[#accessToken] as String;
      });
      when(() => storage.clearAll()).thenAnswer((_) async {
        accessToken = null;
      });

      final options = BaseOptions(baseUrl: 'https://api.test');
      // Cùng adapter cho cả dio chính và retryDio, không ra mạng thật
      final retryDio = Dio(options)
        ..httpClientAdapter = adapter
        ..interceptors.add(NetworkErrorInterceptor());
      dio = Dio(options)..httpClientAdapter = adapter;
      dio.interceptors
        ..add(
          AuthInterceptor(
            authStorage: storage,
            dio: dio,
            sessionNotifier: notifier,
            retryDio: retryDio,
          ),
        )
        ..add(NetworkErrorInterceptor());
    });

    test('should refresh once for concurrent 401s', () async {
      adapter.statuses['/a'] = [401, 200];
      adapter.statuses['/b'] = [401, 200];

      final results = await Future.wait([dio.get<dynamic>('/a'), dio.get<dynamic>('/b')]);

      expect(results.map((r) => r.statusCode), [200, 200]);
      expect(adapter.calls('/api/auth/refresh-token'), 1);
      expect(adapter.lastHeaders('/b')['authorization'], 'Bearer new');
    });

    test('should complete with error when retried request fails', () async {
      adapter.statuses['/a'] = [401, 500];

      await expectLater(
        dio.get<dynamic>('/a').timeout(const Duration(seconds: 2)),
        throwsA(
          isA<DioException>().having((e) => e.response?.statusCode, 'status', 500),
        ),
      );
    });

    test('should attach token to paths that only share a public prefix', () async {
      await dio.get<dynamic>('/api/auth/register-device');

      expect(
        adapter.lastHeaders('/api/auth/register-device')['authorization'],
        'Bearer old',
      );
    });

    test('should not attach token to public paths', () async {
      await dio.post<dynamic>('/api/auth/login');

      expect(adapter.lastHeaders('/api/auth/login')['authorization'], isNull);
    });

    test('should clear session when refresh fails', () async {
      adapter.statuses['/a'] = [401];
      adapter.statuses['/api/auth/refresh-token'] = [401];

      await expectLater(dio.get<dynamic>('/a'), throwsA(isA<DioException>()));
      verify(() => storage.clearAll()).called(1);
      verify(() => notifier.notify()).called(1);
    });

    test('should clear session once when retried request still returns 401', () async {
      adapter.statuses['/a'] = [401, 401];

      await expectLater(dio.get<dynamic>('/a'), throwsA(isA<DioException>()));
      expect(adapter.calls('/api/auth/refresh-token'), 1);
      verify(() => notifier.notify()).called(1);
    });

    test('should not save refreshed tokens when user logged out meanwhile', () async {
      adapter.statuses['/a'] = [401];
      var refreshReads = 0;
      // Đọc 1-2: trước refresh, đọc 3 (sau API) trả null = đã logout
      when(() => storage.getRefreshToken()).thenAnswer(
        (_) async => ++refreshReads <= 2 ? 'r1' : null,
      );

      await expectLater(dio.get<dynamic>('/a'), throwsA(isA<DioException>()));
      verifyNever(
        () => storage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
    });

    test('should not clear new session when it replaced the old one during refresh', () async {
      adapter.statuses['/a'] = [401];
      var refreshReads = 0;
      // Phiên mới được lưu trong lúc refresh phiên cũ đang chạy
      when(() => storage.getRefreshToken()).thenAnswer(
        (_) async => ++refreshReads <= 2 ? 'r1' : 'r-new-session',
      );

      await expectLater(dio.get<dynamic>('/a'), throwsA(isA<DioException>()));
      verifyNever(() => storage.clearAll());
      verifyNever(() => notifier.notify());
    });

    test('should not clear new session when refresh fails after a new login', () async {
      adapter.statuses['/a'] = [401];
      adapter.statuses['/api/auth/refresh-token'] = [500];
      var refreshReads = 0;
      // Đọc 1: refreshAtStart, đọc 2: trong _tryRefreshToken, sau đó: phiên mới
      when(() => storage.getRefreshToken()).thenAnswer(
        (_) async => ++refreshReads <= 2 ? 'r1' : 'r-new-session',
      );

      await expectLater(dio.get<dynamic>('/a'), throwsA(isA<DioException>()));
      verifyNever(() => storage.clearAll());
      verifyNever(() => notifier.notify());
    });

    test('should map retry error to Failure', () async {
      adapter.statuses['/a'] = [401, 500];

      final e = await dio.get<dynamic>('/a').then<Object?>(
        (_) => null,
        onError: (Object e) => e,
      );

      expect(e, isA<DioException>());
      expect((e! as DioException).error, isA<Failure>());
    });
  });
}
