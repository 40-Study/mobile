import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

abstract final class AppLogger {
  static final Talker _talker = Talker(
    settings: TalkerSettings(enabled: kDebugMode, useConsoleLogs: true),
  );

  static void d(String message, [Object? data]) {
    _talker.debug(_format(message, data));
  }

  static void i(String message, [Object? data]) {
    _talker.info(_format(message, data));
  }

  static void w(String message, [Object? data]) {
    _talker.warning(_format(message, data));
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.error(message, error, stackTrace);
  }

  static void auth(String message, [Object? data]) {
    d('[AUTH] $message', data);
  }

  static String _format(String message, Object? data) {
    if (data == null) return message;
    return '$message $data';
  }
}
