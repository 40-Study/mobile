import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/auth/presentation/utils/validators.dart';

void main() {
  group('AuthValidators', () {
    test('email handles missing, whitespace, and malformed values', () {
      expect(AuthValidators.email(null), 'Vui lòng nhập email');
      expect(AuthValidators.email('  '), 'Vui lòng nhập email');
      expect(AuthValidators.email(' student@example.com '), isNull);
      for (final value in [
        'plain',
        'a@b',
        'a@@example.com',
        'a@example.toolong',
      ]) {
        expect(
          AuthValidators.email(value),
          'Email không hợp lệ',
          reason: value,
        );
      }
    });

    test('password accepts the exact minimum and rejects one below it', () {
      expect(AuthValidators.password(null), 'Vui lòng nhập mật khẩu');
      expect(AuthValidators.password('1234567'), 'Mật khẩu tối thiểu 8 ký tự');
      expect(AuthValidators.password('12345678'), isNull);
    });

    test('OTP requires exactly six ASCII digits', () {
      expect(AuthValidators.otp(null), 'Vui lòng nhập mã OTP');
      for (final value in ['12345', '1234567', '12a456', '１２３４５６']) {
        expect(
          AuthValidators.otp(value),
          'Mã OTP phải có 6 chữ số',
          reason: value,
        );
      }
      expect(AuthValidators.otp('000001'), isNull);
    });

    test('required and username treat whitespace-only input as missing', () {
      expect(AuthValidators.required('\t\n', 'Tên'), 'Vui lòng nhập Tên');
      expect(AuthValidators.username('  '), 'Vui lòng nhập tên đăng nhập');
      expect(AuthValidators.username('ab'), 'Tên đăng nhập tối thiểu 3 ký tự');
      expect(AuthValidators.username(' abc '), isNull);
      expect(
        AuthValidators.confirmPassword('secret')('other'),
        'Mật khẩu không khớp',
      );
      expect(AuthValidators.confirmPassword('secret')('secret'), isNull);
    });
  });
}
