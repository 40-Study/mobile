import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:study/di/di_container.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/teacher/data/teacher_api.dart';

class TeacherRealtime {
  TeacherRealtime({
    required this.api,
    required this.channels,
    required this.onEvent,
    required this.onStatus,
  });
  final TeacherApi api;
  final List<String> channels;
  final void Function() onEvent;
  final void Function(bool connected) onStatus;
  WebSocket? _socket;
  Timer? _retry;
  bool _closed = false;
  Future<void> connect() async {
    if (_closed) return;
    try {
      final token = await diContainer<AuthStorage>().getAccessToken();
      if (token == null) throw const FormatException('No session');
      final base = Uri.parse(api.dio.options.baseUrl);
      final url = base.replace(
        scheme: base.scheme == 'https' ? 'wss' : 'ws',
        path: '/api/ws',
        query: null,
      );
      final pending = WebSocket.connect(
        url.toString(),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );
      final socket = await pending.timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          // Future.timeout stops waiting, but leaves the underlying handshake alive.
          // Close a connection that arrives after this attempt was abandoned.
          unawaited(
            pending.then<void>((lateSocket) async {
              await lateSocket.close();
            }, onError: (Object _) {}),
          );
          throw TimeoutException('WebSocket handshake timed out.');
        },
      );
      if (_closed) {
        await socket.close();
        return;
      }
      _socket = socket;
      socket.pingInterval = const Duration(seconds: 25);
      for (final channel in channels) {
        socket.add(
          jsonEncode({
            'event': 'subscribe',
            'payload': {'channel': channel},
          }),
        );
      }
      onStatus(true);
      socket.listen(
        (event) {
          try {
            final data = jsonDecode(event.toString());
            if (data is Map) {
              if (data['event'] == 'error') {
                onStatus(false);
              } else if (const [
                'conversation_message',
                'message_updated',
                'message_deleted',
                'conversation_blocked_changed',
              ].contains(data['event'])) {
                onEvent();
              }
            }
          } catch (_) {
            /* Ignore non-JSON keepalive. */
          }
        },
        onDone: _disconnected,
        onError: (Object _) => _disconnected(),
        cancelOnError: true,
      );
    } catch (_) {
      _disconnected();
    }
  }

  void _disconnected() {
    if (_closed) return;
    onStatus(false);
    _socket?.close();
    _socket = null;
    _retry?.cancel();
    _retry = Timer(const Duration(seconds: 5), connect);
  }

  void dispose() {
    _closed = true;
    _retry?.cancel();
    _socket?.close();
  }
}
