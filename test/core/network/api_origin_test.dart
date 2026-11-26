import 'package:flutter_test/flutter_test.dart';
import 'package:study/core/network/api_origin.dart';

void main() {
  final api = Uri.parse('https://api.40study.vn');

  group('isSameOrigin', () {
    test('should match same scheme host port', () {
      expect(isSameOrigin(Uri.parse('https://API.40study.vn/v/1.mp4'), api), isTrue);
    });

    test('should not attach auth for other hosts', () {
      expect(isSameOrigin(Uri.parse('https://api.attacker.com/x'), api), isFalse);
      expect(isSameOrigin(Uri.parse('https://40study.evil.io/x'), api), isFalse);
      expect(isSameOrigin(Uri.parse('https://cdn.cloudflare.com/v.mp4'), api), isFalse);
    });

    test('should not match http downgrade', () {
      expect(isSameOrigin(Uri.parse('http://api.40study.vn/x'), api), isFalse);
    });

    test('should not match different port', () {
      expect(isSameOrigin(Uri.parse('https://api.40study.vn:8443/x'), api), isFalse);
    });
  });

  group('videoAuthHeaders', () {
    test('should attach bearer for api origin', () {
      expect(
        videoAuthHeaders(Uri.parse('https://api.40study.vn/v.mp4'), apiBase: api, token: 't'),
        {'Authorization': 'Bearer t'},
      );
    });

    test('should be empty for other host', () {
      expect(
        videoAuthHeaders(Uri.parse('https://api.attacker.com/v.mp4'), apiBase: api, token: 't'),
        isEmpty,
      );
    });

    test('should be empty without token', () {
      expect(
        videoAuthHeaders(Uri.parse('https://api.40study.vn/v.mp4'), apiBase: api, token: null),
        isEmpty,
      );
    });
  });
}
