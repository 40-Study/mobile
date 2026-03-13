import 'dart:async';

/// Phát event khi session hết hạn (token refresh thất bại).
/// Đăng ký trong DI, AuthInterceptor gọi notify(),
/// App widget listen stream để điều hướng về login.
class SessionExpiredNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  void dispose() => _controller.close();
}
